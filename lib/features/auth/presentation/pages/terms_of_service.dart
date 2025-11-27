import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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

                  // title
                  Expanded(
                    child: Text(
                      'Terms of Service',
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

            // divider
            Container(
              height: 1,
              color: const Color(0x9B999191),
            ),

            // content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // app name & logo
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
                                // Logo SVG
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

                                //logo mindly
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

                          //tagline
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

                    // last updated
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

                    // Sections
                    _buildSection(
                      number: '1',
                      title: 'Introduction',
                      content:
                      'Welcome to Mindly! These Terms of Service govern your use of our note-taking application. By accessing or using Mindly, you agree to be bound by these terms.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '2',
                      title: 'Account Registration',
                      content:
                      'To use Mindly, you must create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '3',
                      title: 'Your Content',
                      content:
                      'You retain all rights to the notes and content you create in Mindly. We do not claim ownership of your content. However, by using our service, you grant us the right to store and process your content to provide our services.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '4',
                      title: 'Privacy & Data Protection',
                      content:
                      'We take your privacy seriously. Your notes are encrypted and stored securely. We will never sell your personal information to third parties. Please refer to our Privacy Policy for detailed information.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '5',
                      title: 'Acceptable Use',
                      content:
                      'You agree not to use Mindly for any unlawful purpose or in any way that could damage, disable, or impair our service. You must not attempt to gain unauthorized access to any part of our service.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '6',
                      title: 'Service Availability',
                      content:
                      'We strive to keep Mindly available 24/7, but we cannot guarantee uninterrupted access. We reserve the right to modify or discontinue our service at any time with or without notice.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '7',
                      title: 'Account Termination',
                      content:
                      'You may delete your account at any time. We reserve the right to suspend or terminate your account if you violate these terms or engage in any activity that harms our service or other users.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '8',
                      title: 'Limitation of Liability',
                      content:
                      'Mindly is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of our service, including but not limited to data loss or service interruptions.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '9',
                      title: 'Changes to Terms',
                      content:
                      'We may update these Terms of Service from time to time. We will notify you of any material changes by posting the new terms in the app. Your continued use of Mindly after changes constitutes acceptance of the new terms.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '10',
                      title: 'Contact Us',
                      content:
                      'If you have any questions about these Terms of Service, please contact us at support@mindly.com',
                      isLast: true,
                      isSmallScreen: isSmallScreen,
                    ),

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
              // number badge
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

              // title
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

          //content
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