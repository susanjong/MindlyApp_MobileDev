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

                    // terms sections list
                    _buildSection(
                      number: '1',
                      title: 'Agreement',
                      content:
                      'By using Mindly, you agree to these terms and our Privacy Policy.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '2',
                      title: 'Your Account',
                      content:
                      'You are responsible for keeping your account secure and all activities under it.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '3',
                      title: 'Your Content',
                      content:
                      'You own all notes you create. We only store and process them to provide our service.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '4',
                      title: 'Service Usage',
                      content:
                      'Use Mindly legally and responsibly. Do not abuse or harm our service.',
                      isSmallScreen: isSmallScreen,
                    ),

                    _buildSection(
                      number: '5',
                      title: 'Termination',
                      content:
                      'You can delete your account anytime. We may suspend accounts that violate these terms.',
                      isLast: true,
                      isSmallScreen: isSmallScreen,
                    ),

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

  // build numbered terms section with badge
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