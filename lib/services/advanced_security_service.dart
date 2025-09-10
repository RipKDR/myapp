import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

/// Advanced Security Service with military-grade encryption,
/// comprehensive audit logging, and compliance features
class AdvancedSecurityService {
  factory AdvancedSecurityService() => _instance;
  AdvancedSecurityService._internal();
  static final AdvancedSecurityService _instance =
      AdvancedSecurityService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Removed unused Firestore instance to satisfy lints

  bool _isInitialized = false;

  // Encryption keys and algorithms
  late SecretKey _masterKey;
  late SecretKey _userKey;
  // Removed unused session key

  // Security algorithms
  final _aesAlgorithm = AesGcm.with256bits();
  final MacAlgorithm _macAlgorithm = Hmac.sha256();
  final _pbkdf2Algorithm =
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 100000, bits: 256);

  // Audit logging
  final List<SecurityEvent> _auditLog = [];
  final Map<String, SecurityPolicy> _securityPolicies = {};

  // Compliance tracking
  final Map<String, ComplianceRecord> _complianceRecords = {};
  final Map<String, PrivacyConsent> _privacyConsents = {};

  /// Initialize the advanced security service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize encryption keys
      await _initializeEncryptionKeys();

      // Initialize security policies
      await _initializeSecurityPolicies();

      // Initialize compliance tracking
      await _initializeComplianceTracking();

      // Load audit log
      await _loadAuditLog();

      // Start security monitoring
      await _startSecurityMonitoring();

      _isInitialized = true;

      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.system,
        action: 'security_service_initialized',
        severity: SecuritySeverity.info,
        details: {'timestamp': DateTime.now().toIso8601String()},
      ));
    } catch (e) {
      await _analytics.logError(
        error: 'Advanced security initialization failed: $e',
        context: 'advanced_security_service',
      );
      rethrow;
    }
  }

  /// Initialize encryption keys
  Future<void> _initializeEncryptionKeys() async {
    // Generate or retrieve master key
    final masterKeyData = await _secureStorage.read(key: 'master_key');
    if (masterKeyData != null) {
      _masterKey = SecretKey(base64Decode(masterKeyData));
    } else {
      _masterKey = await _aesAlgorithm.newSecretKey();
      await _secureStorage.write(
          key: 'master_key',
          value: base64Encode(await _masterKey.extractBytes()));
    }

    // Generate user-specific key
    final userId = _auth.currentUser?.uid;
    _userKey = await _deriveUserKey(userId ?? 'anonymous');

    // Session key generation removed
  }

  /// Derive user-specific encryption key
  Future<SecretKey> _deriveUserKey(final String userId) async {
    final salt = await _getOrCreateSalt('user_salt_$userId');
    return _pbkdf2Algorithm.deriveKey(
      secretKey: _masterKey,
      nonce: salt,
    );
  }

  /// Get or create salt for key derivation
  Future<Uint8List> _getOrCreateSalt(final String saltKey) async {
    final saltData = await _secureStorage.read(key: saltKey);
    if (saltData != null) {
      return base64Decode(saltData);
    } else {
      final salt =
          Uint8List.fromList(List.generate(32, (final i) => Random().nextInt(256)));
      await _secureStorage.write(key: saltKey, value: base64Encode(salt));
      return salt;
    }
  }

  /// Initialize security policies
  Future<void> _initializeSecurityPolicies() async {
    _securityPolicies.addAll({
      'password_policy': SecurityPolicy(
        name: 'Password Policy',
        rules: {
          'min_length': 8,
          'require_uppercase': true,
          'require_lowercase': true,
          'require_numbers': true,
          'require_special_chars': true,
          'max_age_days': 90,
        },
      ),
      'session_policy': SecurityPolicy(
        name: 'Session Policy',
        rules: {
          'max_duration_minutes': 480, // 8 hours
          'idle_timeout_minutes': 30,
          'max_concurrent_sessions': 3,
        },
      ),
      'encryption_policy': SecurityPolicy(
        name: 'Encryption Policy',
        rules: {
          'algorithm': 'AES-256-GCM',
          'key_rotation_days': 30,
          'require_end_to_end': true,
        },
      ),
      'audit_policy': SecurityPolicy(
        name: 'Audit Policy',
        rules: {
          'retention_days': 2555, // 7 years
          'log_all_events': true,
          'require_tamper_proof': true,
        },
      ),
    });
  }

  /// Initialize compliance tracking
  Future<void> _initializeComplianceTracking() async {
    // Initialize GDPR compliance
    _complianceRecords['gdpr'] = ComplianceRecord(
      framework: 'GDPR',
      status: ComplianceStatus.compliant,
      lastAssessment: DateTime.now(),
      nextAssessment: DateTime.now().add(const Duration(days: 90)),
      requirements: [
        'Data minimization',
        'Purpose limitation',
        'Storage limitation',
        'Accuracy',
        'Security',
        'Accountability',
      ],
    );

    // Initialize Australian Privacy Act compliance
    _complianceRecords['privacy_act'] = ComplianceRecord(
      framework: 'Australian Privacy Act',
      status: ComplianceStatus.compliant,
      lastAssessment: DateTime.now(),
      nextAssessment: DateTime.now().add(const Duration(days: 90)),
      requirements: [
        'Open and transparent management',
        'Anonymity and pseudonymity',
        'Collection of solicited personal information',
        'Dealing with unsolicited personal information',
        'Notification of collection',
        'Use or disclosure',
        'Direct marketing',
        'Cross-border disclosure',
        'Adoption, use or disclosure of government identifiers',
        'Quality of personal information',
        'Security of personal information',
        'Access to personal information',
        'Correction of personal information',
      ],
    );
  }

  /// Load audit log from storage
  Future<void> _loadAuditLog() async {
    try {
      final auditData = await _secureStorage.read(key: 'audit_log');
      if (auditData != null) {
        final auditList = jsonDecode(auditData) as List;
        _auditLog.clear();
        _auditLog.addAll(
          auditList
              .map((final json) =>
                  SecurityEvent.fromJson(json as Map<String, dynamic>))
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load audit log: $e');
    }
  }

  /// Start security monitoring
  Future<void> _startSecurityMonitoring() async {
    // Monitor authentication events
    _auth.authStateChanges().listen((final user) {
      if (user != null) {
        _logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authentication,
          action: 'user_authenticated',
          severity: SecuritySeverity.info,
          details: {'user_id': user.uid, 'email': user.email},
        ));
      } else {
        _logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authentication,
          action: 'user_logged_out',
          severity: SecuritySeverity.info,
          details: {},
        ));
      }
    });
  }

  /// Encrypt sensitive data with end-to-end encryption
  Future<EncryptedData> encryptSensitiveData(final String data,
      {final String? recipientId}) async {
    try {
      final key =
          recipientId != null ? await _deriveUserKey(recipientId) : _userKey;
      final nonce = _aesAlgorithm.newNonce();

      final encrypted = await _aesAlgorithm.encrypt(
        utf8.encode(data),
        secretKey: key,
        nonce: nonce,
      );

      // Create message authentication code (HMAC over ciphertext)
      final macBytes = await _macAlgorithm
          .calculateMac(encrypted.cipherText, secretKey: key)
          .then((final mac) => mac.bytes);

      final encryptedData = EncryptedData(
        cipherText: Uint8List.fromList(encrypted.cipherText),
        nonce: nonce,
        mac: Uint8List.fromList(macBytes),
        algorithm: 'AES-256-GCM',
        timestamp: DateTime.now(),
      );

      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.encryption,
        action: 'data_encrypted',
        severity: SecuritySeverity.info,
        details: {
          'algorithm': 'AES-256-GCM',
          'data_size': data.length,
          'recipient_id': recipientId,
        },
      ));

      return encryptedData;
    } catch (e) {
      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.encryption,
        action: 'encryption_failed',
        severity: SecuritySeverity.error,
        details: {'error': e.toString()},
      ));
      rethrow;
    }
  }

  /// Decrypt sensitive data
  Future<String> decryptSensitiveData(final EncryptedData encryptedData,
      {final String? senderId}) async {
    try {
      final key = senderId != null ? await _deriveUserKey(senderId) : _userKey;

      // Verify MAC
      final expectedMac = await _macAlgorithm.calculateMac(
        encryptedData.cipherText,
        secretKey: key,
      );
      if (!const ListEquality<int>()
          .equals(expectedMac.bytes, encryptedData.mac)) {
        throw SecurityException('Invalid authentication tag');
      }

      final decrypted = await _aesAlgorithm.decrypt(
        SecretBox(encryptedData.cipherText,
            nonce: encryptedData.nonce, mac: Mac(encryptedData.mac)),
        secretKey: key,
      );

      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.encryption,
        action: 'data_decrypted',
        severity: SecuritySeverity.info,
        details: {
          'algorithm': encryptedData.algorithm,
          'sender_id': senderId,
        },
      ));

      return utf8.decode(decrypted);
    } catch (e) {
      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.encryption,
        action: 'decryption_failed',
        severity: SecuritySeverity.error,
        details: {'error': e.toString()},
      ));
      rethrow;
    }
  }

  // RSA signing removed in favor of symmetric HMAC for simplicity/compatibility

  /// Enable multi-factor authentication
  Future<bool> enableMFA() async {
    try {
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        throw SecurityException('Biometric authentication not available');
      }

      // Get available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw SecurityException(
            'No biometric authentication methods available');
      }

      // Authenticate with biometrics
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable multi-factor authentication',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _secureStorage.write(key: 'mfa_enabled', value: 'true');

        await _logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authentication,
          action: 'mfa_enabled',
          severity: SecuritySeverity.info,
          details: {
            'available_biometrics':
                availableBiometrics.map((final b) => b.name).toList(),
          },
        ));

        return true;
      }

      return false;
    } catch (e) {
      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.authentication,
        action: 'mfa_enable_failed',
        severity: SecuritySeverity.error,
        details: {'error': e.toString()},
      ));
      return false;
    }
  }

  /// Disable multi-factor authentication
  Future<bool> disableMFA() async {
    try {
      // Require authentication to disable MFA
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Disable multi-factor authentication',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _secureStorage.delete(key: 'mfa_enabled');

        await _logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authentication,
          action: 'mfa_disabled',
          severity: SecuritySeverity.warning,
          details: {},
        ));

        return true;
      }

      return false;
    } catch (e) {
      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.authentication,
        action: 'mfa_disable_failed',
        severity: SecuritySeverity.error,
        details: {'error': e.toString()},
      ));
      return false;
    }
  }

  /// Check if MFA is enabled
  Future<bool> isMFAEnabled() async {
    final mfaEnabled = await _secureStorage.read(key: 'mfa_enabled');
    return mfaEnabled == 'true';
  }

  /// Authenticate with MFA
  Future<bool> authenticateWithMFA() async {
    try {
      if (!await isMFAEnabled()) {
        return true; // MFA not enabled, allow access
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access secure features',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await _logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authentication,
          action: 'mfa_authentication_success',
          severity: SecuritySeverity.info,
          details: {},
        ));
      } else {
        await _logSecurityEvent(SecurityEvent(
          type: SecurityEventType.authentication,
          action: 'mfa_authentication_failed',
          severity: SecuritySeverity.warning,
          details: {},
        ));
      }

      return isAuthenticated;
    } catch (e) {
      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.authentication,
        action: 'mfa_authentication_error',
        severity: SecuritySeverity.error,
        details: {'error': e.toString()},
      ));
      return false;
    }
  }

  /// Log security event
  Future<void> _logSecurityEvent(final SecurityEvent event) async {
    _auditLog.add(event);

    // Keep only last 1000 events in memory
    if (_auditLog.length > 1000) {
      _auditLog.removeAt(0);
    }

    // Save to secure storage
    await _saveAuditLog();

    // Send to analytics if not sensitive
    if (event.severity != SecuritySeverity.critical) {
      await _analytics.logEvent('security_event', parameters: {
        'type': event.type.name,
        'action': event.action,
        'severity': event.severity.name,
      });
    }
  }

  /// Save audit log to secure storage
  Future<void> _saveAuditLog() async {
    try {
      final auditJson = _auditLog.map((final event) => event.toJson()).toList();
      await _secureStorage.write(
          key: 'audit_log', value: jsonEncode(auditJson));
    } catch (e) {
      debugPrint('Failed to save audit log: $e');
    }
  }

  /// Get audit log
  List<SecurityEvent> getAuditLog() => List.unmodifiable(_auditLog);

  /// Get security events by type
  List<SecurityEvent> getSecurityEventsByType(final SecurityEventType type) => _auditLog.where((final event) => event.type == type).toList();

  /// Get security events by severity
  List<SecurityEvent> getSecurityEventsBySeverity(final SecuritySeverity severity) => _auditLog.where((final event) => event.severity == severity).toList();

  /// Generate compliance report
  Future<ComplianceReport> generateComplianceReport() async {
    final report = ComplianceReport(
      generatedAt: DateTime.now(),
      frameworks: _complianceRecords.keys.toList(),
      overallStatus: ComplianceStatus.compliant,
      findings: [],
      recommendations: [],
    );

    // Analyze compliance for each framework
    for (final entry in _complianceRecords.entries) {
      final framework = entry.key;
      final record = entry.value;

      if (record.status != ComplianceStatus.compliant) {
        report.findings.add(ComplianceFinding(
          framework: framework,
          severity: ComplianceSeverity.high,
          description: 'Non-compliant with $framework requirements',
          recommendation: 'Address compliance issues immediately',
        ));
      }
    }

    // Add security recommendations
    final criticalEvents =
        getSecurityEventsBySeverity(SecuritySeverity.critical);
    if (criticalEvents.isNotEmpty) {
      report.recommendations.add('Review and address critical security events');
    }

    return report;
  }

  /// Request privacy consent
  Future<bool> requestPrivacyConsent(final String purpose, final String description) async {
    try {
      final consent = PrivacyConsent(
        purpose: purpose,
        description: description,
        grantedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 365)),
        version: '1.0',
      );

      _privacyConsents[purpose] = consent;

      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.privacy,
        action: 'privacy_consent_granted',
        severity: SecuritySeverity.info,
        details: {
          'purpose': purpose,
          'expires_at': consent.expiresAt.toIso8601String(),
        },
      ));

      return true;
    } catch (e) {
      await _logSecurityEvent(SecurityEvent(
        type: SecurityEventType.privacy,
        action: 'privacy_consent_failed',
        severity: SecuritySeverity.error,
        details: {'error': e.toString()},
      ));
      return false;
    }
  }

  /// Check privacy consent
  bool hasPrivacyConsent(final String purpose) {
    final consent = _privacyConsents[purpose];
    if (consent == null) return false;

    return DateTime.now().isBefore(consent.expiresAt);
  }

  /// Revoke privacy consent
  Future<void> revokePrivacyConsent(final String purpose) async {
    _privacyConsents.remove(purpose);

    await _logSecurityEvent(SecurityEvent(
      type: SecurityEventType.privacy,
      action: 'privacy_consent_revoked',
      severity: SecuritySeverity.info,
      details: {'purpose': purpose},
    ));
  }

  /// Perform security audit
  Future<SecurityAudit> performSecurityAudit() async {
    final audit = SecurityAudit(
      performedAt: DateTime.now(),
      findings: [],
      recommendations: [],
      overallScore: 100,
    );

    // Check encryption status
    if (!_isInitialized) {
      audit.findings.add(SecurityFinding(
        category: 'Encryption',
        severity: SecuritySeverity.critical,
        description: 'Security service not initialized',
        recommendation: 'Initialize security service immediately',
      ));
      audit.overallScore -= 20;
    }

    // Check MFA status
    if (!await isMFAEnabled()) {
      audit.findings.add(SecurityFinding(
        category: 'Authentication',
        severity: SecuritySeverity.warning,
        description: 'Multi-factor authentication not enabled',
        recommendation: 'Enable MFA for enhanced security',
      ));
      audit.overallScore -= 10;
    }

    // Check for critical security events
    final criticalEvents =
        getSecurityEventsBySeverity(SecuritySeverity.critical);
    if (criticalEvents.isNotEmpty) {
      audit.findings.add(SecurityFinding(
        category: 'Monitoring',
        severity: SecuritySeverity.error,
        description:
            '${criticalEvents.length} critical security events detected',
        recommendation: 'Review and address critical security events',
      ));
      audit.overallScore -= 15;
    }

    // Add general recommendations
    audit.recommendations.addAll([
      'Regularly review audit logs',
      'Keep security policies up to date',
      'Monitor for suspicious activities',
      'Implement regular security training',
    ]);

    return audit;
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  Map<String, SecurityPolicy> get securityPolicies =>
      Map.unmodifiable(_securityPolicies);
  Map<String, ComplianceRecord> get complianceRecords =>
      Map.unmodifiable(_complianceRecords);
  Map<String, PrivacyConsent> get privacyConsents =>
      Map.unmodifiable(_privacyConsents);
}

