import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'ai_chat_service.dart';

/// Advanced Voice Control Service with comprehensive voice recognition,
/// text-to-speech, and accessibility features
class AdvancedVoiceService {
  static final AdvancedVoiceService _instance =
      AdvancedVoiceService._internal();
  factory AdvancedVoiceService() => _instance;
  AdvancedVoiceService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final AIChatService _aiChatService = AIChatService();

  // Speech recognition
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _voiceControlEnabled = false;

  // Voice settings
  String _currentLanguage = 'en-US';
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  double _speechVolume = 1.0;

  // Voice commands and navigation
  final Map<String, VoiceCommand> _voiceCommands = {};
  final List<VoiceNavigationRule> _navigationRules = [];
  final List<VoiceShortcut> _voiceShortcuts = [];

  // Voice recognition patterns
  // Voice patterns and actions (reserved for future use)
  // final Map<String, List<String>> _voicePatterns = {};
  // final Map<String, VoiceAction> _voiceActions = {};

  // Accessibility features
  bool _continuousListening = false;
  bool _voiceFeedback = true;
  bool _gestureRecognition = false;
  bool _eyeTracking = false;

  // Performance tracking
  final Map<String, VoiceMetric> _voiceMetrics = {};
  final List<VoiceEvent> _voiceEvents = [];

  /// Initialize the advanced voice service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Initialize speech recognition
      await _initializeSpeechRecognition();

      // Initialize text-to-speech
      await _initializeTextToSpeech();

      // Load voice settings
      await _loadVoiceSettings();

      // Initialize voice commands
      await _initializeVoiceCommands();

      // Initialize navigation rules
      await _initializeNavigationRules();

      // Initialize voice shortcuts
      await _initializeVoiceShortcuts();

      _isInitialized = true;

      await _analytics
          .logEvent('advanced_voice_service_initialized', parameters: {
        'language': _currentLanguage,
        'voice_commands': _voiceCommands.length,
        'navigation_rules': _navigationRules.length,
        'voice_shortcuts': _voiceShortcuts.length,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Advanced voice service initialization failed: $e',
        context: 'advanced_voice_service',
      );
      rethrow;
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    // Request microphone permission
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus != PermissionStatus.granted) {
      throw Exception('Microphone permission required for voice control');
    }

