// features/home/data/services/background_notification_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

// service to check and process event reminders periodically
// runs every 1 minute to check reminders that are due
class BackgroundNotificationService {
  // singleton pattern
  static final BackgroundNotificationService _instance =
  BackgroundNotificationService._internal();

  factory BackgroundNotificationService() => _instance;

  BackgroundNotificationService._internal();

  // dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // timer for periodic check
  Timer? _periodicTimer;
  bool _isRunning = false;

  // start periodic check every 1 minute
  void startPeriodicCheck() {
    if (_isRunning) {
      debugPrint('background service already running');
      return;
    }

    _isRunning = true;

    // run immediately on start
    checkAndProcessEventReminders();

    // then run every 1 minute
    _periodicTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) => checkAndProcessEventReminders(),
    );

    debugPrint('background notification service started');
  }

  // stop periodic check
  void stopPeriodicCheck() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _isRunning = false;

    debugPrint('background notification service stopped');
  }

  // main function: check and process event reminders
  Future<void> checkAndProcessEventReminders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('no user logged in, skipping reminder check');
        return;
      }

      // check if notifications are enabled
      final isEnabled = await _notificationService.areNotificationsEnabled();
      if (!isEnabled) {
        debugPrint('notifications disabled, skipping reminder check');
        return;
      }

      final now = DateTime.now();

      // get reminders that are:
      // 1. not processed yet (isProcessed = false)
      // 2. reminder time has passed or is now
      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('event_reminders')
          .where('isProcessed', isEqualTo: false)
          .where('reminderTime', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      if (remindersSnapshot.docs.isEmpty) {
        debugPrint('no reminders to process at ${now.toString()}');
        return;
      }

      debugPrint('found ${remindersSnapshot.docs.length} reminders to process');

      // batch write for efficiency
      final batch = _firestore.batch();
      int processedCount = 0;

      for (var doc in remindersSnapshot.docs) {
        final data = doc.data();
        final eventId = data['eventId'] ?? '';
        final eventTitle = data['eventTitle'] ?? 'Event';
        final eventTime = (data['eventTime'] as Timestamp).toDate();
        final minutesBefore = data['minutesBefore'] ?? 15;

        // create in-app notification
        final notifRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'title': 'Event Reminder',
          'description': '"$eventTitle" starts in $minutesBefore minutes at ${_formatTime(eventTime)}',
          'timestamp': Timestamp.now(),
          'isRead': false,
          'type': 'event_reminder',
          'priority': 'high',
          'relatedEventId': eventId,
        });

        // mark reminder as processed
        batch.update(doc.reference, {'isProcessed': true});

        processedCount++;
      }

      // commit batch
      await batch.commit();

      debugPrint('successfully processed $processedCount event reminders');

    } catch (e) {
      debugPrint('error checking event reminders: $e');
    }
  }

  // format time for display in am/pm format
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // clean up old processed reminders - maintenance function
  // call this periodically to keep database clean
  Future<void> cleanOldProcessedReminders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // delete reminders older than 7 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

      final oldReminders = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('event_reminders')
          .where('isProcessed', isEqualTo: true)
          .where('reminderTime', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      if (oldReminders.docs.isEmpty) {
        debugPrint('no old reminders to clean');
        return;
      }

      final batch = _firestore.batch();

      for (var doc in oldReminders.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint('cleaned ${oldReminders.docs.length} old reminders');
    } catch (e) {
      debugPrint('error cleaning old reminders: $e');
    }
  }

  // get service status for debugging
  bool get isRunning => _isRunning;
}