import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/google_theme.dart';
import '../widgets/chat_components.dart';
import '../widgets/enhanced_form_components.dart';
import '../widgets/trending_2025_components.dart';
import '../widgets/neo_brutalism_components.dart';
import '../widgets/advanced_glassmorphism_2025.dart';
import '../widgets/cinematic_data_storytelling.dart';

/// Enhanced AI chat assistant screen with conversational UI
/// Following 2025 design trends with advanced voice support and NDIS expertise
class EnhancedChatScreen extends StatefulWidget {
  const EnhancedChatScreen({super.key});

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _messageController;
  late ScrollController _scrollController;

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isVoiceInputActive = false;
  bool _isLoading = false;

  final List<String> _quickSuggestions = [
    'What is my current budget status?',
    'Book a physiotherapy session',
    'Find services near me',
    'Explain my NDIS plan',
    'When is my next appointment?',
    'How do I claim expenses?',
    'Show my health progress',
    'Contact my support coordinator',
    'Set medication reminder',
    'Emergency contact help',
  ];

  // Enhanced AI conversation context
  String _currentConversationTopic = 'general';
  int _conversationDepth = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _addWelcomeMessage();
  }

  void _initializeControllers() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController = ScrollController();

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final hour = DateTime.now().hour;
    String greeting = 'Hi';
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17)
      greeting = 'Good afternoon';
    else
      greeting = 'Good evening';

    final welcomeMessage = ChatMessage(
      id: 'welcome',
      text:
          '$greeting! I\'m your enhanced NDIS Assistant with AI-powered voice support. I understand NDIS plans, can help book appointments, track budgets, manage health goals, and provide emotional support. I\'m here 24/7 for your journey. How can I support you today?',
      timestamp: DateTime.now(),
      isUser: false,
      quickActions: [
        QuickAction(
          text: 'Budget & Spending',
          icon: Icons.account_balance_wallet,
          onTap: () =>
              _handleQuickAction('Show my budget status and spending patterns'),
        ),
        QuickAction(
          text: 'Book Healthcare',
          icon: Icons.healing,
          onTap: () => _handleQuickAction(
              'Book a healthcare appointment with my preferred providers'),
        ),
        QuickAction(
          text: 'Health Progress',
          icon: Icons.trending_up,
          onTap: () => _handleQuickAction(
              'Show my health goals and progress this month'),
        ),
        QuickAction(
          text: 'Emergency Help',
          icon: Icons.emergency,
          onTap: () =>
              _handleQuickAction('I need emergency contact assistance'),
        ),
      ],
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (final context, final innerBoxIsScrolled) => [
            _buildEnhancedSliverAppBar(context),
          ],
        body: Column(
          children: [
            // Enhanced conversation context indicator
            _buildConversationContext(context),

            // Chat messages with glassmorphism background
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      GoogleTheme.googleBlue.withValues(alpha: 0.1),
                      Colors.transparent,
                      GoogleTheme.ndisTeal.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: _messages.isEmpty
                    ? _buildEnhancedEmptyState(context)
                    : _buildEnhancedMessagesList(context),
              ),
            ),

            // Enhanced typing indicator with personality
            _buildEnhancedTypingIndicator(),

            // Voice-first input interface
            _buildVoiceFirstInputInterface(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSliverAppBar(final BuildContext context) => SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text('NDIS Assistant'),
      actions: [
        // Voice activation toggle
        Trending2025Components.buildInteractiveButton(
          label: 'Voice',
          onPressed: _toggleVoiceInput,
          icon: Icons.mic,
          isPrimary: _isVoiceInputActive,
          backgroundColor: _isVoiceInputActive
              ? GoogleTheme.googleRed
              : GoogleTheme.googleGreen,
          hasPulseAnimation: _isVoiceInputActive,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _showEnhancedChatSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Chat Settings',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: NeoBrutalismComponents.buildStrikingHeader(
          context: context,
          title: 'AI Chat Assistant',
          subtitle: 'Voice-powered NDIS support',
          backgroundColor: GoogleTheme.googleGreen,
          trailing: CinematicDataStoryTelling.buildAnimatedDataStory(
            context: context,
            title: 'Conversations',
            value: (_messages.length ~/ 2).toString(),
            previousValue: '${(_messages.length ~/ 2) - 1}',
            trendDescription: 'Getting helpful answers',
            icon: Icons.chat_bubble,
            color: GoogleTheme.ndisTeal,
            showCelebration: _messages.length > 10,
          ),
        ),
      ),
    );

  Widget _buildConversationContext(final BuildContext context) {
    if (_conversationDepth == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CinematicDataStoryTelling.buildContextualVisualCue(
        context: context,
        message:
            'We\'re discussing $_currentConversationTopic • ${_messages.length ~/ 2} exchanges',
        type: CueType.info,
      ),
    );
  }

  Widget _buildEnhancedEmptyState(final BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Enhanced welcome with glassmorphism
          AdvancedGlassmorphism2025.buildInteractiveGlassCard(
            context: context,
            child: Column(
              children: [
                // AI Assistant avatar with personality
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        GoogleTheme.googleGreen,
                        GoogleTheme.ndisTeal,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: GoogleTheme.googleGreen.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Welcome to Your NDIS Assistant',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: GoogleTheme.googleGreen,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'I\'m here to help with your NDIS journey. I can assist with appointments, budgets, finding services, understanding your plan, and providing emotional support.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Voice activation with prominence
                Trending2025Components.buildVoiceInterface(
                  context: context,
                  isListening: _isVoiceInputActive,
                  onVoiceToggle: _toggleVoiceInput,
                  isAccessible: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Enhanced quick start suggestions
          Text(
            'Quick Start Suggestions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildEnhancedSuggestionChip('Budget Help',
                  Icons.account_balance_wallet, GoogleTheme.googleBlue),
              _buildEnhancedSuggestionChip(
                  'Book Session', Icons.healing, GoogleTheme.googleGreen),
              _buildEnhancedSuggestionChip(
                  'Health Goals', Icons.trending_up, GoogleTheme.ndisTeal),
              _buildEnhancedSuggestionChip(
                  'Emergency Help', Icons.emergency, GoogleTheme.googleRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessagesList(final BuildContext context) => ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (final context, final index) {
        final message = _messages[index];
        final animation = _createMessageAnimation(index);

        return _buildEnhancedMessageBubble(
          message: message,
          animation: animation,
          index: index,
        );
      },
    );

  Widget _buildEnhancedMessageBubble({
    required final ChatMessage message,
    final Animation<double>? animation,
    required final int index,
  }) {
    final isUser = message.isUser;

    return AnimatedBuilder(
      animation: animation ?? const AlwaysStoppedAnimation(1),
      builder: (final context, final child) => FadeTransition(
          opacity: animation ?? const AlwaysStoppedAnimation(1),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(isUser ? 0.3 : -0.3, 0),
              end: Offset.zero,
            ).animate(animation ?? const AlwaysStoppedAnimation(1)),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    // AI Assistant avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GoogleTheme.googleGreen,
                            GoogleTheme.ndisTeal,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Enhanced message bubble with glassmorphism
                  Flexible(
                    child: AdvancedGlassmorphism2025.buildInteractiveGlassCard(
                      context: context,
                      child: _buildMessageContent(message),
                      onTap: () => _handleMessageTap(message),
                      accentColor: isUser
                          ? GoogleTheme.googleBlue
                          : GoogleTheme.googleGreen,
                    ),
                  ),

                  if (isUser) ...[
                    const SizedBox(width: 12),
                    // User avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: GoogleTheme.googleBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildMessageContent(final ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: isUser ? Colors.white : null,
          ),
        ),
        if (message.quickActions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: message.quickActions.map((final action) => GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  action.onTap();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GoogleTheme.googleGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: GoogleTheme.googleGreen.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (action.icon != null) ...[
                        Icon(
                          action.icon,
                          size: 14,
                          color: GoogleTheme.googleGreen,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        action.text,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: GoogleTheme.googleGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          _formatTimestamp(message.timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: (isUser ? Colors.white : theme.colorScheme.onSurfaceVariant)
                .withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTypingIndicator() {
    if (!_isTyping) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GoogleTheme.googleGreen,
                  GoogleTheme.ndisTeal,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Enhanced typing animation with glassmorphism
          AdvancedGlassmorphism2025.buildUltraGlassContainer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NDIS Assistant is thinking',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: GoogleTheme.googleGreen,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 8),
                  // Animated thinking dots
                  ...List.generate(3, (final index) => AnimatedContainer(
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: GoogleTheme.googleGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    )),
                ],
              ),
            ),
            borderRadius: BorderRadius.circular(20),
            backgroundColor: GoogleTheme.googleGreen,
            blurIntensity: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceFirstInputInterface(final BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Enhanced voice interface
          Trending2025Components.buildVoiceInterface(
            context: context,
            isListening: _isVoiceInputActive,
            onVoiceToggle: _toggleVoiceInput,
            transcribedText:
                _isVoiceInputActive ? 'Listening for your voice...' : null,
            isAccessible: true,
          ),

          const SizedBox(height: 16),

          // Traditional text input with voice priority design
          ChatInputField(
            onSendMessage: _sendMessage,
            onVoiceInput: _toggleVoiceInput,
            isVoiceInputActive: _isVoiceInputActive,
            isLoading: _isLoading,
            suggestions: _quickSuggestions,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSuggestionChip(
      final String label, final IconData icon, final Color color) => GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _handleQuickAction(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

  String _formatTimestamp(final DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${timestamp.day}/${timestamp.month}';
  }

  Animation<double>? _createMessageAnimation(final int index) {
    // Animate only the last few messages for performance
    if (index >= _messages.length - 3) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: _messageController,
        curve: Curves.easeOut,
      ));
    }
    return null;
  }

  Future<void> _sendMessage(final String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      isUser: true,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.forward().then((_) {
      _messageController.reset();
      _scrollToBottom();
    });

    // Show typing indicator
    setState(() => _isTyping = true);

    try {
      // Simulate AI response delay
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Generate enhanced AI response
      final aiResponse = _generateEnhancedAIResponse(text);

      setState(() {
        _isTyping = false;
        _messages.add(aiResponse);
        _isLoading = false;
      });

      _messageController.forward().then((_) {
        _messageController.reset();
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _isLoading = false;
      });

      _showErrorMessage('Sorry, I encountered an error. Please try again.');
    }
  }

  ChatMessage _generateEnhancedAIResponse(final String userText) {
    final lowerText = userText.toLowerCase();

    String response;
    List<QuickAction> actions = [];

    // Update conversation context for cinematic storytelling
    _updateConversationContext(lowerText);
    _conversationDepth++;

    // Enhanced emotional intelligence in responses
    if (lowerText.contains('budget') ||
        lowerText.contains('money') ||
        lowerText.contains('funding')) {
      _currentConversationTopic = 'budget management';
      response = _conversationDepth > 2
          ? 'I notice we\'ve been discussing budget management. You have \$18,400 remaining (74% of your plan). Your spending pattern shows you\'re very responsible! 🌟 Your Core Supports are 70% used, which is perfect pacing. Any specific budget concerns I can help address?'
          : r'Based on your current NDIS plan, you have $18,400 remaining across all categories. Your Core Supports budget is 70% utilized, which shows excellent financial planning! Would you like a detailed breakdown or help tracking a new expense?';

      actions = [
        QuickAction(
          text: 'Budget Breakdown',
          icon: Icons.pie_chart,
          onTap: () => Navigator.pushNamed(context, '/budget'),
        ),
        QuickAction(
          text: 'Add Expense',
          icon: Icons.add_circle,
          onTap: () =>
              _handleQuickAction('Help me add a new expense to my budget'),
        ),
        QuickAction(
          text: 'Spending Insights',
          icon: Icons.insights,
          onTap: () =>
              _handleQuickAction('Show me insights about my spending patterns'),
        ),
      ];
    } else if (lowerText.contains('appointment') ||
        lowerText.contains('book') ||
        lowerText.contains('session')) {
      _currentConversationTopic = 'healthcare appointments';
      response =
          'Perfect! I can help you book healthcare appointments. You have 3 upcoming sessions this week - you\'re doing amazing with consistency! 🎯 I can check availability with your preferred providers for physiotherapy, OT, or support services. What type of session would you like?';

      actions = [
        QuickAction(
          text: 'Book Physiotherapy',
          icon: Icons.healing,
          onTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
        QuickAction(
          text: 'Book OT Session',
          icon: Icons.accessibility,
          onTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
        QuickAction(
          text: 'View Schedule',
          icon: Icons.calendar_today,
          onTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
      ];
    } else if (lowerText.contains('emergency') ||
        lowerText.contains('help') ||
        lowerText.contains('urgent')) {
      _currentConversationTopic = 'emergency assistance';
      response =
          'I\'m here to help! For emergencies, I can quickly connect you to:\n• Your primary emergency contact: Sarah Johnson (0412 345 678)\n• Support Coordinator: Active Care Solutions\n• Medical Emergency: 000\n\nWhat type of assistance do you need right now?';

      actions = [
        QuickAction(
          text: 'Call Emergency Contact',
          icon: Icons.phone,
          onTap: () => _handleEmergencyCall('primary'),
        ),
        QuickAction(
          text: 'Call Support Coordinator',
          icon: Icons.support_agent,
          onTap: () => _handleEmergencyCall('coordinator'),
        ),
        QuickAction(
          text: 'Medical Emergency',
          icon: Icons.local_hospital,
          onTap: () => _handleEmergencyCall('medical'),
        ),
      ];
    } else if (lowerText.contains('health') ||
        lowerText.contains('goal') ||
        lowerText.contains('progress')) {
      _currentConversationTopic = 'health progress';
      response =
          'Your health journey is inspiring! 💪 You\'ve completed 8 out of 12 planned goals this period (67% completion rate). Your appointment attendance is excellent at 94%. Your physiotherapy progress shows consistent improvement. What aspect of your health goals would you like to explore?';

      actions = [
        QuickAction(
          text: 'Goal Progress',
          icon: Icons.timeline,
          onTap: () => Navigator.pushNamed(context, '/checklist'),
        ),
        QuickAction(
          text: 'Health Metrics',
          icon: Icons.monitor_heart,
          onTap: () =>
              _handleQuickAction('Show my detailed health progress metrics'),
        ),
        QuickAction(
          text: 'Next Steps',
          icon: Icons.next_plan,
          onTap: () => _handleQuickAction(
              'What should I focus on next for my health goals?'),
        ),
      ];
    } else if (lowerText.contains('medication') ||
        lowerText.contains('medicine') ||
        lowerText.contains('reminder')) {
      _currentConversationTopic = 'medication management';
      response =
          'I can help you set up medication reminders and track your prescriptions. For NDIS participants, medication management is crucial for maintaining independence. Would you like me to help set up reminders or track medication effects on your daily goals?';

      actions = [
        QuickAction(
          text: 'Set Reminder',
          icon: Icons.alarm,
          onTap: () => _handleQuickAction('Set up a medication reminder'),
        ),
        QuickAction(
          text: 'Track Effects',
          icon: Icons.analytics,
          onTap: () => _handleQuickAction(
              'Help me track how medication affects my daily activities'),
        ),
        QuickAction(
          text: 'Contact Doctor',
          icon: Icons.medical_services,
          onTap: () => _handleQuickAction(
              'I need to contact my doctor about medication'),
        ),
      ];
    } else {
      response = _generateContextualResponse(userText);
      actions = [
        QuickAction(
          text: 'Budget Help',
          icon: Icons.account_balance_wallet,
          onTap: () => _handleQuickAction('Help me understand my budget'),
        ),
        QuickAction(
          text: 'Health Support',
          icon: Icons.favorite,
          onTap: () => _handleQuickAction('I need help with my health goals'),
        ),
        QuickAction(
          text: 'Emergency',
          icon: Icons.emergency,
          onTap: () =>
              _handleQuickAction('I need emergency contact assistance'),
        ),
      ];
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: response,
      timestamp: DateTime.now(),
      isUser: false,
      quickActions: actions,
    );
  }

  String _generateContextualResponse(final String userText) {
    final encouragingResponses = [
      'I\'m here to support your NDIS journey every step of the way! 🌟',
      'You\'re doing great managing your NDIS plan - I\'m proud of your progress! 💪',
      'Every question helps you become more independent. That\'s wonderful! ✨',
      'Your engagement with your NDIS plan is inspiring to see! 🎯',
    ];

    final randomEncouragement = encouragingResponses[
        DateTime.now().millisecond % encouragingResponses.length];

    return 'I understand you\'re asking about "$userText". $randomEncouragement I\'m equipped to help with NDIS plans, appointments, budgets, health goals, emergency contacts, and emotional support. What would you like to explore together?';
  }

  void _updateConversationContext(final String text) {
    if (text.contains('budget') || text.contains('money')) {
      _currentConversationTopic = 'budget management';
    } else if (text.contains('health') || text.contains('goal')) {
      _currentConversationTopic = 'health progress';
    } else if (text.contains('emergency') || text.contains('help')) {
      _currentConversationTopic = 'emergency assistance';
    } else if (text.contains('appointment') || text.contains('book')) {
      _currentConversationTopic = 'appointment booking';
    }
  }

  void _handleEmergencyCall(final String type) {
    String message;
    switch (type) {
      case 'primary':
        message =
            'Calling your emergency contact: Sarah Johnson (0412 345 678)';
        break;
      case 'coordinator':
        message =
            'Calling your support coordinator: Active Care Solutions (1800 SUPPORT)';
        break;
      case 'medical':
        message = 'Calling emergency services: 000';
        break;
      default:
        message = 'Initiating emergency call';
    }

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GoogleTheme.googleRed,
      ),
    );
  }

  void _handleQuickAction(final String action) {
    _sendMessage(action);
  }

  void _handleMessageTap(final ChatMessage message) {
    if (!message.isUser && message.quickActions.isNotEmpty) {
      // Show quick actions in a bottom sheet
      _showQuickActionsSheet(message.quickActions);
    }
  }

  void _showQuickActionsSheet(final List<QuickAction> actions) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (final context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...actions.map((final action) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: EnhancedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    action.onTap();
                  },
                  isSecondary: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (action.icon != null) ...[
                        Icon(action.icon, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(action.text),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _toggleVoiceInput() {
    setState(() => _isVoiceInputActive = !_isVoiceInputActive);

    if (_isVoiceInputActive) {
      _startVoiceInput();
    } else {
      _stopVoiceInput();
    }
  }

  Future<void> _startVoiceInput() async {
    HapticFeedback.lightImpact();

    try {
      // TODO: Implement actual speech-to-text
      await Future<void>.delayed(const Duration(seconds: 3));

      // Mock voice input result
      const voiceText = 'What is my budget status?';
      _sendMessage(voiceText);

      setState(() => _isVoiceInputActive = false);
    } catch (e) {
      setState(() => _isVoiceInputActive = false);
      _showErrorMessage('Voice input failed. Please try again.');
    }
  }

  void _stopVoiceInput() {
    setState(() => _isVoiceInputActive = false);
    HapticFeedback.lightImpact();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showErrorMessage(final String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: GoogleTheme.googleRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEnhancedChatSettings() {
    showDialog<void>(
      context: context,
      builder: (final context) => AdvancedGlassmorphism2025.buildGlassModalOverlay(
        context: context,
        child: _buildEnhancedChatSettingsDialog(),
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEnhancedChatSettingsDialog() => Container(
      width: 500,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeoBrutalismComponents.buildStrikingHeader(
            context: context,
            title: 'AI Assistant Settings',
            subtitle: 'Customize your chat experience',
            backgroundColor: GoogleTheme.ndisTeal,
          ),

          const SizedBox(height: 24),

          // Enhanced settings with better UX
          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Voice Input & Recognition',
            content:
                'Advanced speech-to-text with NDIS terminology understanding',
            icon: Icons.mic,
            accentColor: GoogleTheme.googleBlue,
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Proactive NDIS Assistance',
            content:
                'Smart reminders for appointments, deadlines, and opportunities',
            icon: Icons.notifications_active,
            accentColor: GoogleTheme.googleGreen,
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Emotional Intelligence',
            content: 'Supportive responses that understand your NDIS journey',
            icon: Icons.psychology,
            accentColor: GoogleTheme.ndisPurple,
          ),

          const SizedBox(height: 12),

          Trending2025Components.buildAccessibleInfoCard(
            context: context,
            title: 'Privacy & Security',
            content: 'Your conversations are private and NDIS-compliant',
            icon: Icons.security,
            accentColor: GoogleTheme.googleYellow,
          ),

          const SizedBox(height: 24),

          // Enhanced action buttons
          Row(
            children: [
              Expanded(
                child: Trending2025Components.buildInteractiveButton(
                  label: 'Reset Chat',
                  onPressed: _clearChat,
                  isPrimary: false,
                  backgroundColor: GoogleTheme.googleRed,
                  icon: Icons.refresh,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Trending2025Components.buildInteractiveButton(
                  label: 'Done',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: GoogleTheme.ndisTeal,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ],
      ),
    );

  void _clearChat() {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('New Conversation'),
        content: const Text(
            'This will clear the current conversation and start fresh. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          EnhancedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(_messages.clear);
              _addWelcomeMessage();
              HapticFeedback.lightImpact();
            },
            child: const Text('Start Fresh'),
          ),
        ],
      ),
    );
  }
}