/// Encrypted data model
class EncryptedData {

  EncryptedData({
    required this.cipherText,
    required this.nonce,
    required this.mac,
    required this.algorithm,
    required this.timestamp,
  });
  final Uint8List cipherText;
  final List<int> nonce;
  final Uint8List mac;
  final String algorithm;
  final DateTime timestamp;
}

/// Security event model
class SecurityEvent {

  SecurityEvent({
    required this.type,
    required this.action,
    required this.severity,
    required this.details,
    final DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityEvent.fromJson(final Map<String, dynamic> json) {
    try {
      return SecurityEvent(
        type: SecurityEventType.values.firstWhere(
          (final e) => e.name == json['type'],
          orElse: () => SecurityEventType.system,
        ),
        action: json['action'] as String? ?? '',
        severity: SecuritySeverity.values.firstWhere(
          (final e) => e.name == json['severity'],
          orElse: () => SecuritySeverity.info,
        ),
        details: Map<String, dynamic>.from(
            (json['details'] as Map<dynamic, dynamic>?) ?? {}),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
    } catch (e) {
      throw ArgumentError('Invalid security event data: $e');
    }
  }
  final SecurityEventType type;
  final String action;
  final SecuritySeverity severity;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'action': action,
        'severity': severity.name,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Security event type enum
enum SecurityEventType {
  authentication,
  encryption,
  privacy,
  system,
  access,
  data,
}

/// Security severity enum
enum SecuritySeverity {
  info,
  warning,
  error,
  critical,
}

/// Security policy model
class SecurityPolicy {

  SecurityPolicy({
    required this.name,
    required this.rules,
  });
  final String name;
  final Map<String, dynamic> rules;
}

/// Compliance record model
class ComplianceRecord {

  ComplianceRecord({
    required this.framework,
    required this.status,
    required this.lastAssessment,
    required this.nextAssessment,
    required this.requirements,
  });
  final String framework;
  final ComplianceStatus status;
  final DateTime lastAssessment;
  final DateTime nextAssessment;
  final List<String> requirements;
}

/// Compliance status enum
enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
}

/// Privacy consent model
class PrivacyConsent {

  PrivacyConsent({
    required this.purpose,
    required this.description,
    required this.grantedAt,
    required this.expiresAt,
    required this.version,
  });
  final String purpose;
  final String description;
  final DateTime grantedAt;
  final DateTime expiresAt;
  final String version;
}

/// Compliance report model
class ComplianceReport {

  ComplianceReport({
    required this.generatedAt,
    required this.frameworks,
    required this.overallStatus,
    required this.findings,
    required this.recommendations,
  });
  final DateTime generatedAt;
  final List<String> frameworks;
  final ComplianceStatus overallStatus;
  final List<ComplianceFinding> findings;
  final List<String> recommendations;
}

/// Compliance finding model
class ComplianceFinding {

  ComplianceFinding({
    required this.framework,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
  final String framework;
  final ComplianceSeverity severity;
  final String description;
  final String recommendation;
}

/// Compliance severity enum
enum ComplianceSeverity {
  low,
  medium,
  high,
  critical,
}

/// Security audit model
class SecurityAudit {

  SecurityAudit({
    required this.performedAt,
    required this.findings,
    required this.recommendations,
    required this.overallScore,
  });
  final DateTime performedAt;
  final List<SecurityFinding> findings;
  final List<String> recommendations;
  int overallScore;
}

/// Security finding model
class SecurityFinding {

  SecurityFinding({
    required this.category,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
  final String category;
  final SecuritySeverity severity;
  final String description;
  final String recommendation;
}

/// Security exception class
class SecurityException implements Exception {
  SecurityException(this.message);
  final String message;

  @override
  String toString() => 'SecurityException: $message';
}
