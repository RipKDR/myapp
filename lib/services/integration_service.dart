import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
// Removed unused imports for now; re-add when needed

/// Integration Service for third-party APIs, external systems,
/// and comprehensive ecosystem connectivity
class IntegrationService {
  factory IntegrationService() => _instance;
  IntegrationService._internal();
  static final IntegrationService _instance = IntegrationService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  // Services kept for future use; prefix with underscore but ignore lints by referencing where meaningful
  // Remove unused services to satisfy lints (can be reintroduced when needed)
  // final AdvancedCacheService _cacheService = AdvancedCacheService();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;

  // API configurations
  final Map<String, ApiConfiguration> _apiConfigurations = {};
  final Map<String, IntegrationProvider> _integrations = {};
  final Map<String, WebhookConfiguration> _webhooks = {};

  // Integration status
  final Map<String, IntegrationStatus> _integrationStatus = {};
  final Map<String, DateTime> _lastSyncTimes = {};
  final Map<String, List<IntegrationError>> _integrationErrors = {};

  // Rate limiting and throttling
  final Map<String, RateLimit> _rateLimits = {};
  // Removed unused request counts map for now
  // final Map<String, int> _requestCounts = {};

  /// Initialize the integration service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize API configurations
      await _initializeApiConfigurations();

      // Initialize integrations
      await _initializeIntegrations();

      // Initialize webhooks
      await _initializeWebhooks();

      // Load integration status
      await _loadIntegrationStatus();

      // Start integration monitoring
      await _startIntegrationMonitoring();

      _isInitialized = true;

