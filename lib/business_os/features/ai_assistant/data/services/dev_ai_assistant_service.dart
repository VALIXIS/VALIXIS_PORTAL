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

Here is the current business summary of pending and outstanding receivables for your organization:

* **Total Pending Receivables**: \$24,500.00
* **Overdue Invoices**: 2 invoices (INV-2026-002, INV-2026-005)
* **Upcoming Due (Next 7 Days)**: \$10,000.00

#### Recommended Actions:
1. Send payment reminder to **Acme Corp** for invoice **INV-2026-002** (\$14,500.00).
2. Confirm receipt of wire transfer for **Starlight Media** (INV-2026-005).''';
    }

    if (p == 'Draft follow-up email to Acme') {
      return '''### Proposed Follow-Up Email: Acme Corp

**Subject**: Following up on VALIXIS Business OS Proposal & Next Steps

Hi Acme Team,

I hope this email finds you well.

I wanted to touch base regarding our recent enterprise proposal for VALIXIS Business OS. We have updated the custom deployment scope and SLA metrics as discussed.

Could we schedule a brief 15-minute sync this Thursday at 2:00 PM EST to address any remaining questions and review final sign-off?

Best regards,  
*VALIXIS Business Executive Team*''';
    }

    if (p == 'Analyze lead conversion rate') {
      return '''### CRM Lead Pipeline & Conversion Analysis

Based on current organization CRM performance metrics:

* **Active Pipeline Value**: \$185,000.00 across 14 active leads.
* **Overall Lead Conversion Rate**: **24.5%** (exceeds industry benchmark of 18.2%).
* **Average Sales Cycle**: 14.2 days from initial inquiry to closed-won deal.

#### Key Strategic Insights:
* **Top Performing Source**: Inbound enterprise inquiries convert at **42%**.
* **Stage Bottleneck**: 3 leads currently awaiting security review in the Proposal stage.''';
    }

    return '''### VALIXIS Business Assistant Analysis

I have processed your query: **"$p"**.

Based on your organization context:
* Operational metrics remain healthy across CRM, Invoicing, and Task Delivery.
* All customer communications and financial records are synchronized in real-time.

Please let me know if you would like me to generate a detailed report or draft specific communications!''';
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
