import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';

class OverdueCheckerService {
  static Timer? _timer;
  static final NotificationService _notificationService = NotificationService();

  // Start periodic check (every 1 minute for better precision for reminders)
  static void startPeriodicCheck() {
    _checkAll();

    // Cek setiap 1 menit (karena reminder event butuh lebih presisi daripada overdue task)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAll();
    });

    debugPrint('Reminder & Overdue checker service started');
  }

  static void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
    debugPrint('⏹️ Checker service stopped');
  }

  static Future<void> _checkAll() async {
    // 1. Cek Task Overdue
    await _checkOverdueTasks();
    // 2. Cek Event Reminder yang jatuh tempo
    await _checkEventReminders();
  }

  static Future<void> _checkOverdueTasks() async {
    try {
      await _notificationService.checkAndNotifyOverdueTasks();
    } catch (e) {
      debugPrint('❌ Error checking overdue tasks: $e');
    }
  }

  // Panggil fungsi baru dari NotificationService
  static Future<void> _checkEventReminders() async {
    try {
      await _notificationService.checkAndNotifyEventReminders();
    } catch (e) {
      debugPrint('❌ Error checking event reminders: $e');
    }
  }
}