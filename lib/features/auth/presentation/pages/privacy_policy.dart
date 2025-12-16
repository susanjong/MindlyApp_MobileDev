import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = screenWidth < 400 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // top navigation bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // back button icon
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                  const SizedBox(width: 12),

                  // page title text
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.48,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // horizontal divider line
            Container(
              height: 1,
              color: const Color(0x9B999191),
            ),

            // scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // application name and logo section
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // application logo svg
                                SizedBox(
                                  width: 32.36,
                                  height: 30,
                                  child: SvgPicture.asset(
                                    'assets/images/Mindly_logo.svg',
                                    width: 32.36,
                                    height: 30,
                                    fit: BoxFit.contain,
                                    placeholderBuilder: (context) => Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF004455),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // application name text
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Mindly',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF004455),
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            height: 1,
                                            letterSpacing: -0.60,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // application tagline text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Transform Your Productivity',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                letterSpacing: -0.30,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // last updated date badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Last Updated: November 27, 2024',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          letterSpacing: -0.24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildIntroSection(isSmallScreen),

                    const SizedBox(height: 24),

                    _buildSection(
                      number: '1',
                      title: 'Information We Collect',
                      content:
                      'We collect your name, email, and notes you create in Mindly when you use our services.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '2',
                      title: 'How We Use Your Information',
                      content:
                      'We use your information to provide and improve our services, and to personalize your experience.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '3',
                      title: 'Data Security',
                      content:
                      'Your data is encrypted and protected with industry-standard security measures.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '4',
                      title: 'Data Sharing',
                      content:
                      'We do not sell your personal information to third parties.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '5',
                      title: 'Your Rights',
                      content:
                      'You can access, update, or delete your data anytime through app settings.',
                      isLast: true,
                      isSmallScreen: isSmallScreen,
                    ),

                    const SizedBox(height: 32),

                    _buildPrivacyCommitmentCard(isSmallScreen),

                    const SizedBox(height: 44),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // build privacy introduction section with gradient background
  Widget _buildIntroSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF004455),
            Color(0xFF006677),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004455).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // shield icon container with semi-transparent background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // section title text
              Expanded(
                child: Text(
                  'Your Privacy is Protected',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.36,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // description paragraph text
          Text(
            'We are committed to protecting your privacy and ensuring the security of your personal information.',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.5,
              letterSpacing: -0.28,
            ),
          ),
        ],
      ),
    );
  }

  // build privacy commitment card with border
  Widget _buildPrivacyCommitmentCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF004455).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // verified user icon
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF004455),
                size: 24,
              ),
              const SizedBox(width: 12),
              // commitment card title
              Expanded(
                child: Text(
                  'Our Commitment',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF004455),
                    letterSpacing: -0.36,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // first commitment item with icon
          _buildCommitmentItem(
            icon: Icons.lock_outline,
            text: 'End-to-end encryption',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          // second commitment item with icon
          _buildCommitmentItem(
            icon: Icons.block_outlined,
            text: 'No data selling to third parties',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          // third commitment item with icon
          _buildCommitmentItem(
            icon: Icons.delete_outline,
            text: 'Full control of your data',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  // build single commitment item row with icon and text
  Widget _buildCommitmentItem({
    required IconData icon,
    required String text,
    required bool isSmallScreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // commitment icon
        Icon(
          icon,
          color: const Color(0xFF5784EB),
          size: 20,
        ),
        const SizedBox(width: 12),
        // commitment description text
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.5,
              letterSpacing: -0.28,
            ),
          ),
        ),
      ],
    );
  }

  // build numbered privacy policy section with badge
  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    bool isLast = false,
    bool isSmallScreen = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // circular number badge container
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5784EB).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // section title heading
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.36,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // section content paragraph with left padding
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.5,
                letterSpacing: -0.28,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}