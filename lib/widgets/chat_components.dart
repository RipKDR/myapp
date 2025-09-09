import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';

/// Advanced chat components for AI assistant interface
/// Following 2025 conversational UI design trends with accessibility focus

/// Enhanced chat message bubble with rich content support
class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isUser;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTimestamp;
  final bool showAvatar;
  final Animation<double>? animation;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.onTap,
    this.onLongPress,
    this.showTimestamp = true,
    this.showAvatar = true,
    this.animation,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: widget.animation ?? const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return FadeTransition(
          opacity: widget.animation ?? const AlwaysStoppedAnimation(1.0),
          child: SlideTransition(
            position: widget.animation != null
                ? Tween<Offset>(
                    begin: widget.isUser
                        ? const Offset(0.3, 0)
                        : const Offset(-0.3, 0),
                    end: Offset.zero,
                  ).animate(widget.animation!)
                : const AlwaysStoppedAnimation(Offset.zero),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTapDown: (_) => _handleTapDown(),
                    onTapUp: (_) => _handleTapUp(),
                    onTapCancel: () => _handleTapUp(),
                    onTap: widget.onTap,
                    onLongPress: widget.onLongPress,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!widget.isUser) ...[
                            if (widget.showAvatar)
                              _buildAvatar(context)
                            else
                              const SizedBox(width: 40),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: widget.isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                _buildMessageContent(context),
                                if (widget.showTimestamp) ...[
                                  const SizedBox(height: 4),
                                  _buildTimestamp(context),
                                ],
                              ],
                            ),
                          ),
                          if (widget.isUser) ...[
                            const SizedBox(width: 8),
                            if (widget.showAvatar)
                              _buildAvatar(context)
                            else
                              const SizedBox(width: 40),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 16,
      backgroundColor: widget.isUser
          ? GoogleTheme.googleBlue.withOpacity(0.1)
          : GoogleTheme.googleGreen.withOpacity(0.1),
      child: Icon(
        widget.isUser ? Icons.person : Icons.smart_toy,
        size: 16,
        color: widget.isUser ? GoogleTheme.googleBlue : GoogleTheme.googleGreen,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isUser
            ? GoogleTheme.googleBlue
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(widget.isUser ? 20 : 4),
          bottomRight: Radius.circular(widget.isUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message text
          Text(
            widget.message.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: widget.isUser ? Colors.white : colorScheme.onSurface,
              height: 1.4,
            ),
          ),

          // Quick actions for AI responses
          if (!widget.isUser && widget.message.quickActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.message.quickActions.map((action) {
                return _buildQuickActionChip(action);
              }).toList(),
            ),
          ],

          // Message status
          if (widget.isUser) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(widget.message.status),
                  size: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  _getStatusText(widget.message.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(QuickAction action) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: GoogleTheme.googleBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GoogleTheme.googleBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                size: 14,
                color: GoogleTheme.googleBlue,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              action.text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: GoogleTheme.googleBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      _formatTimestamp(widget.message.timestamp),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.schedule;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  String _getStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }
}

/// Advanced chat input with voice support and suggestions
class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onVoiceInput;
  final bool isVoiceInputActive;
  final bool isLoading;
  final List<String> suggestions;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.onVoiceInput,
    this.isVoiceInputActive = false,
    this.isLoading = false,
    this.suggestions = const [],
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _voiceAnimationController;
  late Animation<double> _voicePulseAnimation;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _textController.addListener(_onTextChanged);
  }

  void _initializeAnimations() {
    _voiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _voicePulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _voiceAnimationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVoiceInputActive) {
      _voiceAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVoiceInputActive != oldWidget.isVoiceInputActive) {
      if (widget.isVoiceInputActive) {
        _voiceAnimationController.repeat(reverse: true);
      } else {
        _voiceAnimationController.stop();
        _voiceAnimationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _voiceAnimationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Suggestions
        if (widget.suggestions.isNotEmpty && !_hasText) ...[
          _buildSuggestions(context),
          const SizedBox(height: 12),
        ],

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _hasText ? _sendMessage : null,
                            decoration: InputDecoration(
                              hintText: widget.isVoiceInputActive
                                  ? 'Listening...'
                                  : 'Ask about NDIS, bookings, budget...',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),

                        // Voice input button
                        if (widget.onVoiceInput != null)
                          AnimatedBuilder(
                            animation: _voicePulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: widget.isVoiceInputActive
                                    ? _voicePulseAnimation.value
                                    : 1.0,
                                child: IconButton(
                                  onPressed: widget.onVoiceInput,
                                  icon: Icon(
                                    widget.isVoiceInputActive
                                        ? Icons.mic
                                        : Icons.mic_none,
                                    color: widget.isVoiceInputActive
                                        ? GoogleTheme.googleRed
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: widget.isVoiceInputActive
                                      ? 'Stop recording'
                                      : 'Voice input',
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FloatingActionButton.small(
                    onPressed:
                        _hasText && !widget.isLoading ? _sendMessage : null,
                    backgroundColor: _hasText
                        ? GoogleTheme.googleBlue
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor:
                        _hasText ? Colors.white : colorScheme.onSurfaceVariant,
                    elevation: _hasText ? 2 : 0,
                    child: widget.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = widget.suggestions[index];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                _textController.text = suggestion;
                _sendMessage(suggestion);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _sendMessage([String? text]) {
    final message = text ?? _textController.text.trim();
    if (message.isEmpty) return;

    widget.onSendMessage(message);
    _textController.clear();
    _focusNode.unfocus();
    HapticFeedback.lightImpact();
  }
}

/// Typing indicator for AI responses
class TypingIndicator extends StatefulWidget {
  final bool isVisible;
  final String? typingText;

  const TypingIndicator({
    super.key,
    this.isVisible = false,
    this.typingText,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          (index * 0.2) + 0.4,
          curve: Curves.easeInOut,
        ),
      ));
    });

    if (widget.isVisible) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: GoogleTheme.googleGreen.withOpacity(0.1),
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: GoogleTheme.googleGreen,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.typingText ?? 'NDIS Assistant is typing',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _dotAnimations[index],
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _dotAnimations[index].value,
                          child: Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: GoogleTheme.googleGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat welcome banner with NDIS-specific quick actions
class ChatWelcomeBanner extends StatelessWidget {
  final Function(String) onQuickAction;

  const ChatWelcomeBanner({
    super.key,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GoogleTheme.googleBlue.withOpacity(0.1),
            GoogleTheme.googleGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GoogleTheme.googleBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GoogleTheme.googleBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: GoogleTheme.googleBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'NDIS Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'I\'m here to help you with NDIS questions, appointment booking, budget tracking, and more. Try asking me something!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Actions:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickActionButton(
                  context, 'Check my budget', Icons.account_balance_wallet),
              _buildQuickActionButton(
                  context, 'Book an appointment', Icons.event_available),
              _buildQuickActionButton(
                  context, 'Find services nearby', Icons.map),
              _buildQuickActionButton(
                  context, 'Explain my plan', Icons.help_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onQuickAction(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GoogleTheme.googleBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: GoogleTheme.googleBlue,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: GoogleTheme.googleBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models for chat components
class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final MessageStatus status;
  final List<QuickAction> quickActions;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.status = MessageStatus.delivered,
    this.quickActions = const [],
    this.type = MessageType.text,
  });
}

class QuickAction {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const QuickAction({
    required this.text,
    this.icon,
    required this.onTap,
  });
}

enum MessageStatus { sending, sent, delivered, failed }

enum MessageType { text, voice, system }
