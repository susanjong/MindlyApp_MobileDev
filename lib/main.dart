import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// timezone
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

// app
import 'firebase_options.dart';
import 'config/routes/routes.dart';
import 'features/home/data/services/notification_service.dart';
import 'features/home/data/services/notification_helper.dart';
import 'features/home/data/services/overdue_checker_service.dart';
import 'features/home/data/services/background_notification_server.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // timezone
    tzdata.initializeTimeZones();

    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();

      // handle semua kemungkinan return type
      final String timeZoneName = tzResult is String
          ? tzResult
          : tzResult.toString();

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('Failed to get timezone, fallback to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // notification
    await NotificationHelper().initialize();
    await NotificationService.initialize();

    // background server
    OverdueCheckerService.startPeriodicCheck();
    BackgroundNotificationService().startPeriodicCheck();

    debugPrint('All services initialized successfully');
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final BackgroundNotificationService _bgService =
  BackgroundNotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgService.stopPeriodicCheck();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed, checking reminders...');
      _bgService.checkAndProcessEventReminders();
      _bgService.startPeriodicCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotesApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
