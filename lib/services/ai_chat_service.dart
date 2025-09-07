import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import '../config/api_config.dart';

/// Advanced AI Chat Service with Dialogflow integration, voice recognition,
/// natural language processing, and intelligent NDIS assistance
class AIChatService {
  static const String _dialogflowEndpoint =
      String.fromEnvironment('DIALOGFLOW_ENDPOINT');
  static const String _dialogflowAuth =
      String.fromEnvironment('DIALOGFLOW_AUTH');

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  // Language model manager placeholder - would be implemented based on specific AI service
  // final LanguageModelManager _languageModelManager = LanguageModelManager();
  final AnalyticsService _analytics = AnalyticsService();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  final String _currentLanguage = 'en-US';
  String _sessionId = '';

  // Conversation context and memory
  final List<ChatMessage> _conversationHistory = [];
  final Map<String, dynamic> _userContext = {};
  final Map<String, dynamic> _ndisKnowledgeBase = {};

  // Voice settings
  final double _speechRate = 0.5;
  final double _speechPitch = 1.0;
  final double _speechVolume = 1.0;

  /// Initialize the AI chat service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize speech recognition
      await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      // Initialize text-to-speech
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_speechPitch);
      await _flutterTts.setVolume(_speechVolume);

      // Set up TTS callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _analytics.logError(
            error: 'TTS Error: $msg', context: 'ai_chat_service');
      });

      // Generate session ID
      _sessionId = _generateSessionId();

      // Initialize conversation history
      await _initializeConversationHistory();

      // Load user context and preferences
      await _loadUserContext();

      // Initialize NDIS knowledge base
      await _initializeKnowledgeBase();

      _isInitialized = true;

      await _analytics.logEvent('ai_chat_initialized', parameters: {
        'session_id': _sessionId,
        'language': _currentLanguage,
        'gemini_enabled': ApiConfig.isAIEnabled(),
      });
    } catch (e) {
      await _analytics.logError(
        error: 'AI Chat initialization failed: $e',
        context: 'ai_chat_service',
      );
      rethrow;
    }
  }

  /// Process a text message with AI intelligence
  Future<ChatResponse> processMessage(String message,
      {bool isVoice = false}) async {
    if (!_isInitialized) await initialize();

    try {
      // Add user message to conversation history
      final userMessage = ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
        isVoice: isVoice,
      );
      _conversationHistory.add(userMessage);

      // Log the interaction
      await _analytics.logEvent('ai_chat_message', parameters: {
        'message_length': message.length,
        'is_voice': isVoice,
        'session_id': _sessionId,
      });

      // Process with Gemini AI if available, otherwise use local AI
      ChatResponse response;
      if (ApiConfig.isAIEnabled()) {
        response = await _processWithGemini(message);
      } else {
        response = await _processWithLocalAI(message);
      }

      // Add AI response to conversation history
      final aiMessage = ChatMessage(
        text: response.text,
        isUser: false,
        timestamp: DateTime.now(),
        isVoice: false,
        intent: response.intent,
        confidence: response.confidence,
        suggestions: response.suggestions,
      );
      _conversationHistory.add(aiMessage);

      // Update user context based on response
      await _updateUserContext(response);

      // Save conversation history
      await _saveConversationHistory();

      return response;
    } catch (e) {
      await _analytics.logError(
        error: 'Message processing failed: $e',
        context: 'ai_chat_service',
      );

      // Return fallback response
      return ChatResponse(
        text:
            "I'm sorry, I'm having trouble processing your request right now. Please try again or contact support if the issue persists.",
        intent: 'error',
        confidence: 0.0,
        suggestions: ['Try again', 'Contact support', 'Browse help topics'],
      );
    }
  }

  /// Start voice recognition
  Future<void> startListening() async {
    if (!_isInitialized) await initialize();
    if (_isListening) return;

    try {
      final available = await _speechToText.initialize();
      if (!available) {
        throw Exception('Speech recognition not available');
      }

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: _currentLanguage,
        onSoundLevelChange: _onSoundLevelChange,
      );

      _isListening = true;

      await _analytics.logEvent('voice_listening_started', parameters: {
        'language': _currentLanguage,
        'session_id': _sessionId,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Voice listening failed: $e',
        context: 'ai_chat_service',
      );
      rethrow;
    }
  }

  /// Stop voice recognition
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;

    await _analytics.logEvent('voice_listening_stopped', parameters: {
      'session_id': _sessionId,
    });
  }

  /// Speak text using text-to-speech
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (_isSpeaking) return;

    try {
      await _flutterTts.speak(text);

      await _analytics.logEvent('tts_speech_started', parameters: {
        'text_length': text.length,
        'session_id': _sessionId,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'TTS speech failed: $e',
        context: 'ai_chat_service',
      );
      rethrow;
    }
  }

  /// Stop text-to-speech
  Future<void> stopSpeaking() async {
    if (!_isSpeaking) return;

    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// Get conversation history
  List<ChatMessage> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  /// Clear conversation history
  Future<void> clearHistory() async {
    _conversationHistory.clear();
    await _saveConversationHistory();

    await _analytics.logEvent('conversation_cleared', parameters: {
      'session_id': _sessionId,
    });
  }

  /// Get smart suggestions based on context
  Future<List<String>> getSmartSuggestions() async {
    if (_conversationHistory.isEmpty) {
      return [
        "How much funding do I have left?",
        "Book an appointment",
        "Find providers near me",
        "Check my budget status",
      ];
    }

    // Analyze recent conversation for context-aware suggestions
    final recentMessages = _conversationHistory.length > 3
        ? _conversationHistory.sublist(_conversationHistory.length - 3)
        : _conversationHistory;
    final lastIntent = recentMessages
        .lastWhere(
          (msg) => !msg.isUser,
          orElse: () =>
              ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
        )
        .intent;

    switch (lastIntent) {
      case 'budget_query':
        return [
          "Show budget breakdown",
          "Set budget alerts",
          "View spending history",
          "Compare with last plan",
        ];
      case 'appointment_booking':
        return [
          "View my appointments",
          "Reschedule appointment",
          "Find similar providers",
          "Set appointment reminders",
        ];
      case 'provider_search':
        return [
          "Filter by accessibility",
          "Check availability",
          "Read reviews",
          "Get directions",
        ];
      default:
        return [
          "What can you help me with?",
          "Show my dashboard",
          "Find support resources",
          "Check notifications",
        ];
    }
  }

  /// Process message with Gemini AI
  Future<ChatResponse> _processWithGemini(String message) async {
    try {
      if (!ApiConfig.isAIEnabled()) {
        throw Exception('Gemini AI not enabled');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.geminiGenerateContentEndpoint),
        headers: ApiConfig.geminiHeaders,
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': _buildGeminiPrompt(message),
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;

          if (parts != null && parts.isNotEmpty) {
            final text =
                parts[0]['text'] as String? ?? 'I understand your request.';

            // Extract intent and confidence from the response
            final intent = _classifyIntent(message.toLowerCase());
            final confidence =
                _calculateConfidence(message.toLowerCase(), intent);

            return ChatResponse(
              text: text,
              intent: intent,
              confidence: confidence,
              suggestions: await _generateSuggestionsFromResponse(text, intent),
              entities: _extractEntitiesFromMessage(message),
            );
          }
        }

        throw Exception('Invalid Gemini response format');
      } else {
        throw Exception(
            'Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      await _analytics.logError(
        error: 'Gemini AI processing failed: $e',
        context: 'ai_chat_service',
      );
      // Fallback to local AI processing
      return await _processWithLocalAI(message);
    }
  }

  /// Build context-aware prompt for Gemini
  String _buildGeminiPrompt(String message) {
    final context = _userContext.isNotEmpty
        ? 'User context: ${jsonEncode(_userContext)}\n'
        : '';

    final conversationHistory = _conversationHistory.length > 3
        ? _conversationHistory
            .sublist(_conversationHistory.length - 3)
            .map((msg) => '${msg.isUser ? "User" : "Assistant"}: ${msg.text}')
            .join('\n')
        : '';

    final history = conversationHistory.isNotEmpty
        ? 'Recent conversation:\n$conversationHistory\n'
        : '';

    return '''You are an AI assistant for NDIS Connect, a comprehensive app for NDIS participants and providers. You help users with:

- Budget tracking and funding management
- Appointment booking and scheduling
- Finding providers and services
- Support circle coordination
- Answering NDIS-related questions
- Accessibility and inclusion support

$context$history
User message: $message

Please provide a helpful, accurate, and empathetic response. Focus on NDIS-related assistance and be inclusive in your language. If the user asks about something outside NDIS scope, politely redirect them to NDIS-related topics you can help with.

Response:''';
  }

  /// Generate suggestions based on AI response
  Future<List<String>> _generateSuggestionsFromResponse(
      String response, String intent) async {
    // Use the existing smart suggestions logic
    return await getSmartSuggestions();
  }

  /// Extract entities from user message
  Map<String, dynamic> _extractEntitiesFromMessage(String message) {
    final query = message.toLowerCase();

    // Try to extract entities based on intent
    final intent = _classifyIntent(query);
    switch (intent) {
      case 'budget_query':
        return _extractBudgetEntities(query);
      case 'appointment_booking':
        return _extractAppointmentEntities(query);
      case 'provider_search':
        return _extractProviderEntities(query);
      default:
        return {};
    }
  }

  /// Process message with local AI and knowledge base
  Future<ChatResponse> _processWithLocalAI(String message) async {
    final query = message.toLowerCase();

    // Intent classification using pattern matching
    final intent = _classifyIntent(query);
    final confidence = _calculateConfidence(query, intent);

    // Generate response based on intent
    String responseText;
    List<String> suggestions;
    Map<String, dynamic> entities = {};

    switch (intent) {
      case 'budget_query':
        responseText = await _handleBudgetQuery(query);
        suggestions = [
          "Show detailed breakdown",
          "Set budget alerts",
          "View spending trends",
          "Compare with previous plans",
        ];
        entities = _extractBudgetEntities(query);
        break;

      case 'appointment_booking':
        responseText = await _handleAppointmentQuery(query);
        suggestions = [
          "View my appointments",
          "Find available times",
          "Book new appointment",
          "Set reminders",
        ];
        entities = _extractAppointmentEntities(query);
        break;

      case 'provider_search':
        responseText = await _handleProviderQuery(query);
        suggestions = [
          "Filter by location",
          "Check availability",
          "Read reviews",
          "Get contact info",
        ];
        entities = _extractProviderEntities(query);
        break;

      case 'support_request':
        responseText = await _handleSupportQuery(query);
        suggestions = [
          "Contact support coordinator",
          "Browse help topics",
          "Submit feedback",
          "Emergency contacts",
        ];
        break;

      case 'general_help':
        responseText = await _handleGeneralHelp(query);
        suggestions = [
          "Budget tracking",
          "Appointment booking",
          "Provider directory",
          "Support circle",
        ];
        break;

      default:
        responseText =
            "I understand you're looking for help. I can assist you with budget tracking, appointment booking, finding providers, or connecting you with support. What would you like to do?";
        suggestions = [
          "Budget help",
          "Book appointment",
          "Find providers",
          "Get support",
        ];
    }

    return ChatResponse(
      text: responseText,
      intent: intent,
      confidence: confidence,
      suggestions: suggestions,
      entities: entities,
    );
  }

  /// Classify user intent from message
  String _classifyIntent(String query) {
    // Budget-related queries
    if (query.contains(RegExp(
        r'\b(budget|funding|money|cost|price|spend|remaining|left)\b'))) {
      return 'budget_query';
    }

    // Appointment-related queries
    if (query.contains(
        RegExp(r'\b(book|appointment|schedule|session|meeting|visit)\b'))) {
      return 'appointment_booking';
    }

    // Provider-related queries
    if (query.contains(RegExp(
        r'\b(provider|therapist|doctor|service|find|search|near|location)\b'))) {
      return 'provider_search';
    }

    // Support-related queries
    if (query.contains(
        RegExp(r'\b(help|support|problem|issue|contact|emergency)\b'))) {
      return 'support_request';
    }

    // General help
    if (query.contains(RegExp(r'\b(what|how|can|do|help|assist)\b'))) {
      return 'general_help';
    }

    return 'general';
  }

  /// Calculate confidence score for intent classification
  double _calculateConfidence(String query, String intent) {
    // Simple confidence calculation based on keyword matches
    final keywords = _getIntentKeywords(intent);
    final matches = keywords.where((keyword) => query.contains(keyword)).length;
    return (matches / keywords.length).clamp(0.0, 1.0);
  }

  /// Get keywords for intent classification
  List<String> _getIntentKeywords(String intent) {
    switch (intent) {
      case 'budget_query':
        return ['budget', 'funding', 'money', 'cost', 'spend', 'remaining'];
      case 'appointment_booking':
        return ['book', 'appointment', 'schedule', 'session', 'meeting'];
      case 'provider_search':
        return ['provider', 'therapist', 'doctor', 'find', 'search', 'near'];
      case 'support_request':
        return ['help', 'support', 'problem', 'issue', 'contact'];
      default:
        return ['help', 'assist', 'what', 'how', 'can'];
    }
  }

  /// Handle budget-related queries
  Future<String> _handleBudgetQuery(String query) async {
    // This would integrate with the actual budget service
    if (query.contains('remaining') || query.contains('left')) {
      return "I can help you check your remaining NDIS funding. Let me open the Budget Tracker to show you the current status of your plan categories.";
    } else if (query.contains('spend') || query.contains('used')) {
      return "I'll show you your spending breakdown across all NDIS categories. You can see how much you've used and what's remaining in each area.";
    } else {
      return "I can help you with your NDIS budget. I can show you remaining funding, spending history, set up alerts, or help you understand your plan categories.";
    }
  }

  /// Handle appointment-related queries
  Future<String> _handleAppointmentQuery(String query) async {
    if (query.contains('book') || query.contains('schedule')) {
      return "I can help you book an appointment. Let me show you available times with your providers and help you schedule a session.";
    } else if (query.contains('upcoming') || query.contains('next')) {
      return "I'll show you your upcoming appointments. You can view details, reschedule, or set reminders for your sessions.";
    } else {
      return "I can help you with appointments - booking new ones, viewing your schedule, rescheduling, or setting reminders.";
    }
  }

  /// Handle provider-related queries
  Future<String> _handleProviderQuery(String query) async {
    if (query.contains('find') || query.contains('search')) {
      return "I can help you find NDIS providers in your area. I'll show you options based on your location, service needs, and accessibility requirements.";
    } else if (query.contains('near') || query.contains('location')) {
      return "Let me search for providers near your location. I'll filter by distance, availability, and accessibility features.";
    } else {
      return "I can help you find and connect with NDIS providers. I can search by location, service type, availability, and accessibility features.";
    }
  }

  /// Handle support-related queries
  Future<String> _handleSupportQuery(String query) async {
    if (query.contains('emergency')) {
      return "For emergencies, please contact emergency services (000) or your support coordinator immediately. I can also help you find emergency contacts in your area.";
    } else if (query.contains('problem') || query.contains('issue')) {
      return "I'm here to help resolve any issues. I can connect you with your support coordinator, help you find resources, or guide you through common solutions.";
    } else {
      return "I can help you get support in several ways - connecting with your support coordinator, finding resources, or helping you navigate NDIS processes.";
    }
  }

  /// Handle general help queries
  Future<String> _handleGeneralHelp(String query) async {
    return "I'm your NDIS Connect assistant! I can help you with:\n\n"
        "• Budget tracking and funding management\n"
        "• Booking and managing appointments\n"
        "• Finding providers and services\n"
        "• Support circle coordination\n"
        "• Answering NDIS questions\n\n"
        "What would you like help with today?";
  }

  /// Extract budget-related entities from query
  Map<String, dynamic> _extractBudgetEntities(String query) {
    final entities = <String, dynamic>{};

    // Extract amounts
    final amountRegex = RegExp(r'\$?(\d+(?:\.\d{2})?)');
    final amountMatch = amountRegex.firstMatch(query);
    if (amountMatch != null) {
      entities['amount'] = double.tryParse(amountMatch.group(1) ?? '');
    }

    // Extract categories
    final categories = ['core', 'capacity', 'capital'];
    for (final category in categories) {
      if (query.contains(category)) {
        entities['category'] = category;
        break;
      }
    }

    return entities;
  }

  /// Extract appointment-related entities from query
  Map<String, dynamic> _extractAppointmentEntities(String query) {
    final entities = <String, dynamic>{};

    // Extract time references
    if (query.contains('today')) entities['time'] = 'today';
    if (query.contains('tomorrow')) entities['time'] = 'tomorrow';
    if (query.contains('week')) entities['time'] = 'week';
    if (query.contains('month')) entities['time'] = 'month';

    // Extract service types
    final services = ['therapy', 'assessment', 'consultation', 'review'];
    for (final service in services) {
      if (query.contains(service)) {
        entities['service_type'] = service;
        break;
      }
    }

    return entities;
  }

  /// Extract provider-related entities from query
  Map<String, dynamic> _extractProviderEntities(String query) {
    final entities = <String, dynamic>{};

    // Extract provider types
    final types = [
      'therapist',
      'doctor',
      'nurse',
      'support worker',
      'coordinator'
    ];
    for (final type in types) {
      if (query.contains(type)) {
        entities['provider_type'] = type;
        break;
      }
    }

    // Extract service types
    final services = [
      'physiotherapy',
      'occupational therapy',
      'speech therapy',
      'psychology'
    ];
    for (final service in services) {
      if (query.contains(service)) {
        entities['service_type'] = service;
        break;
      }
    }

    return entities;
  }

  /// Initialize NDIS knowledge base
  Future<void> _initializeKnowledgeBase() async {
    _ndisKnowledgeBase.addAll({
      'categories': {
        'core': 'Daily living and personal care supports',
        'capacity': 'Skills development and training',
        'capital': 'Equipment and home modifications',
      },
      'common_services': [
        'Physiotherapy',
        'Occupational Therapy',
        'Speech Therapy',
        'Psychology',
        'Support Coordination',
        'Plan Management',
      ],
      'plan_review_cycle': '12 months',
      'budget_alerts': {
        'warning_threshold': 80,
        'critical_threshold': 95,
      },
    });
  }

  /// Load user context and preferences
  Future<void> _loadUserContext() async {
    final prefs = await SharedPreferences.getInstance();
    _userContext.addAll({
      'user_id': prefs.getString('user_id'),
      'role': prefs.getString('user_role'),
      'preferred_language': prefs.getString('preferred_language') ?? 'en-US',
      'accessibility_needs': prefs.getStringList('accessibility_needs') ?? [],
      'plan_categories': prefs.getStringList('plan_categories') ?? [],
    });
  }

  /// Update user context based on conversation
  Future<void> _updateUserContext(ChatResponse response) async {
    // Update context based on detected entities and intent
    if (response.entities.isNotEmpty) {
      _userContext.addAll(response.entities);
    }

    // Save updated context
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_context', jsonEncode(_userContext));
  }

  /// Save conversation history
  Future<void> _saveConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _conversationHistory.map((msg) => msg.toJson()).toList();
    await prefs.setString('conversation_history', jsonEncode(historyJson));
  }

  /// Load conversation history
  Future<void> _loadConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('conversation_history');
    if (historyJson != null) {
      final history = jsonDecode(historyJson) as List;
      _conversationHistory.clear();
      _conversationHistory.addAll(
        history.map((json) => ChatMessage.fromJson(json)).toList(),
      );
    }
  }

  /// Initialize conversation history on service start
  Future<void> _initializeConversationHistory() async {
    await _loadConversationHistory();
  }

  /// Generate unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'session_${timestamp}_$random';
  }

  /// Speech recognition callbacks
  void _onSpeechResult(dynamic result) {
    try {
      final recognizedText = result.recognizedWords as String? ?? '';
      if (recognizedText.isNotEmpty) {
        // Process the recognized speech
        processMessage(recognizedText, isVoice: true);
      }
    } catch (e) {
      _analytics.logError(
        error: 'Speech result processing failed: $e',
        context: 'ai_chat_service',
      );
    }
  }

  void _onSpeechError(dynamic error) {
    _analytics.logError(
      error: 'Speech recognition error: $error',
      context: 'ai_chat_service',
    );
  }

  void _onSpeechStatus(dynamic status) {
    // Handle speech recognition status changes
    // Could log status changes for debugging
  }

  void _onSoundLevelChange(dynamic level) {
    // Handle sound level changes for visual feedback
    // Could update UI with sound level indicator
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;
  String get sessionId => _sessionId;
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isVoice;
  final String? intent;
  final double? confidence;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isVoice = false,
    this.intent,
    this.confidence,
    this.suggestions,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isVoice': isVoice,
        'intent': intent,
        'confidence': confidence,
        'suggestions': suggestions,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
        isVoice: json['isVoice'] ?? false,
        intent: json['intent'],
        confidence: json['confidence']?.toDouble(),
        suggestions: json['suggestions']?.cast<String>(),
      );
}

/// Chat response model
class ChatResponse {
  final String text;
  final String intent;
  final double confidence;
  final List<String> suggestions;
  final Map<String, dynamic> entities;

  ChatResponse({
    required this.text,
    required this.intent,
    required this.confidence,
    this.suggestions = const [],
    this.entities = const {},
  });
}
