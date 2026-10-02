import 'package:flutter/material.dart';
import 'widgets/template_catalog_widget.dart';
import 'widgets/webhook_simulator_widget.dart';
import 'widgets/workflow_builder_canvas.dart';

class WorkflowsScreen extends StatelessWidget {
  const WorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VALIXIS Flow — Workflow Builder & Webhook Simulator'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TemplateCatalogWidget(),
            SizedBox(height: 32),
            WorkflowBuilderCanvas(),
            SizedBox(height: 32),
            WebhookSimulatorWidget(),
          ],
        ),
      ),
    );
  }
}

