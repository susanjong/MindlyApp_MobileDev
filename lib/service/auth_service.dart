// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Tambahkan scopes jika diperlukan
    scopes: [
      'email',
      'profile',
    ],
  );

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Stream untuk mendengarkan perubahan auth state
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google - Improved version
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      
      // Pastikan Google Sign-In tersedia
      final bool isAvailable = await _googleSignIn.isSignedIn();
      print('Google Sign-In availability check: $isAvailable');
      
      // Sign out dari sesi sebelumnya untuk memastikan fresh login
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('User cancelled Google Sign-In');
        return null;
      }
      
      print('Google user signed in: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Failed to get Google auth tokens');
        throw Exception('Failed to get Google authentication tokens');
      }
      
      print('Got Google auth tokens successfully');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('Firebase sign-in successful: ${userCredential.user?.email}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('An account already exists with a different credential');
        case 'invalid-credential':
          throw Exception('Invalid credential provided');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled in Firebase Console');
        case 'user-disabled':
          throw Exception('User account has been disabled');
        default:
          throw Exception('Google Sign-In failed: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error during Google Sign-In: $e');
      if (e.toString().contains('network')) {
        throw Exception('Network error. Please check your internet connection');
      }
      throw Exception('Google Sign-In failed. Please try again');
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during email sign-in: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Wrong password provided');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('User account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later');
        default:
          throw Exception('Sign-in failed: ${e.message}');
      }
    } catch (e) {
      print('Error signing in with email: $e');
      throw Exception('Sign-in failed. Please try again');
    }
  }

  // Create account with email and password
  static Future<UserCredential?> createAccountWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during account creation: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak');
        case 'email-already-in-use':
          throw Exception('An account already exists with this email');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception('Account creation failed: ${e.message}');
      }
    } catch (e) {
      print('Error creating account: $e');
      throw Exception('Account creation failed. Please try again');
    }
  }

  // Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw Exception('No user signed in');
      }
    } catch (e) {
      print('Error sending email verification: $e');
      throw Exception('Failed to send verification email');
    }
  }

  // Check if email is verified
  static bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reload user to get updated verification status
  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: $e');
      throw Exception('Failed to refresh user data');
    }
  }

  // Sign out - Improved version
  static Future<void> signOut() async {
    try {
      // Sign out dari Google terlebih dahulu
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Kemudian sign out dari Firebase
      await _auth.signOut();
      
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Sign-out failed');
    }
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Get user display name
  static String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  // Get user email
  static String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get user photo URL
  static String? getUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }

  // Method untuk testing koneksi Google Sign-In
  static Future<bool> testGoogleSignInAvailability() async {
    try {
      final bool isAvailable = await _googleSignIn.isSignedIn();
      print('Google Sign-In is available: $isAvailable');
      return true;
    } catch (e) {
      print('Google Sign-In not available: $e');
      return false;
    }
  }
}