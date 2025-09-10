import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Test configuration and utilities for NDIS Connect app
class TestConfig {
  static bool _isInitialized = false;

  /// Initialize test environment
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Setup Firebase for testing
    await _setupFirebaseForTesting();

    // Setup global test configuration
    _setupGlobalTestConfig();

    _isInitialized = true;
  }

  /// Setup Firebase for testing
  static Future<void> _setupFirebaseForTesting() async {
    // Initialize Firebase with test configuration
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  }

  /// Setup global test configuration
  static void _setupGlobalTestConfig() {
    // Configure test timeout
    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup default test timeouts
    const defaultTimeout = Timeout(Duration(seconds: 30));

    // Configure mock behaviors
    _setupDefaultMockBehaviors();
  }

  /// Setup default mock behaviors for common services
  static void _setupDefaultMockBehaviors() {
    // This would contain default mock setups for common services
    // that are used across multiple tests
  }

  /// Create mock user for testing
  static MockUser createMockUser({
    final String uid = 'test-uid',
    final String email = 'test@example.com',
    final String displayName = 'Test User',
    final bool emailVerified = true,
  }) {
    final mockUser = MockUser();
    when(mockUser.uid).thenReturn(uid);
    when(mockUser.email).thenReturn(email);
    when(mockUser.displayName).thenReturn(displayName);
    when(mockUser.emailVerified).thenReturn(emailVerified);
    return mockUser;
  }

  /// Create mock user credential for testing
  static MockUserCredential createMockUserCredential({final MockUser? user}) {
    final mockCredential = MockUserCredential();
    when(mockCredential.user).thenReturn(user ?? createMockUser());
    return mockCredential;
  }

  /// Create mock Firestore document for testing
  static MockDocumentSnapshot createMockDocumentSnapshot({
    final String id = 'test-doc-id',
    final Map<String, dynamic> data = const {},
    final bool exists = true,
  }) {
    final mockDoc = MockDocumentSnapshot();
    when(mockDoc.id).thenReturn(id);
    when(mockDoc.data()).thenReturn(data);
    when(mockDoc.exists).thenReturn(exists);
    return mockDoc;
  }

  /// Create mock Firestore collection for testing
  static MockCollectionReference createMockCollectionReference() => MockCollectionReference();

  /// Create mock Firestore query for testing
  static MockQuery createMockQuery() => MockQuery();

  /// Create mock Firestore query snapshot for testing
  static MockQuerySnapshot createMockQuerySnapshot({
    final List<MockDocumentSnapshot> docs = const [],
  }) {
    final mockSnapshot = MockQuerySnapshot();
    when(mockSnapshot.docs).thenReturn(docs);
    when(mockSnapshot.size).thenReturn(docs.length);
    return mockSnapshot;
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsyncOperations() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Create test data for appointments
  static Map<String, dynamic> createTestAppointmentData({
    final String id = 'test-appointment-id',
    final String title = 'Test Appointment',
    final String description = 'Test appointment description',
    final DateTime? startTime,
    final DateTime? endTime,
    final String providerId = 'test-provider-id',
    final String participantId = 'test-participant-id',
    final String status = 'scheduled',
  }) {
    final now = DateTime.now();
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': (startTime ?? now).toIso8601String(),
      'endTime': (endTime ?? now.add(const Duration(hours: 1)))
          .toIso8601String(),
      'providerId': providerId,
      'participantId': participantId,
      'status': status,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
  }

  /// Create test data for budget entries
  static Map<String, dynamic> createTestBudgetData({
    final String id = 'test-budget-id',
    final String participantId = 'test-participant-id',
    final double totalAmount = 10000.0,
    final double usedAmount = 0.0,
    final String category = 'Health Services',
  }) => {
      'id': id,
      'participantId': participantId,
      'totalAmount': totalAmount,
      'usedAmount': usedAmount,
      'category': category,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

  /// Create test data for tasks
  static Map<String, dynamic> createTestTaskData({
    final String id = 'test-task-id',
    final String title = 'Test Task',
    final String description = 'Test task description',
    final int priority = 1,
    final DateTime? dueDate,
    final String category = 'Health',
    final bool done = false,
  }) => {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': (dueDate ?? DateTime.now().add(const Duration(days: 7)))
          .toIso8601String(),
      'category': category,
      'done': done,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

  /// Create test data for support circle
  static Map<String, dynamic> createTestCircleData({
    final String id = 'test-circle-id',
    final String participantId = 'test-participant-id',
    final String name = 'Test Support Circle',
    final List<Map<String, dynamic>> members = const [],
  }) => {
      'id': id,
      'participantId': participantId,
      'name': name,
      'members': members,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

  /// Create test data for shifts
  static Map<String, dynamic> createTestShiftData({
    final String id = 'test-shift-id',
    final String providerId = 'test-provider-id',
    final DateTime? startTime,
    final DateTime? endTime,
    final String location = 'Test Location',
    final String status = 'available',
    final int maxParticipants = 5,
    final List<String> participantIds = const [],
  }) {
    final now = DateTime.now();
    return {
      'id': id,
      'providerId': providerId,
      'startTime': (startTime ?? now).toIso8601String(),
      'endTime': (endTime ?? now.add(const Duration(hours: 8)))
          .toIso8601String(),
      'location': location,
      'status': status,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
  }

  /// Verify that a widget has proper accessibility semantics
  static void verifyAccessibilitySemantics(
    final WidgetTester tester,
    final String semanticLabel,
  ) {
    expect(find.bySemanticsLabel(semanticLabel), findsOneWidget);
  }

  /// Verify that a widget supports keyboard navigation
  static void verifyKeyboardNavigation(final WidgetTester tester, final Finder finder) {
    // Focus the widget
    tester.focus(finder);
    expect(tester.element(finder).hasFocus, true);
  }

  /// Verify that a widget has proper contrast ratios
  static void verifyContrastRatio(final WidgetTester tester, final Finder finder) {
    // This would check contrast ratios for accessibility
    // Implementation would depend on specific contrast checking requirements
  }

  /// Create a test environment with specific configurations
  static Future<void> createTestEnvironment({
    final bool enableFirebase = true,
    final bool enableNetworkMocking = true,
    final bool enableOfflineMode = false,
  }) async {
    await initialize();

    if (enableFirebase) {
      await _setupFirebaseForTesting();
    }

    if (enableNetworkMocking) {
      // Setup network mocking
    }

    if (enableOfflineMode) {
      // Setup offline mode
    }
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    // Clean up any test resources
    _isInitialized = false;
  }
}

/// Mock classes for testing
class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuery extends Mock implements Query {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}
