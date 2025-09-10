import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'analytics_service.dart';

/// Support Service for NDIS Connect
///
/// This service handles user support, feedback collection,
/// and help system functionality.
class SupportService {
  factory SupportService() => _instance;
  SupportService._internal();
  static final SupportService _instance = SupportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analytics = AnalyticsService();

  /// Submit user feedback
  Future<bool> submitFeedback({
    required final String feedbackType,
    required final String feedback,
    final int? rating,
    final String? category,
    final List<String>? attachments,
    final Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      final feedbackData = {
        'id': _firestore.collection('feedback').doc().id,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous@example.com',
        'feedbackType': feedbackType,
        'feedback': feedback,
        'rating': rating,
        'category': category ?? 'general',
        'attachments': attachments ?? [],
        'additionalData': additionalData ?? {},
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'priority': _getPriority(feedbackType, rating),
      };

      await _firestore.collection('feedback').add(feedbackData);

      // Log analytics
      await _analytics.logUserFeedback(
        feedbackType: feedbackType,
        feedback: feedback,
        rating: rating,
        additionalParams: {
          'category': category ?? 'general',
          'has_attachments': (attachments?.isNotEmpty ?? false),
        },
      );

      return true;
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'submit_feedback',
      );
      return false;
    }
  }

  /// Get priority level for feedback
  String _getPriority(final String feedbackType, final int? rating) {
    if (feedbackType == 'bug_report' || (rating != null && rating <= 2)) {
      return 'high';
    } else if (feedbackType == 'feature_request' ||
        (rating != null && rating <= 3)) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  /// Submit bug report
  Future<bool> submitBugReport({
    required final String description,
    required final String stepsToReproduce,
    required final String expectedBehavior,
    required final String actualBehavior,
    final String? deviceInfo,
    final String? appVersion,
    final List<String>? screenshots,
    final Map<String, dynamic>? additionalData,
  }) async => submitFeedback(
      feedbackType: 'bug_report',
      feedback: description,
      category: 'bug',
      additionalData: {
        'stepsToReproduce': stepsToReproduce,
        'expectedBehavior': expectedBehavior,
        'actualBehavior': actualBehavior,
        'deviceInfo': deviceInfo ?? await _getDeviceInfo(),
        'appVersion': appVersion ?? '1.0.0',
        'screenshots': screenshots ?? [],
        ...?additionalData,
      },
    );

  /// Submit feature request
  Future<bool> submitFeatureRequest({
    required final String title,
    required final String description,
    required final String useCase,
    final String? priority,
    final List<String>? attachments,
    final Map<String, dynamic>? additionalData,
  }) async => submitFeedback(
      feedbackType: 'feature_request',
      feedback: description,
      category: 'feature',
      additionalData: {
        'title': title,
        'useCase': useCase,
        'priority': priority ?? 'medium',
        'attachments': attachments ?? [],
        ...?additionalData,
      },
    );

  /// Submit accessibility feedback
  Future<bool> submitAccessibilityFeedback({
    required final String issue,
    required final String impact,
    required final String suggestedSolution,
    final String? accessibilityFeature,
    final Map<String, dynamic>? additionalData,
  }) async => submitFeedback(
      feedbackType: 'accessibility_feedback',
      feedback: issue,
      category: 'accessibility',
      additionalData: {
        'impact': impact,
        'suggestedSolution': suggestedSolution,
        'accessibilityFeature': accessibilityFeature,
        ...?additionalData,
      },
    );

  /// Get device information
  Future<String> _getDeviceInfo() async {
    try {
      return '${defaultTargetPlatform.name} - ${DateTime.now().toIso8601String()}';
    } catch (e) {
      return 'Unknown device';
    }
  }

  /// Get help articles
  Future<List<Map<String, dynamic>>> getHelpArticles({
    final String? category,
    final String? searchTerm,
  }) async {
    try {
      Query query = _firestore.collection('help_articles');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query =
            query.where('keywords', arrayContains: searchTerm.toLowerCase());
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((final doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'get_help_articles',
      );
      return [];
    }
  }

  /// Get FAQ items
  Future<List<Map<String, dynamic>>> getFAQItems({
    final String? category,
  }) async {
    try {
      Query query = _firestore.collection('faq');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((final doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'get_faq_items',
      );
      return [];
    }
  }

  /// Contact support
  Future<bool> contactSupport({
    required final String subject,
    required final String message,
    final String? category,
    final String? priority,
    final List<String>? attachments,
  }) async {
    try {
      final user = _auth.currentUser;
      final supportData = {
        'id': _firestore.collection('support_tickets').doc().id,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous@example.com',
        'subject': subject,
        'message': message,
        'category': category ?? 'general',
        'priority': priority ?? 'medium',
        'attachments': attachments ?? [],
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('support_tickets').add(supportData);

      // Log analytics
      await _analytics.logEvent('support_contacted', parameters: {
        'category': category ?? 'general',
        'priority': priority ?? 'medium',
        'has_attachments': (attachments?.isNotEmpty ?? false),
      });

      return true;
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'contact_support',
      );
      return false;
    }
  }

  /// Launch email support
  Future<bool> launchEmailSupport({
    final String? subject,
    final String? body,
  }) async {
    try {
      final user = _auth.currentUser;
      const email = 'support@ndisconnect.app';
      final defaultSubject = subject ?? 'NDIS Connect Support Request';
      final defaultBody = body ??
          '''
Hello NDIS Connect Support Team,

I need assistance with the following:

[Please describe your issue or question here]

User Information:
- Email: ${user?.email ?? 'Not provided'}
- User ID: ${user?.uid ?? 'Not provided'}
- App Version: 1.0.0
- Platform: ${defaultTargetPlatform.name}

Thank you for your help.

Best regards,
[Your name]
''';

      final uri = Uri(
        scheme: 'mailto',
        path: email,
        query:
            'subject=${Uri.encodeComponent(defaultSubject)}&body=${Uri.encodeComponent(defaultBody)}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        await _analytics.logEvent('email_support_launched');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'launch_email_support',
      );
      return false;
    }
  }

  /// Launch phone support
  Future<bool> launchPhoneSupport() async {
    try {
      const phoneNumber = '1800-NDIS-APP'; // Replace with actual support number
      final uri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        await _analytics.logEvent('phone_support_launched');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'launch_phone_support',
      );
      return false;
    }
  }

  /// Launch web support
  Future<bool> launchWebSupport() async {
    try {
      const url = 'https://ndisconnect.app/support';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        await _analytics.logEvent('web_support_launched');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'launch_web_support',
      );
      return false;
    }
  }

  /// Get support contact information
  Map<String, String> getSupportContacts() => {
      'email': 'support@ndisconnect.app',
      'phone': '1800-NDIS-APP',
      'website': 'https://ndisconnect.app/support',
      'hours': 'Monday - Friday, 9:00 AM - 5:00 PM AEST',
      'emergency': '000 (for emergencies)',
    };

  /// Get support categories
  List<Map<String, String>> getSupportCategories() => [
      {
        'id': 'general',
        'name': 'General Support',
        'description': 'General questions and assistance'
      },
      {
        'id': 'technical',
        'name': 'Technical Issues',
        'description': 'App bugs and technical problems'
      },
      {
        'id': 'accessibility',
        'name': 'Accessibility',
        'description': 'Accessibility features and support'
      },
      {
        'id': 'account',
        'name': 'Account Issues',
        'description': 'Login, registration, and account problems'
      },
      {
        'id': 'billing',
        'name': 'Billing & Payments',
        'description': 'Payment and subscription issues'
      },
      {
        'id': 'feature',
        'name': 'Feature Requests',
        'description': 'Suggestions for new features'
      },
      {
        'id': 'feedback',
        'name': 'Feedback',
        'description': 'General feedback and suggestions'
      },
    ];

  /// Get feedback types
  List<Map<String, String>> getFeedbackTypes() => [
      {
        'id': 'bug_report',
        'name': 'Bug Report',
        'description': 'Report a bug or technical issue'
      },
      {
        'id': 'feature_request',
        'name': 'Feature Request',
        'description': 'Suggest a new feature'
      },
      {
        'id': 'accessibility_feedback',
        'name': 'Accessibility Feedback',
        'description': 'Accessibility-related feedback'
      },
      {
        'id': 'general_feedback',
        'name': 'General Feedback',
        'description': 'General feedback and suggestions'
      },
      {
        'id': 'compliment',
        'name': 'Compliment',
        'description': 'Share positive feedback'
      },
      {
        'id': 'complaint',
        'name': 'Complaint',
        'description': 'Report a concern or complaint'
      },
    ];

  /// Rate app
  Future<bool> rateApp({
    required final int rating,
    final String? review,
    final String? category,
  }) async {
    try {
      final user = _auth.currentUser;
      final ratingData = {
        'id': _firestore.collection('app_ratings').doc().id,
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'anonymous@example.com',
        'rating': rating,
        'review': review,
        'category': category ?? 'general',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('app_ratings').add(ratingData);

      // Log analytics
      await _analytics.logEvent('app_rated', parameters: {
        'rating': rating,
        'has_review': (review?.isNotEmpty ?? false),
        'category': category ?? 'general',
      });

      return true;
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'rate_app',
      );
      return false;
    }
  }

  /// Get user feedback history
  Future<List<Map<String, dynamic>>> getUserFeedbackHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('feedback')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((final doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'get_user_feedback_history',
      );
      return [];
    }
  }

  /// Get support ticket status
  Future<Map<String, dynamic>?> getSupportTicketStatus(final String ticketId) async {
    try {
      final doc =
          await _firestore.collection('support_tickets').doc(ticketId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      await _analytics.logError(
        error: e.toString(),
        context: 'get_support_ticket_status',
      );
      return null;
    }
  }
}
