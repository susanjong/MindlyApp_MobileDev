import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'config/routes/routes.dart';
import 'firebase_options.dart';
import 'features/home/data/services/notification_service.dart';
import 'features/home/data/services/overdue_checker_service.dart';
import 'package:notesapp/features/home/data/services/notification_helper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Initialize notification helper (for scheduled notifications)
    await NotificationHelper().initialize();

    // Initialize notification service (for in-app notifications)
    await NotificationService.initialize();

    // Start overdue tasks checker
    OverdueCheckerService.startPeriodicCheck();

    debugPrint('All services initialized successfully');

  } catch (e) {
    debugPrint('❌ Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}