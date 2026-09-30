import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../providers/lead_scoring_provider.dart';
import '../providers/leads_provider.dart';
import 'lead_form_dialog.dart';

/// Interactive draggable card representing an individual deal in the CRM pipeline.
class LeadCard extends ConsumerStatefulWidget {
  final Lead lead;

  const LeadCard({super.key, required this.lead});

  @override
  ConsumerState<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends ConsumerState<LeadCard> {
  bool _isHovered = false;

  void _openEditDialog() {
    LeadFormDialog.show(context, existingLead: widget.lead);
  }

  void _moveToStage(LeadStage targetStage) {
    if (targetStage == widget.lead.stage) return;
    ref
        .read(leadsNotifierProvider.notifier)
        .updateStageOptimistic(
          leadId: widget.lead.id,
          targetStage: targetStage,
        );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Lead'),
        content: Text(
          'Are you sure you want to delete "${widget.lead.name}" (${widget.lead.companyName})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(leadsNotifierProvider.notifier)
                  .deleteLead(widget.lead.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;

    Widget cardContent({bool isFeedback = false}) {
      return Container(
        width: isFeedback ? 280 : double.infinity,
        decoration: BoxDecoration(
          color: isFeedback
              ? AppColors.surfaceElevated.withValues(alpha: 0.95)
              : (_isHovered
                    ? AppColors.surfaceElevated
                    : AppColors.surfaceDark.withValues(alpha: 0.65)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFeedback
                ? AppColors.primary
                : (_isHovered
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border),
            width: isFeedback ? 1.5 : 1.0,
          ),
          boxShadow: isFeedback
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : (_isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Company initial + Name + Accessible Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: lead.stage.color.withValues(alpha: 0.15),
                  child: Text(
                    lead.initial,
                    style: TextStyle(
                      color: lead.stage.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.companyName,
                        style: AppTypography.title.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead.name,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Accessible More Actions & Non-drag Stage Move Menu
                if (!isFeedback)
                  PopupMenuButton<String>(
                    tooltip: 'Lead options and stage movement',
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    color: AppColors.surfaceElevated,
                    padding: EdgeInsets.zero,
                    onSelected: (action) {
                      if (action == 'ai_score') {
                        ref
                            .read(leadScoreProvider(lead.id).notifier)
                            .score(note: lead.notes);
                      } else if (action == 'convert_to_customer') {
                        ref
                            .read(leadConversionProvider(lead.id).notifier)
                            .convert(
                              leadId: lead.id,
                              leadName: lead.name,
                              companyName: lead.companyName,
                              email: lead.email,
                              phone: lead.phone,
                            );
                      } else if (action == 'edit') {
                        _openEditDialog();
                      } else if (action == 'delete') {
                        _confirmDelete();
                      } else if (action.startsWith('stage:')) {
                        final stageName = action.replaceFirst('stage:', '');
                        final stage = LeadStage.values.firstWhere(
                          (s) => s.name == stageName,
                        );
                        _moveToStage(stage);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        if (lead.stage == LeadStage.won) ...[
                          const PopupMenuItem(
                            value: 'convert_to_customer',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text('Convert to Customer'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                        ],
                        const PopupMenuItem(
                          value: 'ai_score',
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text('AI Lead Score'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 8),
                              Text('Edit Lead'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        // Move to stage alternatives
                        ...LeadStage.values.where((s) => s != lead.stage).map((
                          s,
                        ) {
                          return PopupMenuItem(
                            value: 'stage:${s.name}',
                            child: Row(
                              children: [
                                Icon(s.icon, size: 16, color: s.color),
                                const SizedBox(width: 8),
                                Text('Move to ${s.label}'),
                              ],
                            ),
                          );
                        }),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Value badge + Contact / Notes preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Monetary Value Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      Text(
                        lead.valueFormatted,
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Contact touchpoint icon or email
                if (lead.email != null && lead.email!.isNotEmpty)
                  Flexible(
                    child: Tooltip(
                      message: lead.email!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              lead.email!,
                              style: AppTypography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (lead.phone != null && lead.phone!.isNotEmpty)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            lead.phone!,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 3: AI Qualification Scoring Section
            _buildAiScoringSection(context, ref, isFeedback),

            // Row 4: Won Lead -> Customer Conversion Action
            if (lead.stage == LeadStage.won) ...[
              const SizedBox(height: 8),
              _buildCustomerConversionSection(context, ref, isFeedback),
            ],
          ],
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Draggable<Lead>(
        data: lead,
        feedback: Material(
          type: MaterialType.transparency,
          child: cardContent(isFeedback: true),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: cardContent()),
        child: GestureDetector(onTap: _openEditDialog, child: cardContent()),
      ),
    );
  }

  Widget _buildAiScoringSection(
    BuildContext context,
    WidgetRef ref,
    bool isFeedback,
  ) {
    final scoreState = ref.watch(leadScoreProvider(widget.lead.id));

    if (scoreState is LeadScoreScoring) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Scoring...',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (scoreState is LeadScoreSuccess) {
      final leadScore = scoreState.score;
      final Color intentColor;
      switch (leadScore.intent) {
        case LeadIntent.high:
          intentColor = AppColors.success;
          break;
        case LeadIntent.med:
          intentColor = AppColors.warning;
          break;
        case LeadIntent.low:
          intentColor = AppColors.textSecondary;
          break;
      }

      return Tooltip(
        message: 'AI Recommendation:\n${leadScore.action}',
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.textPrimary),
        child: InkWell(
          onTap: isFeedback
              ? null
              : () => _showAiActionDialog(context, leadScore),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: intentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: intentColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 12, color: intentColor),
                const SizedBox(width: 4),
                Text(
                  '${leadScore.score}',
                  style: AppTypography.caption.copyWith(
                    color: intentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: intentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    leadScore.intent.label,
                    style: TextStyle(
                      color: intentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.info_outline_rounded,
                  size: 11,
                  color: intentColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (scoreState is LeadScoreError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: scoreState.message,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 11,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'AI Failed',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (!isFeedback)
            InkWell(
              onTap: () {
                ref
                    .read(leadScoreProvider(widget.lead.id).notifier)
                    .score(note: widget.lead.notes);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Retry',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // Default: LeadScoreIdle
    return InkWell(
      onTap: isFeedback
          ? null
          : () {
              ref
                  .read(leadScoreProvider(widget.lead.id).notifier)
                  .score(note: widget.lead.notes);
            },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 11,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'AI Score',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiActionDialog(BuildContext context, LeadScore score) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Recommendation',
              style: AppTypography.title.copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Score: ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${score.score} / 100',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Intent: ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  score.intent.label,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Recommended Action:',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(score.action, style: AppTypography.body),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerConversionSection(
    BuildContext context,
    WidgetRef ref,
    bool isFeedback,
  ) {
    final conversionState = ref.watch(leadConversionProvider(widget.lead.id));

    if (conversionState is LeadConversionLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Converting...',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (conversionState is LeadConversionSuccess) {
      final customer = conversionState.customer;
      return Tooltip(
        message:
            'Lead converted to customer: ${customer.companyName}. Click to open profile.',
        child: InkWell(
          onTap: isFeedback
              ? null
              : () {
                  ref.read(selectedCustomerIdProvider.notifier).state =
                      customer.id;
                  context.go('/customers');
                },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 13,
                  color: AppColors.success,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Converted',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 11,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (conversionState is LeadConversionError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 13,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Conversion failed',
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: isFeedback
                  ? null
                  : () {
                      ref
                          .read(leadConversionProvider(widget.lead.id).notifier)
                          .convert(
                            leadId: widget.lead.id,
                            leadName: widget.lead.name,
                            companyName: widget.lead.companyName,
                            email: widget.lead.email,
                            phone: widget.lead.phone,
                          );
                    },
              child: Text(
                'Retry',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default Idle State: "Convert to Customer" button
    return Semantics(
      label: 'Convert won lead to enterprise customer',
      button: true,
      child: Tooltip(
        message: 'Convert won lead into an enterprise customer account',
        child: InkWell(
          onTap: isFeedback
              ? null
              : () {
                  ref
                      .read(leadConversionProvider(widget.lead.id).notifier)
                      .convert(
                        leadId: widget.lead.id,
                        leadName: widget.lead.name,
                        companyName: widget.lead.companyName,
                        email: widget.lead.email,
                        phone: widget.lead.phone,
                      );
                },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Convert to Customer',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