    // Request speech recognition permission
    final speechStatus = await Permission.speech.request();
    if (speechStatus != PermissionStatus.granted) {
      throw Exception('Speech recognition permission required');
    }
  }

  /// Initialize speech recognition
  Future<void> _initializeSpeechRecognition() async {
    final available = await _speechToText.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
    );

    if (!available) {
      throw Exception('Speech recognition not available');
    }
  }

  /// Initialize text-to-speech
  Future<void> _initializeTextToSpeech() async {
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_speechPitch);
    await _flutterTts.setVolume(_speechVolume);

    // Set up TTS callbacks
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _logVoiceEvent(VoiceEvent(
        type: VoiceEventType.ttsStart,
        details: {'language': _currentLanguage},
      ));
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _logVoiceEvent(VoiceEvent(
        type: VoiceEventType.ttsComplete,
        details: {},
      ));
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      _logVoiceEvent(VoiceEvent(
        type: VoiceEventType.ttsError,
        details: {'error': msg},
      ));
    });
  }

  /// Load voice settings from storage
  Future<void> _loadVoiceSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _currentLanguage = prefs.getString('voice_language') ?? 'en-US';
    _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
    _speechPitch = prefs.getDouble('speech_pitch') ?? 1.0;
    _speechVolume = prefs.getDouble('speech_volume') ?? 1.0;
    _voiceControlEnabled = prefs.getBool('voice_control_enabled') ?? false;
    _continuousListening = prefs.getBool('continuous_listening') ?? false;
    _voiceFeedback = prefs.getBool('voice_feedback') ?? true;
    _gestureRecognition = prefs.getBool('gesture_recognition') ?? false;
    _eyeTracking = prefs.getBool('eye_tracking') ?? false;
  }

  /// Save voice settings to storage
  Future<void> _saveVoiceSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('voice_language', _currentLanguage);
    await prefs.setDouble('speech_rate', _speechRate);
    await prefs.setDouble('speech_pitch', _speechPitch);
    await prefs.setDouble('speech_volume', _speechVolume);
    await prefs.setBool('voice_control_enabled', _voiceControlEnabled);
    await prefs.setBool('continuous_listening', _continuousListening);
    await prefs.setBool('voice_feedback', _voiceFeedback);
    await prefs.setBool('gesture_recognition', _gestureRecognition);
    await prefs.setBool('eye_tracking', _eyeTracking);
  }

  /// Initialize voice commands
  Future<void> _initializeVoiceCommands() async {
    _voiceCommands.addAll({
      'navigate': VoiceCommand(
        id: 'navigate',
        patterns: ['go to', 'navigate to', 'open', 'show'],
        action: VoiceAction.navigate,
        description: 'Navigate to a specific screen or feature',
      ),
      'search': VoiceCommand(
        id: 'search',
        patterns: ['search for', 'find', 'look for'],
        action: VoiceAction.search,
        description: 'Search for content or information',
      ),
      'help': VoiceCommand(
        id: 'help',
        patterns: ['help', 'what can you do', 'commands'],
        action: VoiceAction.help,
        description: 'Get help and available commands',
      ),
      'settings': VoiceCommand(
        id: 'settings',
        patterns: ['settings', 'preferences', 'configure'],
        action: VoiceAction.settings,
        description: 'Open settings or preferences',
      ),
      'budget': VoiceCommand(
        id: 'budget',
        patterns: ['budget', 'funding', 'money', 'spending'],
        action: VoiceAction.budget,
        description: 'Access budget and funding information',
      ),
      'appointments': VoiceCommand(
        id: 'appointments',
        patterns: ['appointments', 'schedule', 'calendar'],
        action: VoiceAction.appointments,
        description: 'Access appointment and scheduling features',
      ),
      'providers': VoiceCommand(
        id: 'providers',
        patterns: ['providers', 'services', 'therapists'],
        action: VoiceAction.providers,
        description: 'Search for providers and services',
      ),
      'support': VoiceCommand(
        id: 'support',
        patterns: ['support', 'help me', 'assistance'],
        action: VoiceAction.support,
        description: 'Get support and assistance',
      ),
    });
  }

  /// Initialize navigation rules
  Future<void> _initializeNavigationRules() async {
    _navigationRules.addAll([
      VoiceNavigationRule(
        pattern: 'go to budget',
        action: 'navigate_to_budget',
        parameters: {'screen': 'budget'},
      ),
      VoiceNavigationRule(
        pattern: 'open calendar',
        action: 'navigate_to_calendar',
        parameters: {'screen': 'calendar'},
      ),
      VoiceNavigationRule(
        pattern: 'show providers',
        action: 'navigate_to_providers',
        parameters: {'screen': 'providers'},
      ),
      VoiceNavigationRule(
        pattern: 'access support circle',
        action: 'navigate_to_support_circle',
        parameters: {'screen': 'support_circle'},
      ),
    ]);
  }

  /// Initialize voice shortcuts
  Future<void> _initializeVoiceShortcuts() async {
    _voiceShortcuts.addAll([
      VoiceShortcut(
        id: 'quick_budget_check',
        phrase: 'check budget',
        action: 'quick_budget_check',
        description: 'Quickly check budget status',
      ),
      VoiceShortcut(
        id: 'next_appointment',
        phrase: 'next appointment',
        action: 'next_appointment',
        description: 'Get next appointment information',
      ),
      VoiceShortcut(
        id: 'emergency_contact',
        phrase: 'emergency',
        action: 'emergency_contact',
        description: 'Access emergency contacts',
      ),
      VoiceShortcut(
        id: 'voice_help',
        phrase: 'voice help',
        action: 'voice_help',
        description: 'Get voice control help',
      ),
    ]);
  }

  /// Start voice recognition
  Future<void> startListening({bool continuous = false}) async {
    if (!_isInitialized) await initialize();
    if (_isListening) return;

    try {
      final available = await _speechToText.initialize();
      if (!available) {
        throw Exception('Speech recognition not available');
      }

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: continuous
            ? const Duration(minutes: 10)
            : const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: _currentLanguage,
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: false,
        listenMode: continuous ? ListenMode.confirmation : ListenMode.dictation,
      );

      _isListening = true;
      _continuousListening = continuous;

      _logVoiceEvent(VoiceEvent(
        type: VoiceEventType.listeningStart,
        details: {
          'continuous': continuous,
          'language': _currentLanguage,
        },
      ));
    } catch (e) {
      await _analytics.logError(
        error: 'Voice listening failed: $e',
        context: 'advanced_voice_service',
      );
      rethrow;
    }
  }

  /// Stop voice recognition
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
    _continuousListening = false;

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.listeningStop,
      details: {},
    ));
  }

  /// Speak text using text-to-speech
  Future<void> speak(String text, {bool interrupt = false}) async {
    if (!_isInitialized) await initialize();

    if (interrupt && _isSpeaking) {
      await _flutterTts.stop();
    }

    if (_isSpeaking && !interrupt) return;

    try {
      await _flutterTts.speak(text);

      _logVoiceEvent(VoiceEvent(
        type: VoiceEventType.ttsStart,
        details: {
          'text_length': text.length,
          'interrupt': interrupt,
        },
      ));
    } catch (e) {
      await _analytics.logError(
        error: 'TTS speech failed: $e',
        context: 'advanced_voice_service',
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

  /// Process voice command
  Future<void> processVoiceCommand(String command) async {
    try {
      final normalizedCommand = command.toLowerCase().trim();

      // Check for exact voice shortcuts first
      for (final shortcut in _voiceShortcuts) {
        if (normalizedCommand.contains(shortcut.phrase.toLowerCase())) {
          await _executeVoiceAction(shortcut.action, {});
          return;
        }
      }

      // Check for navigation rules
      for (final rule in _navigationRules) {
        if (normalizedCommand.contains(rule.pattern.toLowerCase())) {
          await _executeVoiceAction(rule.action, rule.parameters);
          return;
        }
      }

      // Check for voice commands
      for (final voiceCommand in _voiceCommands.values) {
        for (final pattern in voiceCommand.patterns) {
          if (normalizedCommand.contains(pattern.toLowerCase())) {
            await _executeVoiceAction(voiceCommand.action.name, {});
            return;
          }
        }
      }

      // If no specific command found, try AI chat
      if (_voiceControlEnabled) {
        final response =
            await _aiChatService.processMessage(command, isVoice: true);
        if (_voiceFeedback) {
          await speak(response.text);
        }
      }
    } catch (e) {
      await _analytics.logError(
        error: 'Voice command processing failed: $e',
        context: 'advanced_voice_service',
      );

      if (_voiceFeedback) {
        await speak(
            "I'm sorry, I didn't understand that command. Please try again.");
      }
    }
  }

  /// Execute voice action
  Future<void> _executeVoiceAction(
      String action, Map<String, dynamic> parameters) async {
    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.actionExecuted,
      details: {
        'action': action,
        'parameters': parameters,
      },
    ));

    // Implementation would execute the specific action
    // This would integrate with the app's navigation and feature system
    switch (action) {
      case 'navigate_to_budget':
        // Navigate to budget screen
        break;
      case 'navigate_to_calendar':
        // Navigate to calendar screen
        break;
      case 'quick_budget_check':
        // Perform quick budget check
        break;
      case 'next_appointment':
        // Get next appointment
        break;
      case 'emergency_contact':
        // Access emergency contacts
        break;
      case 'voice_help':
        // Show voice help
        break;
    }
  }

  /// Enable voice control
  Future<void> enableVoiceControl() async {
    _voiceControlEnabled = true;
    await _saveVoiceSettings();

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.voiceControlEnabled,
      details: {},
    ));

    if (_voiceFeedback) {
      await speak(
          "Voice control enabled. You can now use voice commands to navigate the app.");
    }
  }

  /// Disable voice control
  Future<void> disableVoiceControl() async {
    _voiceControlEnabled = false;
    await _saveVoiceSettings();

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.voiceControlDisabled,
      details: {},
    ));
  }

  /// Set voice language
  Future<void> setVoiceLanguage(String language) async {
    _currentLanguage = language;
    await _flutterTts.setLanguage(language);
    await _saveVoiceSettings();

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.languageChanged,
      details: {'language': language},
    ));
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 2.0);
    await _flutterTts.setSpeechRate(_speechRate);
    await _saveVoiceSettings();
  }

  /// Set speech pitch
  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_speechPitch);
    await _saveVoiceSettings();
  }

  /// Set speech volume
  Future<void> setSpeechVolume(double volume) async {
    _speechVolume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_speechVolume);
    await _saveVoiceSettings();
  }

  /// Add custom voice command
  Future<void> addCustomVoiceCommand(VoiceCommand command) async {
    _voiceCommands[command.id] = command;

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.customCommandAdded,
      details: {
        'command_id': command.id,
        'patterns': command.patterns,
      },
    ));
  }

  /// Add custom voice shortcut
  Future<void> addCustomVoiceShortcut(VoiceShortcut shortcut) async {
    _voiceShortcuts.add(shortcut);

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.customShortcutAdded,
      details: {
        'shortcut_id': shortcut.id,
        'phrase': shortcut.phrase,
      },
    ));
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    final languages = await _speechToText.locales();
    return languages.map((locale) => locale.localeId).toList();
  }

  /// Get voice metrics
  Map<String, VoiceMetric> getVoiceMetrics() {
    return Map.unmodifiable(_voiceMetrics);
  }

  /// Get voice events
  List<VoiceEvent> getVoiceEvents() {
    return List.unmodifiable(_voiceEvents);
  }

  /// Speech recognition callbacks
  void _onSpeechResult(dynamic result) {
    try {
      final recognizedText = result.recognizedWords as String? ?? '';
      final confidence = (result.confidence as double?) ?? 0.0;

      _logVoiceEvent(VoiceEvent(
        type: VoiceEventType.speechRecognized,
        details: {
          'text': recognizedText,
          'confidence': confidence,
        },
      ));

      // Process the recognized speech
      if (recognizedText.isNotEmpty) {
        processVoiceCommand(recognizedText);
      }
    } catch (e) {
      _analytics.logError(
        error: 'Speech result processing failed: $e',
        context: 'advanced_voice_service',
      );
    }
  }

  void _onSpeechError(dynamic error) {
    _isListening = false;

    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.speechError,
      details: {'error': error.toString()},
    ));

    _analytics.logError(
      error: 'Speech recognition error: $error',
      context: 'advanced_voice_service',
    );
  }

  void _onSpeechStatus(dynamic status) {
    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.speechStatusChanged,
      details: {'status': status.toString()},
    ));
  }

  void _onSoundLevelChange(dynamic level) {
    _logVoiceEvent(VoiceEvent(
      type: VoiceEventType.soundLevelChanged,
      details: {'level': level.toString()},
    ));
  }

  /// Log voice event
  void _logVoiceEvent(VoiceEvent event) {
    _voiceEvents.add(event);

    // Keep only last 100 events in memory
    if (_voiceEvents.length > 100) {
      _voiceEvents.removeAt(0);
    }

    // Update metrics
    _updateVoiceMetrics(event);
  }

  /// Update voice metrics
  void _updateVoiceMetrics(VoiceEvent event) {
    final metricKey = '${event.type.name}_count';
    final metric = _voiceMetrics.putIfAbsent(
      metricKey,
      () => VoiceMetric(
        name: metricKey,
        count: 0,
        lastUpdated: DateTime.now(),
      ),
    );

    metric.count++;
    metric.lastUpdated = DateTime.now();
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get voiceControlEnabled => _voiceControlEnabled;
  String get currentLanguage => _currentLanguage;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  double get speechVolume => _speechVolume;
  bool get continuousListening => _continuousListening;
  bool get voiceFeedback => _voiceFeedback;
  Map<String, VoiceCommand> get voiceCommands =>
      Map.unmodifiable(_voiceCommands);
  List<VoiceShortcut> get voiceShortcuts => List.unmodifiable(_voiceShortcuts);
}

