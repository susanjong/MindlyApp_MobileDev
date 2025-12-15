import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _notifications;

  // ✅ Initialize notification plugin (WITHOUT exact alarm permission)
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('Notification tapped: ${response.payload}');
        }
      },
    );

    // Request permissions (WITHOUT exact alarms)
    await _requestPermissions();

    if (kDebugMode) {
      print('✅ NotificationHelper initialized (without exact alarms)');
    }
  }

  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // ✅ Request notification permission (basic)
    await android?.requestNotificationsPermission();

    // ❌ HAPUS BARIS INI - Tidak perlu exact alarms permission
    // await android?.requestExactAlarmsPermission();

    final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ✅ Schedule notification (menggunakan inexact scheduling)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      ticker: 'Event Reminder',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // ✅ Gunakan inexact scheduling (tidak butuh exact alarm permission)
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );

    if (kDebugMode) {
      print('✅ Notification scheduled (inexact): ID=$id, Time=$scheduledDate');
    }
  }

  // ✅ Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    if (kDebugMode) {
      print('🗑️ Notification cancelled: ID=$id');
    }
  }

  // ✅ Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    if (kDebugMode) {
      print('🗑️ All notifications cancelled');
    }
  }

  // ✅ Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ✅ Show instant notification (for testing)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Instant test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
  }
}