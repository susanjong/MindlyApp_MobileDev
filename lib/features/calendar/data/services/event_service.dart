import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:notesapp/features/home/data/services/notification_helper.dart';
import '../../presentation/widgets/delete_repeated_event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final NotificationHelper _notificationHelper = NotificationHelper();

  CollectionReference _getEventsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('events');
  }

  // ✅ PERBAIKAN: Tambahkan logic untuk repeat events
  Future<String> addEvent(Event event) async {
    try {
      DocumentReference docRef = await _getEventsCollection(event.userId).add(event.toMap());

      // ✅ Handle repeat events dengan BATASAN
      if (event.repeat != 'Does not repeat') {
        await _createRepeatInstances(event, docRef.id);
      }

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

  // ✅ PERBAIKAN: Batasi repeat instances
  Future<void> _createRepeatInstances(Event event, String parentEventId) async {
    try {
      int maxInstances;
      DateTime nextEventDate = event.startTime;

      // ✅ Batasi jumlah repeat berdasarkan tipe
      switch (event.repeat) {
        case 'Every day':
          maxInstances = 30; // 1 bulan
          break;
        case 'Every week':
          maxInstances = 12; // 3 bulan
          break;
        case 'Every month':
          maxInstances = 12; // 1 tahun
          break;
        case 'Every year':
          maxInstances = 5; // 5 tahun
          break;
        default:
          return;
      }

      final batch = _firestore.batch();
      int createdCount = 0;

      for (int i = 1; i <= maxInstances; i++) {
        // ✅ Hitung tanggal berikutnya
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

        createdCount++;
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Created $createdCount repeat instances for "${event.title}"');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating repeat instances: $e');
      }
    }
  }

  // ✅ PERBAIKAN: Schedule reminder dengan error handling
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

      // ✅ PERBAIKAN: Pastikan timezone sudah diinisialisasi
      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      // Schedule notification
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

      // ✅ Create in-app notification
      await _notificationService.createNotification(
        title: '⏰ Reminder Set',
        description: 'You will be reminded about "$eventTitle" ${_getTimeUntilMessage(reminderTime)}',
        type: 'event_reminder',
        priority: 'high',
        relatedEventId: eventId,
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling reminder: $e');
      }
      rethrow;
    }
  }

  // ✅ Helper untuk format waktu tersisa
  String _getTimeUntilMessage(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'now';
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
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('event_reminders')
        .doc(eventId)
        .set({
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

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // ✅ Method lainnya tetap sama
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

  Future<void> deleteRecurringEvent({
    required String userId,
    required Event event,
    required DeleteMode mode,
  }) async {
    final eventsRef = _getEventsCollection(userId);
    final batch = _firestore.batch();

    try {
      // Logic ID: Jika parentEventId null, maka event ini adalah Parent-nya
      final String seriesId = event.parentEventId ?? event.id!;

      if (mode == DeleteMode.single) {
        // 1. Hapus event ini saja (Single instance)
        batch.delete(eventsRef.doc(event.id));
      }
      else if (mode == DeleteMode.all) {
        // 2. Hapus Parent (Master)
        batch.delete(eventsRef.doc(seriesId));

        // 3. Hapus semua Anak (Children)
        final childrenQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .get();

        for (var doc in childrenQuery.docs) {
          batch.delete(doc.reference);
        }
      }
      else if (mode == DeleteMode.following) {
        // 4. Hapus event ini
        batch.delete(eventsRef.doc(event.id));

        // 5. Hapus semua event yang parent-nya sama DAN waktunya setelah event ini
        // NOTE: Firestore membutuhkan Composite Index untuk query ini
        // (parentEventId == X AND startTime > Y)
        final futureEvents = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .where('startTime', isGreaterThan: Timestamp.fromDate(event.startTime))
            .get();

        for (var doc in futureEvents.docs) {
          batch.delete(doc.reference);
        }

        // Edge Case: Jika kita menghapus "Following" dari Parent-nya langsung
        if (event.id == seriesId) {
          // Logic tambahan mungkin diperlukan jika parent dihapus tapi child sebelumnya ingin disimpan
          // Tapi untuk simplifikasi, biasanya hapus parent = hapus akses ke series.
        }
      }

      await batch.commit();

      // Cancel notifikasi terkait
      if (mode == DeleteMode.single) {
        await _cancelScheduledNotification(event.id!);
      } else {
        // TODO: Logic cancel notifikasi batch (opsional, butuh iterasi ID)
      }

    } catch (e) {
      throw Exception('Failed to delete recurring event: $e');
    }
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

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationHelper.getPendingNotifications();
  }
}