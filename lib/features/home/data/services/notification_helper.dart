import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _notifications;

  // Initialize notification plugin
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
        debugPrint('📱 Notification tapped: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    // Request permissions
    await _requestPermissions();

    debugPrint('NotificationHelper initialized');
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    debugPrint('🎯 Handling notification payload: $payload');

    // TODO: Parse payload dan navigate
    // Format: "event_reminder:eventId"
    // Implementasi navigation ke event detail atau notification page
  }

  // Request permissions
  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Request notification permission (Android 13+)
    await android?.requestNotificationsPermission();

    // iOS permissions
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permissions requested');
  }

  // Schedule notification - COMPLETELY FIXED!
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      // AndroidNotificationDetails - FIXED color issue
      final androidDetails = AndroidNotificationDetails(
        'event_reminders',
        'Event Reminders',
        channelDescription: 'Reminders for upcoming events',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        ticker: 'Event Reminder',
        styleInformation: const BigTextStyleInformation(''),
        enableLights: true,
        color: const Color(0xFF5683EB),
        ledColor: const Color(0xFF5683EB),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Removed the problematic parameter!
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );

      debugPrint(' Notification scheduled: ID=$id, Time=$scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  //  Show instant notification (for testing or immediate alerts)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Instant test notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
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

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint('Instant notification shown: $title');
  }

  // Cancel single notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🗑️ Notification cancelled: ID=$id');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🗑️ All notifications cancelled');
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();

    debugPrint('📋 Pending notifications: ${pending.length}');
    for (var notif in pending) {
      debugPrint('  - ID: ${notif.id}, Title: ${notif.title}');
    }

    return pending;
  }

  // Get active notifications (Android only, API 23+)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final active = await android.getActiveNotifications();
      debugPrint('📱 Active notifications: ${active.length}');
      return active;
    }

    return [];
  }
}