/// Voice command model
class VoiceCommand {
  final String id;
  final List<String> patterns;
  final VoiceAction action;
  final String description;

  VoiceCommand({
    required this.id,
    required this.patterns,
    required this.action,
    required this.description,
  });
}

/// Voice action enum
enum VoiceAction {
  navigate,
  search,
  help,
  settings,
  budget,
  appointments,
  providers,
  support,
}

/// Voice navigation rule model
class VoiceNavigationRule {
  final String pattern;
  final String action;
  final Map<String, dynamic> parameters;

  VoiceNavigationRule({
    required this.pattern,
    required this.action,
    required this.parameters,
  });
}

/// Voice shortcut model
class VoiceShortcut {
  final String id;
  final String phrase;
  final String action;
  final String description;

  VoiceShortcut({
    required this.id,
    required this.phrase,
    required this.action,
    required this.description,
  });
}

/// Voice event model
class VoiceEvent {
  final VoiceEventType type;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  VoiceEvent({
    required this.type,
    required this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Voice event type enum
enum VoiceEventType {
  listeningStart,
  listeningStop,
  speechRecognized,
  speechComplete,
  speechError,
  speechStatusChanged,
  soundLevelChanged,
  ttsStart,
  ttsComplete,
  ttsError,
  actionExecuted,
  voiceControlEnabled,
  voiceControlDisabled,
  languageChanged,
  customCommandAdded,
  customShortcutAdded,
}

/// Voice metric model
class VoiceMetric {
  final String name;
  int count;
  DateTime lastUpdated;

  VoiceMetric({
    required this.name,
    required this.count,
    required this.lastUpdated,
  });
}
