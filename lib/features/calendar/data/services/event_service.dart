import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:notesapp/features/home/data/services/notification_helper.dart';
import '../../presentation/widgets/delete_repeated_event.dart';
import '../../presentation/widgets/updated_repeated_dialog.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final NotificationHelper _notificationHelper = NotificationHelper();

  CollectionReference _getEventsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('events');
  }

  // Convert reminder string to minutes
  int _reminderToMinutes(String reminder) {
    switch (reminder) {
      case 'None':
        return 0;
      case '5 minutes before':
        return 5;
      case '10 minutes before':
        return 10;
      case '15 minutes before':
        return 15;
      case '30 minutes before':
        return 30;
      case '1 hour before':
        return 60;
      case '1 day before':
        return 1440;
      default:
        return 15;
    }
  }

  // Add new event with automatic reminder scheduling
  Future<String> addEvent(Event event) async {
    try {
      DocumentReference docRef = await _getEventsCollection(event.userId).add(event.toMap());

      // Schedule reminder based on user selection
      final reminderMinutes = _reminderToMinutes(event.reminder);
      if (reminderMinutes > 0) {
        await _scheduleEventReminder(
          userId: event.userId,
          eventId: docRef.id,
          eventTitle: event.title,
          eventTime: event.startTime,
          minutesBefore: reminderMinutes,
        );
      }

      // Handle repeat events with reminders
      if (event.repeat != 'Does not repeat') {
        await _createRepeatInstances(event, docRef.id, reminderMinutes);
      }

      // Create in-app notification
      await _notificationService.createNotification(
        title: 'Event Created',
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

  // Create repeat instances with reminders
  Future<void> _createRepeatInstances(
      Event event,
      String parentEventId,
      int reminderMinutes,
      ) async {
    try {
      int maxInstances;
      DateTime nextEventDate = event.startTime;

      switch (event.repeat) {
        case 'Every day':
          maxInstances = 30;
          break;
        case 'Every week':
          maxInstances = 12;
          break;
        case 'Every month':
          maxInstances = 12;
          break;
        case 'Every year':
          maxInstances = 5;
          break;
        default:
          return;
      }

      final batch = _firestore.batch();
      final List<Map<String, dynamic>> pendingReminders = [];
      int createdCount = 0;
      final now = DateTime.now();

      for (int i = 1; i <= maxInstances; i++) {
        switch (event.repeat) {
          case 'Every day':
            nextEventDate = nextEventDate.add(const Duration(days: 1));
            break;
          case 'Every week':
            nextEventDate = nextEventDate.add(const Duration(days: 7));
            break;
          case 'Every month':
            nextEventDate = DateTime(
              nextEventDate.year,
              nextEventDate.month + 1,
              nextEventDate.day,
              nextEventDate.hour,
              nextEventDate.minute,
            );
            break;
          case 'Every year':
            nextEventDate = DateTime(
              nextEventDate.year + 1,
              nextEventDate.month,
              nextEventDate.day,
              nextEventDate.hour,
              nextEventDate.minute,
            );
            break;
        }

        final duration = event.endTime.difference(event.startTime);
        final newEndTime = nextEventDate.add(duration);

        final repeatEvent = event.copyWith(
          id: null,
          startTime: nextEventDate,
          endTime: newEndTime,
          parentEventId: parentEventId,
        );

        final docRef = _getEventsCollection(event.userId).doc();
        batch.set(docRef, repeatEvent.toMap());

        // Save reminder info for scheduling after batch commit
        if (nextEventDate.isAfter(now) && reminderMinutes > 0) {
          pendingReminders.add({
            'userId': event.userId,
            'eventId': docRef.id,
            'eventTitle': event.title,
            'eventTime': nextEventDate,
            'minutesBefore': reminderMinutes,
          });
        }

        createdCount++;
      }

      await batch.commit();

      // Schedule reminders for all repeat instances
      for (var reminderInfo in pendingReminders) {
        try {
          await _scheduleEventReminder(
            userId: reminderInfo['userId'],
            eventId: reminderInfo['eventId'],
            eventTitle: reminderInfo['eventTitle'],
            eventTime: reminderInfo['eventTime'],
            minutesBefore: reminderInfo['minutesBefore'],
          );
        } catch (e) {
          debugPrint('Failed to schedule reminder for repeat instance: $e');
        }
      }

      debugPrint('Created $createdCount repeat instances with reminders');
    } catch (e) {
      debugPrint('Error creating repeat instances: $e');
    }
  }

  // Schedule single event reminder
  Future<void> _scheduleEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventTime,
    required int minutesBefore,
  }) async {
    try {
      final now = DateTime.now();
      final reminderTime = _calculateReminderTime(eventTime, minutesBefore);

      if (reminderTime.isBefore(now)) {
        debugPrint('Reminder time is in the past, skipping');
        return;
      }

      final notificationId = _generateNotificationId(eventId, minutesBefore);

      // Schedule local notification
      try {
        await _notificationHelper.scheduleNotification(
          id: notificationId,
          title: _getReminderTitle(minutesBefore),
          body: '$eventTitle - ${_formatTime(eventTime)}',
          scheduledDate: reminderTime,
          payload: 'event_reminder:$eventId',
        );

        debugPrint('Scheduled reminder: $minutesBefore min before at $reminderTime');
      } catch (e) {
        debugPrint('Failed to schedule notification: $e');
        return;
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
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  // Calculate reminder time
  DateTime _calculateReminderTime(DateTime eventTime, int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return eventTime.subtract(Duration(days: days));
    } else {
      return eventTime.subtract(Duration(minutes: minutes));
    }
  }

  // Get reminder title for notification
  String _getReminderTitle(int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return 'Event Tomorrow' + (days > 1 ? ' (in $days days)' : '');
    } else if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return 'Event in $hours hour${hours > 1 ? 's' : ''}';
    } else {
      return 'Event in $minutes minutes';
    }
  }

  // Generate unique notification ID
  int _generateNotificationId(String eventId, int minutes) {
    return (eventId.hashCode + minutes).abs() % 2147483647;
  }

  // Save reminder to Firestore
  Future<void> _saveReminderToFirestore({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventTime,
    required DateTime reminderTime,
    required int minutesBefore,
    required int notificationId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('event_reminders')
        .doc('${eventId}_${minutesBefore}min')
        .set({
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventTime': Timestamp.fromDate(eventTime),
      'reminderTime': Timestamp.fromDate(reminderTime),
      'minutesBefore': minutesBefore,
      'notificationId': notificationId,
      'createdAt': FieldValue.serverTimestamp(),
      'isProcessed': false,
    });
  }

  // Cancel all reminders for an event
  Future<void> _cancelAllEventReminders(String userId, String eventId) async {
    try {
      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('event_reminders')
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var doc in remindersSnapshot.docs) {
        final notificationId = doc.data()['notificationId'] as int;
        await _notificationHelper.cancelNotification(notificationId);
        await doc.reference.delete();
      }

      debugPrint('Cancelled ${remindersSnapshot.docs.length} reminders for event $eventId');
    } catch (e) {
      debugPrint('Error cancelling reminders: $e');
    }
  }

  // Format time for display
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Update event with reschedule reminders
  Future<void> updateEvent(String userId, Event event) async {
    try {
      final docRef = _getEventsCollection(userId).doc(event.id);
      final oldDocSnapshot = await docRef.get();

      if (!oldDocSnapshot.exists) {
        throw Exception("Event not found");
      }

      final oldData = oldDocSnapshot.data() as Map<String, dynamic>;
      final String oldRepeat = oldData['repeat'] ?? 'Does not repeat';

      // Update event data
      await docRef.update(event.toMap());

      // Cancel old reminders
      await _cancelAllEventReminders(userId, event.id!);

      // Schedule new reminder
      final reminderMinutes = _reminderToMinutes(event.reminder);
      if (reminderMinutes > 0) {
        await _scheduleEventReminder(
          userId: userId,
          eventId: event.id!,
          eventTitle: event.title,
          eventTime: event.startTime,
          minutesBefore: reminderMinutes,
        );
      }

      // Handle repeat changes
      if (oldRepeat == 'Does not repeat' && event.repeat != 'Does not repeat') {
        await _createRepeatInstances(event, event.id!, reminderMinutes);
      } else if (oldRepeat != 'Does not repeat' && event.repeat != oldRepeat) {
        await _deleteChildEvents(userId, event.id!);
        if (event.repeat != 'Does not repeat') {
          await _createRepeatInstances(event, event.id!, reminderMinutes);
        }
      } else if (oldRepeat != 'Does not repeat' && event.repeat == 'Does not repeat') {
        await _deleteChildEvents(userId, event.id!);
      }

      await _notificationService.createNotification(
        title: 'Event Updated',
        description: 'Event "${event.title}" has been updated',
        type: 'event_updated',
        priority: 'low',
        relatedEventId: event.id,
      );
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Update recurring event with different modes
  Future<void> updateRecurringEvent({
    required String userId,
    required Event event,
    required UpdateMode mode,
  }) async {
    final batch = _firestore.batch();
    final eventsRef = _getEventsCollection(userId);
    final String seriesId = event.parentEventId ?? event.id!;

    try {
      if (mode == UpdateMode.single) {
        // Separate this event from series
        final updatedSingleEvent = event.copyWith(
          id: event.id,
          parentEventId: null,
          repeat: 'Does not repeat',
        );

        batch.update(eventsRef.doc(event.id), updatedSingleEvent.toMap());
        batch.update(eventsRef.doc(event.id), {'parentEventId': FieldValue.delete()});

        await _cancelAllEventReminders(userId, event.id!);

        final reminderMinutes = _reminderToMinutes(event.reminder);
        if (reminderMinutes > 0) {
          await _scheduleEventReminder(
            userId: userId,
            eventId: event.id!,
            eventTitle: event.title,
            eventTime: event.startTime,
            minutesBefore: reminderMinutes,
          );
        }
      } else if (mode == UpdateMode.following) {
        // Delete future events
        final futureEventsQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .where('startTime', isGreaterThan: Timestamp.fromDate(event.startTime))
            .get();

        for (var doc in futureEventsQuery.docs) {
          batch.delete(doc.reference);
          await _cancelAllEventReminders(userId, doc.id);
        }

        // Update this event as new parent
        final newParentEvent = event.copyWith(
          id: event.id,
          parentEventId: null,
        );

        batch.set(eventsRef.doc(event.id), newParentEvent.toMap());

        if (event.parentEventId != null) {
          batch.update(eventsRef.doc(event.id), {'parentEventId': FieldValue.delete()});
        }

        await batch.commit();

        await _cancelAllEventReminders(userId, event.id!);

        final reminderMinutes = _reminderToMinutes(event.reminder);
        if (reminderMinutes > 0) {
          await _scheduleEventReminder(
            userId: userId,
            eventId: event.id!,
            eventTitle: event.title,
            eventTime: event.startTime,
            minutesBefore: reminderMinutes,
          );
        }

        // Create new series from this point
        if (newParentEvent.repeat != 'Does not repeat') {
          await _createRepeatInstances(newParentEvent, newParentEvent.id!, reminderMinutes);
        }
        return;
      } else if (mode == UpdateMode.all) {
        // Delete parent
        batch.delete(eventsRef.doc(seriesId));
        await _cancelAllEventReminders(userId, seriesId);

        // Delete all children
        final allChildrenQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .get();

        for (var doc in allChildrenQuery.docs) {
          batch.delete(doc.reference);
          await _cancelAllEventReminders(userId, doc.id);
        }

        await batch.commit();

        // Create fresh event
        final freshEvent = event.copyWith(id: null, parentEventId: null);
        await addEvent(freshEvent);
        return;
      }

      await batch.commit();

      await _notificationService.createNotification(
        title: 'Event Series Updated',
        description: 'Recurring event "${event.title}" updated',
        type: 'event_updated',
        priority: 'low',
        relatedEventId: event.id,
      );
    } catch (e) {
      throw Exception('Failed to update recurring event: $e');
    }
  }

  // Delete recurring event with different modes
  Future<void> deleteRecurringEvent({
    required String userId,
    required Event event,
    required DeleteMode mode,
  }) async {
    final eventsRef = _getEventsCollection(userId);
    final batch = _firestore.batch();

    try {
      final String seriesId = event.parentEventId ?? event.id!;

      if (mode == DeleteMode.single) {
        batch.delete(eventsRef.doc(event.id));
        await _cancelAllEventReminders(userId, event.id!);
      } else if (mode == DeleteMode.following) {
        batch.delete(eventsRef.doc(event.id));
        await _cancelAllEventReminders(userId, event.id!);

        final futureEvents = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .where('startTime', isGreaterThan: Timestamp.fromDate(event.startTime))
            .get();

        for (var doc in futureEvents.docs) {
          batch.delete(doc.reference);
          await _cancelAllEventReminders(userId, doc.id);
        }

        if (event.id == seriesId) {
          batch.delete(eventsRef.doc(seriesId));
        }
      } else if (mode == DeleteMode.all) {
        batch.delete(eventsRef.doc(seriesId));
        await _cancelAllEventReminders(userId, seriesId);

        final childrenQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .get();

        for (var doc in childrenQuery.docs) {
          batch.delete(doc.reference);
          await _cancelAllEventReminders(userId, doc.id);
        }
      }

      await batch.commit();
      debugPrint('Deleted recurring event with all reminders');
    } catch (e) {
      throw Exception('Failed to delete recurring event: $e');
    }
  }

  // Delete single event
  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _getEventsCollection(userId).doc(eventId).delete();
      await _cancelAllEventReminders(userId, eventId);
      debugPrint('Deleted event $eventId with reminders');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Delete all child events
  Future<void> _deleteChildEvents(String userId, String parentEventId) async {
    final eventsRef = _getEventsCollection(userId);
    final batch = _firestore.batch();

    final childrenQuery = await eventsRef
        .where('parentEventId', isEqualTo: parentEventId)
        .get();

    for (var doc in childrenQuery.docs) {
      batch.delete(doc.reference);
      await _cancelAllEventReminders(userId, doc.id);
    }

    await batch.commit();
  }

  // Get events for month
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

  // Get events for specific date
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

  // Get all events
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

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationHelper.getPendingNotifications();
  }

  // Get reminders for specific event
  Stream<List<Map<String, dynamic>>> getEventReminders(String userId, String eventId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('event_reminders')
        .where('eventId', isEqualTo: eventId)
        .orderBy('minutesBefore')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}