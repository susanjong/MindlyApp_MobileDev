import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/routes/routes.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Deteksi orientasi
    final isPortrait = screenHeight > screenWidth;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: screenHeight,
          child: Stack(
            children: [
              _buildDecorativeCircles(),

              // main content
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Top spacer
                              const Spacer(flex: 12),
                              _buildLogoAndTagline(context),
                              // Center spacer
                              if (isPortrait)
                                const Spacer(flex: 3)
                              else
                                const Spacer(flex: 30),
                              _buildButtons(context),
                              const SizedBox(height: 16),
                              _buildTermsAndPrivacy(context),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

  Widget _buildLogoAndTagline(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = screenHeight > screenWidth;

    // Ukuran font LEBIH BESAR untuk landscape/horizontal
    final appNameSize = isPortrait ? 40.0 : 40.0;
    final taglineSize = isPortrait ? 20.0 : 20.0;
    final logoSize = isPortrait ? 36.0 : 56.0;
    final logoHeight = isPortrait ? 36.0 : 54.0;
    final spacingAfterLogo = isPortrait ? 12.0 : 24.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // logo and app name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoHeight,
                decoration: BoxDecoration(
                  color: AppColors.logo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SvgPicture.asset(
                    'assets/images/Mindly_logo.svg',
                    width: logoSize,
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: isPortrait ? 16 : 24),
              Text(
                'Mindly',
                style: GoogleFonts.poppins(
                  color: AppColors.logo,
                  fontSize: appNameSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.80,
                ),
              ),
            ],
          ),

          SizedBox(height: spacingAfterLogo),

          // tagline
          Text(
            'Transform your Productivity',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: taglineSize,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = screenHeight > screenWidth;

    // Ukuran font dan padding lebih kecil untuk portrait
    final buttonFontSize = isPortrait ? 12.0 : 15.0;
    final horizontalPadding = isPortrait ? 30.0 : 40.0;
    final verticalPadding = isPortrait ? 12.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.25),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.30,
                ),
              ),
            ),
          ),
          SizedBox(height: isPortrait ? 12 : 16),
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
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.25),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Already have an account? Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.30,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndPrivacy(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = screenHeight > screenWidth;

    // font size for potrait mode
    final textSize = isPortrait ? 10.0 : 13.0;
    final horizontalPadding = isPortrait ? 30.0 : 40.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            color: AppColors.textGrey,
            fontSize: textSize,
            fontWeight: FontWeight.w500,
            height: 1.50,
            letterSpacing: -0.26,
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.termsOfService);
                },
                child: Text(
                  'Terms of Service',
                  style: GoogleFonts.poppins(
                    color: AppColors.textGrey,
                    fontSize: textSize,
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
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.PrivacyPolicy);
                },
                child: Text(
                  'Privacy Policy',
                  style: GoogleFonts.poppins(
                    color: AppColors.textGrey,
                    fontSize: textSize,
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