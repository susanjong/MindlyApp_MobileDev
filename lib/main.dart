import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart'; // Import your signup screen

// Firebase configuration options
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these values with your Firebase project configuration
    // You can get these from Firebase Console -> Project Settings -> General -> Your apps
    return const FirebaseOptions(
        apiKey: 'AIzaSyDrt7OkInJiVpUqKNggpG22FkD4CsRg0WA',
    appId: '1:16618628362:android:e11d2ba09588757aacc6f3',
    messagingSenderId: '16618628362',
    projectId: 'appnotes-4be34',
    storageBucket: 'appnotes-4be34.appspot.com',
  );
  }
}

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
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
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
      initialRoute: '/',
    );
  }
}

// Auth wrapper to check if user is already logged in
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.purple.shade50,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Initializing...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          print('User is logged in: ${snapshot.data!.email}');
          return HomeScreen();
        } else {
          print('User is not logged in');
          return CreateAccountScreen();
        }
      },
    );
  }
}

// Enhanced Error Handler Widget
class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({Key? key, required this.error}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade600,
                ),
                SizedBox(height: 20),
                Text(
                  'Firebase Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Please check your Firebase configuration',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}