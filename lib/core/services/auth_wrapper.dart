import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import 'package:notesapp/features/home/presentation/pages/home.dart';
import 'package:notesapp/features/auth/presentation/pages/email_verification_screen.dart';
import 'package:notesapp/features/auth/presentation/pages/intro_app.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF4000),
              ),
            ),
          );
        }

        // User tidak login -> ke Intro/Welcome Screen
        if (!snapshot.hasData || snapshot.data == null) {
          return const WelcomeScreen();
        }

        final user = snapshot.data!;

        // google sign in-> Langsung ke Home (sudah verified)
        final provider = AuthService.getAuthProvider();
        if (provider == 'google.com') {
          return const HomePage();
        }

        // email/pass sign in-> Cek verification
        if (user.emailVerified) {
          // Email sudah diverifikasi -> ke Home
          return const HomePage();
        } else {
          // Email belum diverifikasi -> ke Verification Screen
          return const EmailVerificationScreen();
        }
      },
    );
  }
}