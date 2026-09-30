import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/app_utils.dart';
import '../providers/leads_provider.dart';
import 'lead_card.dart';
import 'lead_form_dialog.dart';

/// Single Kanban Stage Column with DragTarget drop zone and scrollable card list.
class LeadColumn extends ConsumerStatefulWidget {
  final LeadStage stage;
  final List<Lead> leads;
  final double width;

  const LeadColumn({
    super.key,
    required this.stage,
    required this.leads,
    this.width = 300,
  });

  @override
  ConsumerState<LeadColumn> createState() => _LeadColumnState();
}

class _LeadColumnState extends ConsumerState<LeadColumn> {
  bool _isDragOver = false;

  double get _totalStageValue {
    return widget.leads.fold(0.0, (acc, lead) => acc + lead.estimatedValue);
  }

  void _onLeadDropped(Lead draggedLead) {
    if (draggedLead.stage == widget.stage) return;
    ref
        .read(leadsNotifierProvider.notifier)
        .updateStageOptimistic(
          leadId: draggedLead.id,
          targetStage: widget.stage,
        );
  }

  void _quickAddLead() {
    LeadFormDialog.show(
      context,
      existingLead: Lead(
        id: '',
        organizationId: '',
        name: '',
        companyName: '',
        stage: widget.stage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final leads = widget.leads;

    return DragTarget<Lead>(
      onWillAcceptWithDetails: (details) {
        final willAccept = details.data.stage != stage;
        setState(() => _isDragOver = willAccept);
        return willAccept;
      },
      onLeave: (_) {
        setState(() => _isDragOver = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        _onLeadDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: _isDragOver
                ? stage.color.withValues(alpha: 0.12)
                : AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDragOver
                  ? stage.color
                  : AppColors.border.withValues(alpha: 0.6),
              width: _isDragOver ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Stage indicator dot / icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: stage.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(stage.icon, color: stage.color, size: 14),
                    ),
                    const SizedBox(width: 8),

                    // Stage Name
                    Expanded(
                      child: Text(
                        stage.label,
                        style: AppTypography.title.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Stage Value Badge
                    if (_totalStageValue > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          AppUtils.formatCurrency(_totalStageValue),
                          style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                    // Count pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stage.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        leads.length.toString(),
                        style: TextStyle(
                          color: stage.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),
                    // Quick add to this stage
                    IconButton(
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      tooltip: 'Add lead to ${stage.label}',
                      onPressed: _quickAddLead,
                    ),
                  ],
                ),
              ),

              // Cards list or empty drop area
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                stage.icon,
                                size: 28,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No leads in ${stage.label}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _quickAddLead,
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text(
                                  'Add Lead',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lead = leads[index];
                          return LeadCard(key: ValueKey(lead.id), lead: lead);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
