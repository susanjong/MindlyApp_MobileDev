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
            // top app bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // back button
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

                  // Title
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

            // Divider
            Container(
              height: 1,
              color: const Color(0x9B999191),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Name & Logo
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
                                // Logo
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

                                // logo mindly
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

                          // tagline
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

                    // last update badge
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
                      'We collect information you provide directly to us when you create an account, use our services, or communicate with us. This includes your name, email address, and the notes and content you create within Mindly.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '2',
                      title: 'How We Use Your Information',
                      content:
                      'We use the information we collect to provide, maintain, and improve our services, to communicate with you, to monitor and analyze trends and usage, and to personalize your experience with Mindly.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '3',
                      title: 'Data Storage & Security',
                      content:
                      'Your data is encrypted both in transit and at rest. We implement industry-standard security measures to protect your information from unauthorized access, alteration, or destruction. We use secure servers and regularly update our security protocols.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '4',
                      title: 'Data Sharing & Third Parties',
                      content:
                      'We do not sell, trade, or rent your personal information to third parties. We may share your information only with service providers who assist us in operating our app, conducting our business, or serving our users, and only under strict confidentiality agreements.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '5',
                      title: 'Your Privacy Rights',
                      content:
                      'You have the right to access, update, or delete your personal information at any time. You can export your data, modify your account settings, or request complete account deletion through the app settings.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '6',
                      title: 'Cookies & Tracking',
                      content:
                      'We use cookies and similar tracking technologies to enhance your experience, understand how you use our services, and improve our app. You can control cookie preferences through your device settings.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '7',
                      title: 'Data Retention',
                      content:
                      'We retain your information for as long as your account is active or as needed to provide you services. If you delete your account, we will delete your data within 30 days, except where we are required to retain it for legal purposes.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '8',
                      title: 'Children\'s Privacy',
                      content:
                      'Mindly is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '9',
                      title: 'International Data Transfers',
                      content:
                      'Your information may be transferred to and processed in countries other than your country of residence. We ensure that such transfers comply with applicable data protection laws and that your data receives adequate protection.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '10',
                      title: 'Changes to This Policy',
                      content:
                      'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy on this page and updating the "Last Updated" date. Your continued use of Mindly after changes constitutes acceptance of the updated policy.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '11',
                      title: 'Contact Us',
                      content:
                      'If you have any questions about this Privacy Policy or our data practices, please contact us at privacy@mindly.com or support@mindly.com',
                      isLast: true,
                      isSmallScreen: isSmallScreen,
                    ),

                    const SizedBox(height: 32),

                    _buildPrivacyCommitmentCard(isSmallScreen),

                    const SizedBox(height: 44),

                    // footer
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 2,
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF004455),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '@mindly 2025',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              letterSpacing: -0.24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All Rights Reserved',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: FontWeight.w300,
                              color: Colors.black38,
                              letterSpacing: -0.20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 52),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          Text(
            'At Mindly, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our note-taking application.',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.5,
              letterSpacing: -0.28,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

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
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF004455),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Our Privacy Commitment',
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
          _buildCommitmentItem(
            icon: Icons.lock_outline,
            text: 'End-to-end encryption for your notes',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildCommitmentItem(
            icon: Icons.block_outlined,
            text: 'We never sell your data to third parties',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildCommitmentItem(
            icon: Icons.visibility_off_outlined,
            text: 'Your notes remain private and confidential',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 12),
          _buildCommitmentItem(
            icon: Icons.delete_outline,
            text: 'Full control to export or delete your data anytime',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentItem({
    required IconData icon,
    required String text,
    required bool isSmallScreen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF5784EB),
          size: 20,
        ),
        const SizedBox(width: 12),
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
              // Number Badge
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

              // Title
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

          // Content
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
              textAlign: TextAlign.justify,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}