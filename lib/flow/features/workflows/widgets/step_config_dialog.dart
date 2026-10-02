import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/builder_step_model.dart';

class StepConfigDialog extends StatefulWidget {
  final BuilderStep step;
  final void Function(Map<String, dynamic> config, String? actionType) onSave;

  const StepConfigDialog({
    super.key,
    required this.step,
    required this.onSave,
  });

  @override
  State<StepConfigDialog> createState() => _StepConfigDialogState();
}

class _StepConfigDialogState extends State<StepConfigDialog> {
  late TextEditingController _titleController;
  late TextEditingController _customPromptController;
  late TextEditingController _emailMappingController;
  late double _temperature;
  late String _actionType;

  final List<String> _availableVariables = [
    '{{trigger.name}}',
    '{{trigger.email}}',
    '{{trigger.phone}}',
    '{{trigger.company}}',
    '{{ai.extracted_budget}}',
    '{{ai.summary}}',
    '{{ai.lead_score}}',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.step.title);
    _customPromptController = TextEditingController(
      text: widget.step.config['prompt_instructions'] as String? ?? 'Extract business intent & entities.',
    );
    _emailMappingController = TextEditingController(
      text: widget.step.config['mapped_email'] as String? ?? '{{trigger.email}}',
    );
    _temperature = (widget.step.config['temperature'] as num?)?.toDouble() ?? 0.2;
    _actionType = widget.step.actionType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customPromptController.dispose();
    _emailMappingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.obsidianSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.obsidianBorder),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.electricCyan, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Configure: ${widget.step.title}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (widget.step.type == StepType.aiReasoning) ...[
              const Text('Temperature (Creativity vs Determinism)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Slider(
                value: _temperature,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: AppColors.electricCyan,
                label: _temperature.toStringAsFixed(1),
                onChanged: (val) => setState(() => _temperature = val),
              ),
              const SizedBox(height: 12),
              const Text('Custom System Instruction Prompt', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _customPromptController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  fillColor: AppColors.obsidianCard,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],

            if (widget.step.type == StepType.actionDispatcher) ...[
              const Text('Target Action Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: _actionType,
                dropdownColor: AppColors.obsidianCard,
                isExpanded: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                items: const [
                  DropdownMenuItem(value: 'create_lead', child: Text('Create CRM Lead (create_lead)')),
                  DropdownMenuItem(value: 'create_task', child: Text('Create Operational Task (create_task)')),
                  DropdownMenuItem(value: 'draft_email', child: Text('Draft AI Response Email (draft_email)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _actionType = val);
                },
              ),
              const SizedBox(height: 16),
              const Text('Mapped Recipient Email', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailMappingController,
                style: const TextStyle(color: AppColors.electricCyan, fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  fillColor: AppColors.obsidianCard,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Text('Dynamic Variable Autocomplete Picker', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableVariables.map((v) {
                return ActionChip(
                  label: Text(v, style: const TextStyle(color: AppColors.electricCyan, fontFamily: 'monospace', fontSize: 11)),
                  backgroundColor: AppColors.obsidianCard,
                  side: const BorderSide(color: AppColors.obsidianBorder),
                  onPressed: () {
                    _emailMappingController.text = v;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Inserted $v into variable mapping!')),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final newConfig = Map<String, dynamic>.from(widget.step.config);
                    newConfig['temperature'] = _temperature;
                    newConfig['prompt_instructions'] = _customPromptController.text;
                    newConfig['mapped_email'] = _emailMappingController.text;

                    widget.onSave(newConfig, _actionType);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricCyan,
                    foregroundColor: AppColors.obsidianDark,
                  ),
                  child: const Text('Save Step Config'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
