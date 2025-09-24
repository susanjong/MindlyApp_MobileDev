import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notesapp/auth_wrapper.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/home.dart';
import 'package:notesapp/login.dart';
import 'package:notesapp/resetpass.dart';
import 'signup.dart'; // Import your signup screen

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      // Define routes
      routes: {
        '/': (context) => AuthWrapper(),
        '/signup': (context) => CreateAccountScreen(),
        '/login': (context) => LoginAccountScreen(),
        '/home': (context) => HomeScreen(),
        '/reset': (context) => ResetPasswordScreen(),
        '/forgotpass': (context) => ResetPasswordScreen(),

      },
      initialRoute: '/',
    );
  }
}

