import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../firebase_bg.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final _messaging = FirebaseMessaging.instance;
  static final _fln = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Web: local notifications plugin and background handlers not applicable.
        // Firebase messaging will still work for web if configured, but skip native init.
        return;
      }
      // Local notifications init
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const init = InitializationSettings(android: android, iOS: ios);
      await _fln.initialize(init);
      tz.initializeTimeZones();

      // Request permission
      await _messaging.requestPermission();

      // Foreground presentation
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((final message) {
        final notif = message.notification;
        if (notif != null) {
          _fln.show(
            notif.hashCode,
            notif.title,
            notif.body,
            const NotificationDetails(
              android: AndroidNotificationDetails('default', 'General'),
              iOS: DarwinNotificationDetails(),
            ),
          );
        }
      });
    } catch (e) {
      log('Notifications init skipped: $e');
    }
  }

  static Future<void> scheduleAt(
    final DateTime when, {
    required final int id,
    required final String title,
    required final String body,
  }) async {
    if (kIsWeb) {
      // No-op on web
      return;
    }
    const android = AndroidNotificationDetails('reminders', 'Reminders');
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _fln.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
