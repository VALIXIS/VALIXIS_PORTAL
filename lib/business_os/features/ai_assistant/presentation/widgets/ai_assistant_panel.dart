import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/assistant_message.dart';
import '../providers/ai_assistant_provider.dart';

/// Slide-over AI Executive Assistant Panel for VALIXIS BUSINESS OS.
class AIAssistantPanel extends ConsumerStatefulWidget {
  const AIAssistantPanel({super.key});

  @override
  ConsumerState<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends ConsumerState<AIAssistantPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  static const List<String> _quickPrompts = [
    'Summarize pending invoices',
    'Draft follow-up email to Acme',
    'Analyze lead conversion rate',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    final org = ref.read(currentOrganizationProvider);
    _inputController.clear();
    ref.read(aiAssistantProvider.notifier).sendMessage(text, organizationId: org?.id);
    _scrollToBottom();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text('Copied to clipboard'),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAssistantProvider);
    final notifier = ref.read(aiAssistantProvider.notifier);
    final isMobile = AppBreakpoints.isMobile(context);

    // Auto-scroll when messages update during streaming
    ref.listen<AiAssistantState>(aiAssistantProvider, (prev, next) {
      if (next.isStreaming || (prev?.messages.length != next.messages.length)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    if (!state.isPanelOpen) {
      return const SizedBox.shrink();
    }

    final panelWidth = isMobile
        ? MediaQuery.of(context).size.width
        : 440.0;

    return Stack(
      children: [
        // Backdrop overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: notifier.closePanel,
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
        ),

        // Slide-Over Assistant Panel
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Material(
            elevation: 16,
            color: Colors.transparent,
            child: Container(
              width: panelWidth,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  left: BorderSide(color: AppColors.border, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 28,
                    offset: const Offset(-6, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Panel Header
                    _buildHeader(context, state, notifier),

                    Divider(color: AppColors.border, height: 1),

                    // Quick Prompt Chips
                    _buildQuickPromptChips(state),

                    Divider(color: AppColors.border, height: 1),

                    // Message List Area
                    Expanded(
                      child: _buildMessagesList(state),
                    ),

                    // Input Control Footer
                    _buildInputFooter(state, notifier),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AiAssistantState state,
    AiAssistantNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALIXIS AI Assistant',
                  style: AppTypography.title.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: state.isStreaming
                            ? AppColors.primary
                            : AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: state.isStreaming
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    )
                        .animate(
                          target: state.isStreaming ? 1 : 0,
                          onPlay: (c) => c.repeat(reverse: true),
                        )
                        .fade(
                          begin: 0.3,
                          end: 1.0,
                          duration: const Duration(milliseconds: 400),
                        ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        state.isStreaming
                            ? 'Streaming Response...'
                            : 'Executive Business Intelligence',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              tooltip: 'Clear Conversation',
              color: AppColors.textSecondary,
              onPressed: notifier.clearConversation,
            ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: 'Close AI Assistant',
            color: AppColors.textSecondary,
            onPressed: notifier.closePanel,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptChips(AiAssistantState state) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _quickPrompts.map((chipText) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(
                  chipText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                avatar: const Icon(
                  Icons.bolt_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed:
                    state.isStreaming ? null : () => _handleSubmitted(chipText),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMessagesList(AiAssistantState state) {
    if (state.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 32,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How can VALIXIS AI assist your organization today?',
                style: AppTypography.title.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a quick prompt above or type a query to retrieve live business intelligence.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(AssistantMessage message) {
    final isUser = message.role == AssistantRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser)
                    Text(
                      message.content,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    )
                  else ...[
                    MarkdownBody(
                      data: message.content.isEmpty && message.isStreaming
                          ? 'Thinking...'
                          : message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        h1: AppTypography.title.copyWith(fontSize: 18),
                        h2: AppTypography.title.copyWith(fontSize: 16),
                        h3: AppTypography.title.copyWith(fontSize: 14),
                        h4: AppTypography.title.copyWith(fontSize: 13),
                        listBullet: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondary,
                        ),
                        code: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          backgroundColor: AppColors.background,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                      ),
                    ),
                    if (message.isStreaming) ...[
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                    if (!message.isStreaming && message.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            tooltip: 'Copy response to clipboard',
                            color: AppColors.textMuted,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _copyToClipboard(context, message.content),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputFooter(
    AiAssistantState state,
    AiAssistantNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              textInputAction: TextInputAction.send,
              maxLines: 3,
              minLines: 1,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Ask VALIXIS AI anything...',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
              ),
              onSubmitted: state.isStreaming ? null : _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          if (state.isStreaming)
            IconButton(
              icon: const Icon(Icons.stop_circle_outlined, color: AppColors.error),
              tooltip: 'Cancel streaming',
              onPressed: notifier.cancelStreaming,
            )
          else
            IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              tooltip: 'Send prompt',
              onPressed: () => _handleSubmitted(_inputController.text),
            ),
        ],
      ),
    );
  }
}
