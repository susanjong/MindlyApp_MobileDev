import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:notesapp/features/home/data/services/notification_helper.dart';
import '../../presentation/widgets/delete_repeated_event.dart';
import '../../presentation/widgets/update_repeated_dialog.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final NotificationHelper _notificationHelper = NotificationHelper();

  // Helper untuk mendapatkan referensi koleksi event user
  CollectionReference _getEventsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('events');
  }

  // --- CRUD DASAR ---

  // Menambahkan event baru (single atau recurring)
  Future<String> addEvent(Event event) async {
    try {
      // Simpan event utama (parent)
      DocumentReference docRef = await _getEventsCollection(event.userId).add(event.toMap());

      // Jika event berulang, buat instance turunannya
      if (event.repeat != 'Does not repeat') {
        await _createRepeatInstances(event, docRef.id);
      }

      // Kirim notifikasi sistem (in-app log)
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

  // Memperbarui event tunggal dan menangani perubahan status 'repeat'
  Future<void> updateEvent(String userId, Event event) async {
    try {
      final docRef = _getEventsCollection(userId).doc(event.id);
      final oldDocSnapshot = await docRef.get();
      if (!oldDocSnapshot.exists) throw Exception("Event not found");

      final oldData = oldDocSnapshot.data() as Map<String, dynamic>;
      final String oldRepeat = oldData['repeat'] ?? 'Does not repeat';

      // Update data event utama
      await docRef.update(event.toMap());

      // Logika perubahan tipe repeat (Single -> Repeat, Repeat -> Change, Repeat -> Single)
      if (oldRepeat == 'Does not repeat' && event.repeat != 'Does not repeat') {
        await _createRepeatInstances(event, event.id!);
      } else if (oldRepeat != 'Does not repeat' && event.repeat != oldRepeat) {
        // Hapus instance lama, buat yang baru
        await _deleteChildEvents(userId, event.id!);
        if (event.repeat != 'Does not repeat') {
          await _createRepeatInstances(event, event.id!);
        }
      } else if (oldRepeat != 'Does not repeat' && event.repeat == 'Does not repeat') {
        // Hapus semua anak, event ini menjadi single
        await _deleteChildEvents(userId, event.id!);
      }

      await _notificationService.createNotification(
        title: '📝 Event Updated',
        description: 'Event "${event.title}" has been updated',
        type: 'event_updated', // Typo fixed from original code 'event_created'
        priority: 'low',
        relatedEventId: event.id,
      );
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Menghapus event tunggal
  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _getEventsCollection(userId).doc(eventId).delete();
      await _cancelScheduledNotification(eventId);
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // --- LOGIKA RECURRING EVENT (BERULANG) ---

  // Membuat instance duplikat untuk event berulang menggunakan Batch Write
  Future<void> _createRepeatInstances(Event event, String parentEventId) async {
    try {
      int maxInstances;
      DateTime nextEventDate = event.startTime;

      // Tentukan batas pengulangan
      switch (event.repeat) {
        case 'Every day': maxInstances = 30; break;
        case 'Every week': maxInstances = 12; break;
        case 'Every month': maxInstances = 12; break;
        case 'Every year': maxInstances = 5; break;
        default: return;
      }

      final batch = _firestore.batch();
      int createdCount = 0;

      for (int i = 1; i <= maxInstances; i++) {
        // Kalkulasi tanggal berikutnya berdasarkan tipe repeat
        switch (event.repeat) {
          case 'Every day':
            nextEventDate = nextEventDate.add(const Duration(days: 1));
            break;
          case 'Every week':
            nextEventDate = nextEventDate.add(const Duration(days: 7));
            break;
          case 'Every month':
            nextEventDate = DateTime(
              nextEventDate.year, nextEventDate.month + 1, nextEventDate.day,
              nextEventDate.hour, nextEventDate.minute,
            );
            break;
          case 'Every year':
            nextEventDate = DateTime(
              nextEventDate.year + 1, nextEventDate.month, nextEventDate.day,
              nextEventDate.hour, nextEventDate.minute,
            );
            break;
        }

        final duration = event.endTime.difference(event.startTime);
        final newEndTime = nextEventDate.add(duration);

        // Buat objek event turunan
        final repeatEvent = event.copyWith(
          id: null, // ID baru akan digenerate Firestore
          startTime: nextEventDate,
          endTime: newEndTime,
          parentEventId: parentEventId,
        );

        final docRef = _getEventsCollection(event.userId).doc();
        batch.set(docRef, repeatEvent.toMap());
        createdCount++;
      }

      await batch.commit();
      if (kDebugMode) print('✅ Created $createdCount repeat instances for "${event.title}"');

    } catch (e) {
      if (kDebugMode) print('❌ Error creating repeat instances: $e');
    }
  }

  // Menangani update pada event berulang (Single, Following, atau All)
  Future<void> updateRecurringEvent({
    required String userId,
    required Event originalEvent,
    required Event newEvent,
    required UpdateMode mode,
  }) async {
    final batch = _firestore.batch();
    final eventsRef = _getEventsCollection(userId);
    final String seriesId = originalEvent.parentEventId ?? originalEvent.id!;

    try {
      if (mode == UpdateMode.single) {
        // Pisahkan event ini dari rangkaian (jadi single event)
        final updatedSingleEvent = newEvent.copyWith(
          id: originalEvent.id,
          parentEventId: null,
          repeat: 'Does not repeat',
        );

        // Update event ini dan hapus referensi parent-nya
        batch.update(eventsRef.doc(originalEvent.id), updatedSingleEvent.toMap());
        batch.update(eventsRef.doc(originalEvent.id), {'parentEventId': FieldValue.delete()});
      }

      else if (mode == UpdateMode.following) {
        // Hapus semua event masa depan dalam rangkaian ini
        final futureEventsQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .where('startTime', isGreaterThan: Timestamp.fromDate(originalEvent.startTime))
            .get();

        for (var doc in futureEventsQuery.docs) {
          batch.delete(doc.reference);
        }

        // Update event ini menjadi 'parent' baru untuk rangkaian baru
        final newParentEvent = newEvent.copyWith(
          id: originalEvent.id,
          parentEventId: null,
        );

        batch.set(eventsRef.doc(originalEvent.id), newParentEvent.toMap());
        // Hapus parentId lama jika ada (memutus dari rangkaian lama)
        if (originalEvent.parentEventId != null) {
          batch.update(eventsRef.doc(originalEvent.id), {'parentEventId': FieldValue.delete()});
        }

        await batch.commit();

        // Buat ulang rangkaian baru dari titik ini
        if (newParentEvent.repeat != 'Does not repeat') {
          await _createRepeatInstances(newParentEvent, newParentEvent.id!);
        }
        return; // Return early karena logic commit berbeda
      }

      else if (mode == UpdateMode.all) {
        // Hapus parent utama
        batch.delete(eventsRef.doc(seriesId));

        // Hapus semua anak
        final allChildrenQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .get();

        for (var doc in allChildrenQuery.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        // Buat ulang event baru sebagai parent baru (fresh start)
        final freshEvent = newEvent.copyWith(id: null, parentEventId: null);
        await addEvent(freshEvent);
        return;
      }

      await batch.commit();

      await _notificationService.createNotification(
        title: '📝 Event Series Updated',
        description: 'Recurring event "${newEvent.title}" updated',
        type: 'event_updated',
        priority: 'low',
        relatedEventId: originalEvent.id,
      );

    } catch (e) {
      throw Exception('Failed to update recurring event: $e');
    }
  }

  // Menangani penghapusan event berulang (Single, Following, atau All)
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
        // Hapus hanya satu event ini
        batch.delete(eventsRef.doc(event.id));
      }
      else if (mode == DeleteMode.following) {
        // Hapus event ini
        batch.delete(eventsRef.doc(event.id));

        // Hapus event-event selanjutnya
        final futureEvents = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .where('startTime', isGreaterThan: Timestamp.fromDate(event.startTime))
            .get();

        for (var doc in futureEvents.docs) {
          batch.delete(doc.reference);
        }

        // Jika yang dihapus adalah parent, hapus juga doc parent-nya
        if (event.id == seriesId) {
          batch.delete(eventsRef.doc(seriesId));
        }
      }
      else if (mode == DeleteMode.all) {
        // Hapus parent utama
        batch.delete(eventsRef.doc(seriesId));

        // Hapus semua anak
        final childrenQuery = await eventsRef
            .where('parentEventId', isEqualTo: seriesId)
            .get();

        for (var doc in childrenQuery.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
      await _cancelScheduledNotification(event.id!);

    } catch (e) {
      debugPrint("Error deleting recurring event: $e");
      throw Exception('Failed to delete recurring event: $e');
    }
  }

  // Helper: Menghapus semua event turunan (child)
  Future<void> _deleteChildEvents(String userId, String parentEventId) async {
    final eventsRef = _getEventsCollection(userId);
    final batch = _firestore.batch();

    final childrenQuery = await eventsRef
        .where('parentEventId', isEqualTo: parentEventId)
        .get();

    for (var doc in childrenQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // --- LOGIKA NOTIFIKASI & PENGINGAT ---

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
        print('Event: $eventTitle, Time: $reminderTime');
      }

      if (reminderTime.isBefore(now)) {
        if (kDebugMode) print('⚠️ Reminder time is in the past, skipping.');
        return;
      }

      // Generate ID unik untuk notifikasi berdasarkan event ID
      final notificationId = eventId.hashCode;
      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      // Jadwalkan notifikasi lokal
      await _notificationHelper.scheduleNotification(
        id: notificationId,
        title: 'Reminder: $eventTitle',
        body: 'Event starts in $minutesBefore minutes (${_formatTime(eventTime)})',
        scheduledDate: scheduledDate,
      );

      // Simpan log pengingat ke Firestore
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
      if (kDebugMode) print('❌ Error scheduling reminder: $e');
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
      'isProcessed': false,
    });
  }

  Future<void> _cancelScheduledNotification(String eventId) async {
    final notificationId = eventId.hashCode;
    await _notificationHelper.cancelNotification(notificationId);
  }

  // --- QUERY & GETTERS ---

  // Mengambil event untuk satu bulan penuh (Filter di level query)
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

  // Mengambil event untuk satu hari spesifik
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

  // Mengambil semua event (misalnya untuk pencarian atau view tahunan)
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

  // Helper format waktu (HH:mm AM/PM)
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}