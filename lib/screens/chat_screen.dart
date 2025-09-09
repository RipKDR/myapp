import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chat_service.dart';
import '../widgets/feature_guard.dart';
import '../core/feature_flags.dart';
import '../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _chat = ChatService();
  final _messages = <_Msg>[];
  late stt.SpeechToText _stt;
  bool _listening = false;
  bool _isTyping = false;
  late AnimationController _typingController;
  late AnimationController _pulseController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _stt = stt.SpeechToText();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _typingController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(_Msg(
      "Hi! I'm your NDIS Assistant. I can help you with questions about your plan, finding services, understanding your budget, and more. What would you like to know?",
      false,
      isWelcome: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.ndisTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.ndisTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('NDIS Assistant'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'call',
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 18),
                    SizedBox(width: 8),
                    Text('Call NDIA 1800 800 110'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email, size: 18),
                    SizedBox(width: 8),
                    Text('Email NDIA enquiries@ndis.gov.au'),
                  ],
                ),
              ),
            ],
            onSelected: (v) => _escalate(v),
          )
        ],
      ),
      body: FeatureGuard(
        tier: FeatureTier.premium,
        child: Column(
          children: [
            // Quick Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: scheme.outline.withOpacity(0.1)),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickActionChip(
                      label: 'Budget Help',
                      icon: Icons.account_balance_wallet,
                      onTap: () =>
                          _sendQuickMessage('Help me understand my budget'),
                    ),
                    const SizedBox(width: 8),
                    _QuickActionChip(
                      label: 'Find Services',
                      icon: Icons.search,
                      onTap: () =>
                          _sendQuickMessage('Help me find services near me'),
                    ),
                    const SizedBox(width: 8),
                    _QuickActionChip(
                      label: 'Plan Questions',
                      icon: Icons.help_outline,
                      onTap: () => _sendQuickMessage(
                          'I have questions about my NDIS plan'),
                    ),
                  ],
                ),
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length && _isTyping) {
                    return _TypingIndicator(controller: _typingController);
                  }
                  final m = _messages[i];
                  return _MessageBubble(message: m);
                },
              ),
            ),

            // Input Area
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(color: scheme.outline.withOpacity(0.1)),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Voice Input Button
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _listening
                                ? 1.0 + (_pulseController.value * 0.1)
                                : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _listening
                                    ? AppTheme.ndisOrange
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                tooltip: _listening
                                    ? 'Stop listening'
                                    : 'Voice input',
                                icon: Icon(
                                  _listening ? Icons.mic : Icons.mic_none,
                                  color: _listening
                                      ? Colors.white
                                      : scheme.onSurfaceVariant,
                                ),
                                onPressed: _toggleListening,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Text Input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: scheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Ask a question about NDIS...',
                              hintStyle:
                                  TextStyle(color: scheme.onSurfaceVariant),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Send Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.ndisBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          tooltip: 'Send',
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed:
                              _controller.text.trim().isEmpty ? null : _send,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _escalate(String v) async {
    if (v == 'call') {
      await _launch('tel:1800800110');
    } else if (v == 'email') {
      await _launch(
          'mailto:enquiries@ndis.gov.au?subject=NDIS%20Connect%20support');
    }
  }

  Future<void> _launch(String url) async {
    final ok = await canLaunchUrl(Uri.parse(url));
    if (ok) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _sendQuickMessage(String message) {
    _controller.text = message;
    _send();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg(text, true));
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _typingController.repeat();

    final reply = await _chat.ask(text);
    if (!mounted) return;

    setState(() {
      _messages.add(_Msg(reply, false));
      _isTyping = false;
    });

    _typingController.stop();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _stt.stop();
      setState(() {
        _listening = false;
        _pulseController.stop();
      });
      return;
    }

    final available = await _stt.initialize();
    if (!available) return;

    setState(() {
      _listening = true;
      _pulseController.repeat();
    });

    _stt.listen(
      onResult: (r) {
        setState(() => _controller.text = r.recognizedWords);
      },
      onSoundLevelChange: (level) {
        // Could add visual feedback for sound level
      },
    );
  }
}

class _Msg {
  final String text;
  final bool mine;
  final bool isWelcome;

  _Msg(this.text, this.mine, {this.isWelcome = false});
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.ndisBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.ndisBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.ndisBlue,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.ndisBlue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Msg message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.mine) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.ndisTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppTheme.ndisTeal,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.mine
                    ? AppTheme.ndisBlue
                    : message.isWelcome
                        ? AppTheme.ndisTeal.withOpacity(0.1)
                        : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.mine
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.mine
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: message.isWelcome
                    ? Border.all(color: AppTheme.ndisTeal.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.mine ? Colors.white : scheme.onSurface,
                        ),
                  ),
                  if (message.isWelcome) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.ndisTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.ndisTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Try asking: "How do I check my budget?" or "Find physiotherapy near me"',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.ndisTeal,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.mine) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.ndisBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.ndisBlue,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final AnimationController controller;

  const _TypingIndicator({required this.controller});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> {
  @override
  void initState() {
    super.initState();
    widget.controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.ndisTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: AppTheme.ndisTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue =
                        (widget.controller.value - delay).clamp(0.0, 1.0);
                    final scale =
                        0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.ndisTeal.withOpacity(scale),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
