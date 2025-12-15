import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';
import 'package:notesapp/features/to_do_list/data/services/todo_services.dart';

class OverdueCheckerService {
  static Timer? _timer;
  static final NotificationService _notificationService = NotificationService();
  static final TodoService _todoService = TodoService();

  // Start periodic check (every 1 hour)
  static void startPeriodicCheck() {
    // Check immediately on start
    _checkOverdueTasks();
    // check every hour
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkOverdueTasks();
    });

    debugPrint('✅ Overdue checker service started');
  }

  // stop periodic check
  static void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
    debugPrint('⏹️ Overdue checker service stopped');
  }

  // manual check for overdue tasks
  static Future<void> _checkOverdueTasks() async {
    try {
      await _notificationService.checkAndNotifyOverdueTasks();
      debugPrint('🔍 Checked for overdue tasks at ${DateTime.now()}');
    } catch (e) {
      debugPrint('❌ Error checking overdue tasks: $e');
    }
  }
}

