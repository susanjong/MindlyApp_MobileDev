import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:notesapp/features/home/data/services/notification_helper.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final NotificationHelper _notificationHelper = NotificationHelper();

  CollectionReference _getEventsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('events');
  }

  Future<String> addEvent(Event event) async {
    try {
      DocumentReference docRef = await _getEventsCollection(event.userId).add(event.toMap());
      await _notificationService.createNotification(
        title: '📅 Event Created',
        description: 'Event "${event.title}" has been scheduled',
        type: 'event_created',
        priority: 'medium',
        relatedEventId: docRef.id,
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  Future<void> updateEvent(String userId, Event event) async {
    try {
      await _getEventsCollection(userId).doc(event.id).update(event.toMap());
      await _notificationService.createNotification(
        title: '📝 Event Updated',
        description: 'Event "${event.title}" has been updated',
        type: 'event_created',
        priority: 'low',
        relatedEventId: event.id,
      );
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _getEventsCollection(userId).doc(eventId).delete();
      await _cancelScheduledNotification(eventId);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Stream<List<Event>> getEventsForDate(String userId, DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _getEventsCollection(userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Event>> getEventsForMonth(String userId, DateTime month) {
    DateTime startOfMonth = DateTime(month.year, month.month, 1);
    DateTime endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return _getEventsCollection(userId)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<Event>> getAllEvents(String userId) {
    return _getEventsCollection(userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<Event?> getEventById(String userId, String eventId) async {
    try {
      DocumentSnapshot doc = await _getEventsCollection(userId).doc(eventId).get();
      if (doc.exists) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  // schedule notification
  Future<void> scheduleEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventTime,
    required int minutesBefore,
  }) async {
    try {
      final now = DateTime.now();
      final reminderTime = eventTime.subtract(Duration(minutes: minutesBefore));

      if (kDebugMode) {
        print('\n=== 🔔 SCHEDULING REMINDER ===');
        print('Event: $eventTitle');
        print('Event Time: $eventTime');
        print('Reminder Time: $reminderTime');
        print('Current Time: $now');
      }

      if (reminderTime.isBefore(now)) {
        throw Exception('Cannot set reminder for past time');
      }

      final notificationId = eventId.hashCode;
      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      // use NotificationHelper to schedule
      await _notificationHelper.scheduleNotification(
        id: notificationId,
        title: '⏰ Event Reminder',
        body: '$eventTitle starts at ${_formatTime(eventTime)}',
        scheduledDate: scheduledDate,
      );

      if (kDebugMode) {
        final pending = await _notificationHelper.getPendingNotifications();
        print('📋 Pending notifications: ${pending.length}');
        print('=== END ===\n');
      }

      // Save to Firestore
      await _saveReminderToFirestore(
        userId: userId,
        eventId: eventId,
        eventTitle: eventTitle,
        eventTime: eventTime,
        reminderTime: reminderTime,
        minutesBefore: minutesBefore,
        notificationId: notificationId,
      );

      // create in-app notification
      final difference = reminderTime.difference(now);
      String timeMessage;
      if (difference.inDays > 0) {
        timeMessage = 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        timeMessage = 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        timeMessage = 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        timeMessage = 'now';
      }

      await _notificationService.createNotification(
        title: '⏰ Reminder Set',
        description: 'You will be reminded about "$eventTitle" $timeMessage',
        type: 'event_reminder',
        priority: 'high',
        relatedEventId: eventId,
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ ERROR: $e');
      }
      rethrow;
    }
  }

  Future<void> _saveReminderToFirestore({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventTime,
    required DateTime reminderTime,
    required int minutesBefore,
    required int notificationId,
  }) async {
    await _firestore.collection('users').doc(userId).collection('event_reminders').doc(eventId).set({
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventTime': Timestamp.fromDate(eventTime),
      'reminderTime': Timestamp.fromDate(reminderTime),
      'minutesBefore': minutesBefore,
      'notificationId': notificationId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _cancelScheduledNotification(String eventId) async {
    final notificationId = eventId.hashCode;
    await _notificationHelper.cancelNotification(notificationId);
  }

  Future<Map<String, dynamic>?> getEventReminder(String userId, String eventId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('event_reminders').doc(eventId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelEventReminder(String userId, String eventId) async {
    try {
      await _cancelScheduledNotification(eventId);
      await _firestore.collection('users').doc(userId).collection('event_reminders').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to cancel reminder: $e');
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

}