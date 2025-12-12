import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesapp/features/home/data/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  CollectionReference get _notificationsCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(user.uid).collection('notifications');
  }

  // ✅ NEW: Check if notifications are enabled for current user
  Future<bool> areNotificationsEnabled() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('notificationsEnabled')) {
          return data['notificationsEnabled'] as bool;
        }
      }

      // Default true jika field tidak ada
      return true;
    } catch (e) {
      debugPrint('Error checking notification settings: $e');
      return true; // Default true jika error
    }
  }

  // ✅ NEW: Stream untuk notification setting
  Stream<bool> getNotificationSettingStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('notificationsEnabled')) {
          return data['notificationsEnabled'] as bool;
        }
      }
      return true; // Default true
    });
  }

  // Initialize local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Show local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // ✅ UPDATED: Create notification dengan check setting
  Future<void> createNotification({
    required String title,
    required String description,
    required String type,
    required String priority,
    String? relatedTaskId,
  }) async {
    try {
      // ✅ Check apakah notifikasi diaktifkan
      final isEnabled = await areNotificationsEnabled();

      if (!isEnabled) {
        debugPrint('⚠️ Notifications are disabled by user. Skipping notification creation.');
        return; // Tidak buat notifikasi jika disabled
      }

      // Buat notifikasi di Firestore
      await _notificationsCollection.add({
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'type': type,
        'priority': priority,
        'relatedTaskId': relatedTaskId,
      });

      // Show local notification di HP
      await showNotification(
        title: title,
        body: description,
        type: type,
      );

      debugPrint('✅ Notification created: $title');
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  // Get notifications stream
  Stream<List<NotificationModel>> getNotificationsStream() {
    return _notificationsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Get unread count stream
  Stream<int> getUnreadCountStream() {
    return _notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
    });
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final unreadDocs = await _notificationsCollection
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  // ✅ UPDATED: Schedule reminder dengan check setting
  Future<void> scheduleReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
  }) async {
    try {
      // ✅ Check apakah notifikasi diaktifkan
      final isEnabled = await areNotificationsEnabled();

      if (!isEnabled) {
        debugPrint('⚠️ Notifications are disabled by user. Cannot schedule reminder.');
        return; // Tidak schedule reminder jika disabled
      }

      // Create reminder notification in Firestore
      await createNotification(
        title: 'Reminder: $taskTitle',
        description: 'Don\'t forget about your task!',
        type: 'reminder',
        priority: 'medium',
        relatedTaskId: taskId,
      );

      // Show immediate notification
      await showNotification(
        title: 'Reminder Set! ⏰',
        body: 'You will be reminded about "$taskTitle"',
        type: 'reminder',
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }
}