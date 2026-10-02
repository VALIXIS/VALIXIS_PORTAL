import 'dart:async';
import '../../domain/services/ai_assistant_service.dart';

/// Development/Offline mock implementation of AiAssistantService with token streaming.
class DevAiAssistantService implements AiAssistantService {
  final Map<String, StreamController<String>> _activeControllers = {};

  @override
  Stream<String> streamAssistantResponse({
    required String prompt,
    required String organizationId,
  }) {
    final controller = StreamController<String>();
    final key = 'stream_${DateTime.now().microsecondsSinceEpoch}';
    _activeControllers[key] = controller;

    final fullResponse = _getResponseForPrompt(prompt);
    final words = fullResponse.split(' ');

    int wordIndex = 0;
    Timer? timer;

    timer = Timer.periodic(const Duration(milliseconds: 25), (t) {
      if (controller.isClosed) {
        t.cancel();
        _activeControllers.remove(key);
        return;
      }

      if (wordIndex < words.length) {
        final token = (wordIndex == 0 ? '' : ' ') + words[wordIndex];
        controller.add(token);
        wordIndex++;
      } else {
        t.cancel();
        controller.close();
        _activeControllers.remove(key);
      }
    });

    controller.onCancel = () {
      timer?.cancel();
      _activeControllers.remove(key);
    };

    return controller.stream;
  }

  @override
  Future<String> generateAssistantResponse({
    required String prompt,
    required String organizationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _getResponseForPrompt(prompt);
  }

  String _getResponseForPrompt(String prompt) {
    final p = prompt.trim();
    if (p == 'Summarize pending invoices') {
      return '''### Pending Invoices Overview

There are currently no outstanding overdue invoices requiring escalation. All accounts receivable are up to date.

* **Total Pending Receivables**: \$0.00
* **Overdue Invoices**: 0

Please create new invoices in the Invoices section to track billables.''';
    }

    if (p == 'Draft follow-up email to Acme' || p.toLowerCase().contains('draft follow-up')) {
      return '''### Proposed Follow-Up Email

**Subject**: Following up on our recent conversation & Next Steps

Hi Team,

I hope this email finds you well.

I wanted to touch base regarding our recent discussion. We have prepared the requested documentation and deployment roadmap.

Could we schedule a brief 15-minute sync to address any questions and review next steps?

Best regards,  
*VALIXIS Executive Team*''';
    }

    if (p == 'Analyze lead conversion rate') {
      return '''### CRM Lead Pipeline & Conversion Analysis

CRM pipeline analytics will calculate real-time conversion rates as inbound leads and opportunities are recorded.

* **Active Pipeline Status**: Clean pipeline ready for intake.
* **Stage Tracking**: Lead stages (New, Contacted, Qualified, Proposal, Won) are monitored live.''';
    }

    return '''### VALIXIS Business Assistant Analysis

I have processed your query: **"$p"**.

Based on your organization context:
* Operational metrics remain healthy across CRM, Invoicing, and Task Delivery.
* All customer communications and financial records are synchronized in real-time.

Please let me know if you would like me to generate a detailed report or assist with operations!''';
  }

  @override
  void dispose() {
    for (final controller in _activeControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _activeControllers.clear();
  }
}
