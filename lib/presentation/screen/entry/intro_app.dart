import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/routes/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';

// app colors
class AppColors {
  static const Color primary = Color(0xFFD732A8);
  static const Color secondary = Color(0xFF5683EB);
  static const Color logo = Color(0xFF004455);
  static const Color accent = Color(0xFFBEE973);
  static const Color textGrey = Color(0xFF615F5F);
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              _buildDecorativeCircles(),

              // main content
              Positioned.fill(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _buildLogoAndTagline(),
                    const Spacer(flex: 1),
                    _buildButtons(context),
                    const SizedBox(height: 24),
                    _buildTermsAndPrivacy(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // blue circle
        Positioned(
          left: -168.54,
          top: 49,
          child: Container(
            width: 366.04,
            height: 366.04,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // pink circle
        Positioned(
          right: -100,
          top: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // green circle
        Positioned(
          right: -64.39,
          top: 274.53,
          child: Container(
            width: 151.47,
            height: 151.47,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoAndTagline() {
    return Container(
      margin: const EdgeInsets.only(top: 350),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // logo and app name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.logo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SvgPicture.asset(
                    'assets/images/Mindly_logo.svg',
                    width: 48,
                    height: 46,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                'Mindly',
                style: GoogleFonts.poppins(
                  color: AppColors.logo,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.80,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // tagline
          Text(
            'Transform your Productivity',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // get started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.signUp);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.25),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // sign in button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.signIn);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.25),
              ),
              child: Text(
                'Already have an account? Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            color: AppColors.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.50,
            letterSpacing: -0.26,
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  // todo: change this Navigator.pushNamed(context, AppRoutes.termsOfService);
                },
                child: Text(
                  'Terms of Service',
                  style: GoogleFonts.poppins(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    height: 1.50,
                    letterSpacing: -0.26,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  // todo: change this Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                },
                child: Text(
                  'Privacy Policy',
                  style: GoogleFonts.poppins(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    height: 1.50,
                    letterSpacing: -0.26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}