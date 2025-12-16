// notification_service.dart
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
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications');
  }

  // ✅ Check if notifications are enabled for current user
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
      return true;
    } catch (e) {
      debugPrint('Error checking notification settings: $e');
      return true;
    }
  }

  // ✅ Stream untuk notification setting
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
      return true;
    });
  }

  // Initialize local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

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
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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

  // ✅ Create notification dengan check setting
  Future<void> createNotification({
    required String title,
    required String description,
    required String type,
    required String priority,
    String? relatedTaskId,
    String? relatedEventId,
  }) async {
    try {
      final isEnabled = await areNotificationsEnabled();

      if (!isEnabled) {
        debugPrint('⚠️ Notifications are disabled by user. Skipping notification creation.');
        return;
      }

      await _notificationsCollection.add({
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'type': type,
        'priority': priority,
        'relatedTaskId': relatedTaskId,
        'relatedEventId': relatedEventId,
      });

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

  Future<void> checkAndNotifyEventReminders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();

      // Ambil reminder yang waktunya sudah lewat atau sekarang, tapi belum diproses
      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('event_reminders')
          .where('isProcessed', isEqualTo: false)
          .where('reminderTime', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (var doc in remindersSnapshot.docs) {
        final data = doc.data();
        final eventTitle = data['eventTitle'] ?? 'Event';
        final minutesBefore = data['minutesBefore'] ?? 0;

        final notifRef = _notificationsCollection.doc();
        batch.set(notifRef, {
          'title': '📅 Upcoming Event',
          'description': '"$eventTitle" starts in $minutesBefore minutes.',
          'timestamp': Timestamp.now(),
          'isRead': false,
          'type': 'event_reminder',
          'priority': 'high',
          'relatedEventId': data['eventId'],
        });

        batch.update(doc.reference, {'isProcessed': true});
        hasUpdates = true;
      }

      if (hasUpdates) {
        await batch.commit();
        debugPrint('✅ Processed ${remindersSnapshot.docs.length} event reminders into in-app notifications.');
      }
    } catch (e) {
      debugPrint('Error checking event reminders: $e');
    }
  }

  // ✅ NEW: Check for overdue tasks and create notifications
  Future<void> checkAndNotifyOverdueTasks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final isEnabled = await areNotificationsEnabled();
      if (!isEnabled) return;

      final now = DateTime.now();
      final todosSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .where('isCompleted', isEqualTo: false)
          .get();

      for (var doc in todosSnapshot.docs) {
        final data = doc.data();
        final deadline = (data['deadline'] as Timestamp).toDate();

        // Cek apakah sudah overdue
        if (deadline.isBefore(now)) {
          final taskTitle = data['title'] ?? 'Untitled Task';
          final createdAt = data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : now;

          // Format tanggal
          final deadlineStr = _formatDate(deadline);
          final createdStr = _formatDate(createdAt);

          // Cek apakah sudah ada notifikasi overdue untuk task ini
          final existingNotif = await _notificationsCollection
              .where('relatedTaskId', isEqualTo: doc.id)
              .where('type', isEqualTo: 'overdue')
              .limit(1)
              .get();

          // Hanya buat notifikasi baru jika belum ada
          if (existingNotif.docs.isEmpty) {
            await createNotification(
              title: '⚠️ Overdue Task',
              description: 'Task "$taskTitle" is overdue! Created on $createdStr, deadline was $deadlineStr',
              type: 'overdue',
              priority: 'high',
              relatedTaskId: doc.id,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking overdue tasks: $e');
    }
  }

  // Helper untuk format tanggal
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

  // ✅ NEW: Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      final batch = _firestore.batch();
      final allDocs = await _notificationsCollection.get();

      for (var doc in allDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ All notifications deleted');
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Schedule reminder
  Future<void> scheduleReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderTime,
  }) async {
    try {
      final isEnabled = await areNotificationsEnabled();
      if (!isEnabled) {
        debugPrint('⚠️ Notifications are disabled by user. Cannot schedule reminder.');
        return;
      }

      await createNotification(
        title: 'Reminder: $taskTitle',
        description: 'Don\'t forget about your task!',
        type: 'reminder',
        priority: 'medium',
        relatedTaskId: taskId,
      );

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