      await _analytics.logEvent('integration_service_initialized', parameters: {
        'api_configurations': _apiConfigurations.length,
        'integrations': _integrations.length,
        'webhooks': _webhooks.length,
      });
    } catch (e) {
      await _analytics.logError(
        error: 'Integration service initialization failed: $e',
        context: 'integration_service',
      );
      rethrow;
    }
  }

  /// Initialize API configurations
  Future<void> _initializeApiConfigurations() async {
    // Google Calendar API
    _apiConfigurations['google_calendar'] = ApiConfiguration(
      name: 'Google Calendar',
      baseUrl: 'https://www.googleapis.com/calendar/v3',
      authType: AuthType.oauth2,
      rateLimit: RateLimit(requestsPerMinute: 1000, requestsPerDay: 1000000),
      timeout: const Duration(seconds: 30),
    );

    // Microsoft Outlook API
    _apiConfigurations['microsoft_outlook'] = ApiConfiguration(
      name: 'Microsoft Outlook',
      baseUrl: 'https://graph.microsoft.com/v1.0',
      authType: AuthType.oauth2,
      rateLimit: RateLimit(requestsPerMinute: 600, requestsPerDay: 100000),
      timeout: const Duration(seconds: 30),
    );

    // Apple Calendar API
    _apiConfigurations['apple_calendar'] = ApiConfiguration(
      name: 'Apple Calendar',
      baseUrl: 'https://api.apple.com/calendar',
      authType: AuthType.oauth2,
      rateLimit: RateLimit(requestsPerMinute: 100, requestsPerDay: 10000),
      timeout: const Duration(seconds: 30),
    );

    // Twilio SMS API
    _apiConfigurations['twilio_sms'] = ApiConfiguration(
      name: 'Twilio SMS',
      baseUrl: 'https://api.twilio.com/2010-04-01',
      authType: AuthType.basic,
      rateLimit: RateLimit(requestsPerMinute: 100, requestsPerDay: 10000),
      timeout: const Duration(seconds: 30),
    );

    // Zoom API
    _apiConfigurations['zoom'] = ApiConfiguration(
      name: 'Zoom',
      baseUrl: 'https://api.zoom.us/v2',
      authType: AuthType.oauth2,
      rateLimit: RateLimit(requestsPerMinute: 200, requestsPerDay: 10000),
      timeout: const Duration(seconds: 30),
    );

    // myGov API
    _apiConfigurations['mygov'] = ApiConfiguration(
      name: 'myGov',
      baseUrl: 'https://api.mygov.gov.au',
      authType: AuthType.oauth2,
      rateLimit: RateLimit(requestsPerMinute: 60, requestsPerDay: 1000),
      timeout: const Duration(seconds: 30),
    );

    // NDIA API
    _apiConfigurations['ndia'] = ApiConfiguration(
      name: 'NDIA',
      baseUrl: 'https://api.ndis.gov.au',
      authType: AuthType.oauth2,
      rateLimit: RateLimit(requestsPerMinute: 30, requestsPerDay: 1000),
      timeout: const Duration(seconds: 30),
    );
  }

  /// Initialize integrations
  Future<void> _initializeIntegrations() async {
    // Calendar integrations
    _integrations['google_calendar'] = IntegrationProvider(
      id: 'google_calendar',
      name: 'Google Calendar',
      type: IntegrationType.calendar,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'read_calendar',
        'write_calendar',
        'sync_events',
        'create_events',
        'update_events',
        'delete_events',
      ],
    );

    _integrations['microsoft_outlook'] = IntegrationProvider(
      id: 'microsoft_outlook',
      name: 'Microsoft Outlook',
      type: IntegrationType.calendar,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'read_calendar',
        'write_calendar',
        'sync_events',
        'create_events',
        'update_events',
        'delete_events',
      ],
    );

    _integrations['apple_calendar'] = IntegrationProvider(
      id: 'apple_calendar',
      name: 'Apple Calendar',
      type: IntegrationType.calendar,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'read_calendar',
        'write_calendar',
        'sync_events',
        'create_events',
        'update_events',
        'delete_events',
      ],
    );

    // Communication integrations
    _integrations['twilio_sms'] = IntegrationProvider(
      id: 'twilio_sms',
      name: 'Twilio SMS',
      type: IntegrationType.communication,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'send_sms',
        'receive_sms',
        'sms_notifications',
        'bulk_sms',
      ],
    );

    _integrations['zoom'] = IntegrationProvider(
      id: 'zoom',
      name: 'Zoom',
      type: IntegrationType.videoConferencing,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'create_meetings',
        'join_meetings',
        'schedule_meetings',
        'record_meetings',
        'meeting_analytics',
      ],
    );

    // Government integrations
    _integrations['mygov'] = IntegrationProvider(
      id: 'mygov',
      name: 'myGov',
      type: IntegrationType.government,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'authentication',
        'profile_data',
        'service_access',
        'document_access',
      ],
    );

    _integrations['ndia'] = IntegrationProvider(
      id: 'ndia',
      name: 'NDIA',
      type: IntegrationType.government,
      status: IntegrationStatus.disconnected,
      capabilities: [
        'plan_data',
        'budget_information',
        'provider_data',
        'service_coordination',
      ],
    );
  }

  /// Initialize webhooks
  Future<void> _initializeWebhooks() async {
    _webhooks['calendar_sync'] = WebhookConfiguration(
      id: 'calendar_sync',
      name: 'Calendar Sync',
      url: 'https://api.ndisconnect.app/webhooks/calendar-sync',
      events: ['calendar.created', 'calendar.updated', 'calendar.deleted'],
      secret: 'webhook_secret_calendar',
      enabled: true,
    );

    _webhooks['budget_alert'] = WebhookConfiguration(
      id: 'budget_alert',
      name: 'Budget Alert',
      url: 'https://api.ndisconnect.app/webhooks/budget-alert',
      events: ['budget.threshold_reached', 'budget.low_balance'],
      secret: 'webhook_secret_budget',
      enabled: true,
    );

    _webhooks['appointment_reminder'] = WebhookConfiguration(
      id: 'appointment_reminder',
      name: 'Appointment Reminder',
      url: 'https://api.ndisconnect.app/webhooks/appointment-reminder',
      events: ['appointment.upcoming', 'appointment.reminder'],
      secret: 'webhook_secret_appointment',
      enabled: true,
    );
  }

  /// Load integration status from storage
  Future<void> _loadIntegrationStatus() async {
    final prefs = await SharedPreferences.getInstance();

    for (final integration in _integrations.values) {
      final statusData =
          prefs.getString('integration_status_${integration.id}');
      if (statusData != null) {
        final statusJson = jsonDecode(statusData);
        _integrationStatus[integration.id] =
            IntegrationStatus.values.firstWhere(
          (final s) => s.name == statusJson['status'],
          orElse: () => IntegrationStatus.disconnected,
        );
        _lastSyncTimes[integration.id] =
            DateTime.parse(statusJson['last_sync'] as String);
      }
    }
  }

  /// Start integration monitoring
  Future<void> _startIntegrationMonitoring() async {
    // Monitor connectivity changes
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged
        .listen((final results) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result != ConnectivityResult.none) {
        _syncAllIntegrations();
      }
    });
  }

  /// Connect to an integration
  Future<bool> connectIntegration(
      final String integrationId, final Map<String, dynamic> credentials) async {
    try {
      final integration = _integrations[integrationId];
      if (integration == null) {
        throw Exception('Integration not found: $integrationId');
      }

      // Validate credentials
      final isValid = await _validateCredentials(integrationId, credentials);
      if (!isValid) {
        throw Exception('Invalid credentials for $integrationId');
      }

      // Store credentials securely
      await _storeCredentials(integrationId, credentials);

      // Test connection
      final isConnected = await _testConnection(integrationId);
      if (!isConnected) {
        throw Exception('Failed to connect to $integrationId');
      }

      // Update status
      _integrationStatus[integrationId] = IntegrationStatus.connected;
      integration.status = IntegrationStatus.connected;

      // Save status
      await _saveIntegrationStatus(integrationId);

      // Start sync
      await _startSync(integrationId);

      await _analytics.logEvent('integration_connected', parameters: {
        'integration_id': integrationId,
        'integration_name': integration.name,
        'integration_type': integration.type.name,
      });

      return true;
    } catch (e) {
      await _recordIntegrationError(integrationId, e.toString());
      await _analytics.logError(
        error: 'Integration connection failed: $integrationId - $e',
        context: 'integration_service',
      );
      return false;
    }
  }

  /// Disconnect from an integration
  Future<bool> disconnectIntegration(final String integrationId) async {
    try {
      final integration = _integrations[integrationId];
      if (integration == null) {
        throw Exception('Integration not found: $integrationId');
      }

      // Stop sync
      await _stopSync(integrationId);

      // Clear credentials
      await _clearCredentials(integrationId);

      // Update status
      _integrationStatus[integrationId] = IntegrationStatus.disconnected;
      integration.status = IntegrationStatus.disconnected;

      // Save status
      await _saveIntegrationStatus(integrationId);

      await _analytics.logEvent('integration_disconnected', parameters: {
        'integration_id': integrationId,
        'integration_name': integration.name,
      });

      return true;
    } catch (e) {
      await _analytics.logError(
        error: 'Integration disconnection failed: $integrationId - $e',
        context: 'integration_service',
      );
      return false;
    }
  }

  /// Sync data from an integration
  Future<bool> syncIntegration(final String integrationId) async {
    try {
      final integration = _integrations[integrationId];
      if (integration == null ||
          integration.status != IntegrationStatus.connected) {
        return false;
      }

      final startTime = DateTime.now();

      // Perform sync based on integration type
      switch (integration.type) {
        case IntegrationType.calendar:
          await _syncCalendarData(integrationId);
          break;
        case IntegrationType.communication:
          await _syncCommunicationData(integrationId);
          break;
        case IntegrationType.videoConferencing:
          await _syncVideoConferencingData(integrationId);
          break;
        case IntegrationType.government:
          await _syncGovernmentData(integrationId);
          break;
        case IntegrationType.healthcare:
          await _syncHealthcareData(integrationId);
          break;
        case IntegrationType.iot:
          await _syncIoTData(integrationId);
          break;
        case IntegrationType.payment:
          // No-op for now; implement when payment providers are added
          break;
        case IntegrationType.analytics:
          // No-op for now; implement when analytics providers are added
          break;
      }

      // Update last sync time
      _lastSyncTimes[integrationId] = DateTime.now();
      await _saveIntegrationStatus(integrationId);

      final duration = DateTime.now().difference(startTime);

      await _analytics.logEvent('integration_sync_completed', parameters: {
        'integration_id': integrationId,
        'duration_ms': duration.inMilliseconds,
      });

      return true;
    } catch (e) {
      await _recordIntegrationError(integrationId, e.toString());
      await _analytics.logError(
        error: 'Integration sync failed: $integrationId - $e',
        context: 'integration_service',
      );
      return false;
    }
  }

  /// Sync all connected integrations
  Future<void> _syncAllIntegrations() async {
    for (final integration in _integrations.values) {
      if (integration.status == IntegrationStatus.connected) {
        await syncIntegration(integration.id);
      }
    }
  }

  /// Sync calendar data
  Future<void> _syncCalendarData(final String integrationId) async {
    // Implementation would sync calendar data
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Sync communication data
  Future<void> _syncCommunicationData(final String integrationId) async {
    // Implementation would sync communication data
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Sync video conferencing data
  Future<void> _syncVideoConferencingData(final String integrationId) async {
    // Implementation would sync video conferencing data
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Sync government data
  Future<void> _syncGovernmentData(final String integrationId) async {
    // Implementation would sync government data
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Sync healthcare data
  Future<void> _syncHealthcareData(final String integrationId) async {
    // Implementation would sync healthcare data
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Sync IoT data
  Future<void> _syncIoTData(final String integrationId) async {
    // Implementation would sync IoT data
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  /// Validate credentials for an integration
  Future<bool> _validateCredentials(
      final String integrationId, final Map<String, dynamic> credentials) async {
    // Implementation would validate credentials
    return true;
  }

  /// Store credentials securely
  Future<void> _storeCredentials(
      final String integrationId, final Map<String, dynamic> credentials) async {
    // Implementation would store credentials securely
  }

  /// Clear credentials
  Future<void> _clearCredentials(final String integrationId) async {
    // Implementation would clear credentials
  }

  /// Test connection to an integration
  Future<bool> _testConnection(final String integrationId) async {
    // Implementation would test connection
    return true;
  }

  /// Start sync for an integration
  Future<void> _startSync(final String integrationId) async {
    // Implementation would start sync
  }

  /// Stop sync for an integration
  Future<void> _stopSync(final String integrationId) async {
    // Implementation would stop sync
  }

  /// Save integration status
  Future<void> _saveIntegrationStatus(final String integrationId) async {
    final prefs = await SharedPreferences.getInstance();
    final statusData = {
      'status': _integrationStatus[integrationId]?.name ?? 'disconnected',
      'last_sync': _lastSyncTimes[integrationId]?.toIso8601String(),
    };
    await prefs.setString(
        'integration_status_$integrationId', jsonEncode(statusData));
  }

  /// Record integration error
  Future<void> _recordIntegrationError(
      final String integrationId, final String error) async {
    final errorRecord = IntegrationError(
      integrationId: integrationId,
      error: error,
      timestamp: DateTime.now(),
    );

    _integrationErrors.putIfAbsent(integrationId, () => []).add(errorRecord);

    // Keep only last 10 errors per integration
    if (_integrationErrors[integrationId]!.length > 10) {
      _integrationErrors[integrationId]!.removeAt(0);
    }
  }

  /// Make API request with rate limiting and error handling
  Future<ApiResponse> makeApiRequest(
    final String integrationId,
    final String endpoint, {
    final HttpMethod method = HttpMethod.get,
    final Map<String, dynamic>? body,
    final Map<String, String>? headers,
    final Duration? timeout,
  }) async {
    try {
      final config = _apiConfigurations[integrationId];
      if (config == null) {
        throw Exception('API configuration not found: $integrationId');
      }

      // Check rate limit
      if (!await _checkRateLimit(integrationId)) {
        throw Exception('Rate limit exceeded for $integrationId');
      }

      // Build URL
      final url = Uri.parse('${config.baseUrl}$endpoint');

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Add authentication headers
      await _addAuthHeaders(integrationId, requestHeaders);

      // Make request based on HTTP method
      http.Response response;
      final effectiveTimeout = timeout ?? config.timeout;
      switch (method) {
        case HttpMethod.get:
          response = await http
              .get(url, headers: requestHeaders)
              .timeout(effectiveTimeout);
          break;
        case HttpMethod.post:
          response = await http
              .post(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(effectiveTimeout);
          break;
        case HttpMethod.put:
          response = await http
              .put(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(effectiveTimeout);
          break;
        case HttpMethod.delete:
          response = await http
              .delete(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(effectiveTimeout);
          break;
        case HttpMethod.patch:
          response = await http
              .patch(
                url,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(effectiveTimeout);
          break;
      }

      // Update rate limit
      _updateRateLimit(integrationId);

      // Parse response
      final responseBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      return ApiResponse(
        statusCode: response.statusCode,
        body: responseBody,
        headers: response.headers,
        success: response.statusCode >= 200 && response.statusCode < 300,
      );
    } catch (e) {
      await _recordIntegrationError(integrationId, e.toString());
      rethrow;
    }
  }

  /// Check rate limit for an integration
  Future<bool> _checkRateLimit(final String integrationId) async {
    final config = _apiConfigurations[integrationId];
    if (config == null) return true;

    final rateLimit = _rateLimits[integrationId];

    if (rateLimit == null) {
      _rateLimits[integrationId] = RateLimit(
        requestsPerMinute: config.rateLimit.requestsPerMinute,
        requestsPerDay: config.rateLimit.requestsPerDay,
      );
      return true;
    }

    // Check minute limit
    if (rateLimit.minuteRequests >= config.rateLimit.requestsPerMinute) {
      return false;
    }

    // Check day limit
    if (rateLimit.dayRequests >= config.rateLimit.requestsPerDay) {
      return false;
    }

    return true;
  }

  /// Update rate limit for an integration
  void _updateRateLimit(final String integrationId) {
    final rateLimit = _rateLimits[integrationId];
    if (rateLimit != null) {
      rateLimit.minuteRequests++;
      rateLimit.dayRequests++;
    }
  }

  /// Add authentication headers
  Future<void> _addAuthHeaders(
      final String integrationId, final Map<String, String> headers) async {
    // Implementation would add authentication headers
  }

  /// Get integration status
  IntegrationStatus? getIntegrationStatus(final String integrationId) => _integrationStatus[integrationId];

  /// Get all integrations
  Map<String, IntegrationProvider> getIntegrations() => Map.unmodifiable(_integrations);

  /// Get connected integrations
  List<IntegrationProvider> getConnectedIntegrations() => _integrations.values
        .where(
            (final integration) => integration.status == IntegrationStatus.connected)
        .toList();

  /// Get integration errors
  List<IntegrationError> getIntegrationErrors(final String integrationId) => _integrationErrors[integrationId] ?? [];

  /// Get integration statistics
  Map<String, dynamic> getIntegrationStatistics() {
    final total = _integrations.length;
    final connected = _integrations.values
        .where(
            (final integration) => integration.status == IntegrationStatus.connected)
        .length;
    final disconnected = total - connected;

    return {
      'total_integrations': total,
      'connected_integrations': connected,
      'disconnected_integrations': disconnected,
      'connection_rate': total > 0 ? (connected / total) * 100 : 0,
      'last_sync_times': _lastSyncTimes,
      'error_counts': _integrationErrors.map(
        (final key, final value) => MapEntry(key, value.length),
      ),
    };
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  Map<String, ApiConfiguration> get apiConfigurations =>
      Map.unmodifiable(_apiConfigurations);
  Map<String, WebhookConfiguration> get webhooks => Map.unmodifiable(_webhooks);
}

/// API configuration model
class ApiConfiguration {

  ApiConfiguration({
    required this.name,
    required this.baseUrl,
    required this.authType,
    required this.rateLimit,
    required this.timeout,
  });
  final String name;
  final String baseUrl;
  final AuthType authType;
  final RateLimit rateLimit;
  final Duration timeout;
}

/// Authentication type enum
enum AuthType {
  none,
  basic,
  bearer,
  oauth2,
  apiKey,
}

/// Rate limit model
class RateLimit {

  RateLimit({
    required this.requestsPerMinute,
    required this.requestsPerDay,
  });
  final int requestsPerMinute;
  final int requestsPerDay;
  int minuteRequests = 0;
  int dayRequests = 0;
}

/// Integration provider model
class IntegrationProvider {

  IntegrationProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.capabilities,
  });
  final String id;
  final String name;
  final IntegrationType type;
  IntegrationStatus status;
  final List<String> capabilities;
}

/// Integration type enum
enum IntegrationType {
  calendar,
  communication,
  videoConferencing,
  government,
  healthcare,
  iot,
  payment,
  analytics,
}

/// Integration status enum
enum IntegrationStatus {
  disconnected,
  connecting,
  connected,
  error,
  syncing,
}

/// Webhook configuration model
class WebhookConfiguration {

  WebhookConfiguration({
    required this.id,
    required this.name,
    required this.url,
    required this.events,
    required this.secret,
    required this.enabled,
  });
  final String id;
  final String name;
  final String url;
  final List<String> events;
  final String secret;
  final bool enabled;
}

/// Integration error model
class IntegrationError {

  IntegrationError({
    required this.integrationId,
    required this.error,
    required this.timestamp,
  });
  final String integrationId;
  final String error;
  final DateTime timestamp;
}

/// API response model
class ApiResponse {

  ApiResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.success,
  });
  final int statusCode;
  final dynamic body;
  final Map<String, String> headers;
  final bool success;
}

/// HTTP method enum
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
}
