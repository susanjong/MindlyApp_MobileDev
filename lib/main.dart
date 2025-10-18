import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notesapp/presentation/screen/splash_screen.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/presentation/screen/home.dart';
import 'package:notesapp/sign/login.dart';
import 'package:notesapp/sign/resetpass.dart';
import 'package:notesapp/sign/signup.dart';
import 'package:notesapp/sign/forgotpass.dart';
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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      
      // Set initial route
      initialRoute: '/',
      
      // Define routes
      routes: {
        '/': (context) => const LogoSplash(),
        '/splash': (context) => const LogoSplash(),
        '/sign_up': (context) => SignUpScreen(),
        '/sign_in': (context) => LoginAccountScreen(),
        '/home': (context) => HomeScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(), 
      },
    );
  }
}