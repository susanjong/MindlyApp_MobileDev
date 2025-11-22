import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          title: Text(
            'About',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.48,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // App Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Logo and App Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32.26,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF004455),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: SvgPicture.asset(
                                  'assets/images/Mindly_logo.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text.rich(
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Progress Tracker',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Versi 1.0.0',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Tags
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x7FD9D9D9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Productivity',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x7FD9D9D9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Task Management',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'A comprehensive productivity application designed\nto help you manage tasks, track daily progress, and\nachieve your goals efficiently.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // About Progress Tracker Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Progress Tracker',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Progress Tracker is a comprehensive productivity application designed to help you manage tasks, track daily progress, and achieve your goals efficiently. With intuitive design and powerful features, stay organized across academic, work, and personal projects while gaining valuable insights into your productivity patterns.',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                            letterSpacing: 0.33,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Key Features:',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                            letterSpacing: 0.33,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '✓  Smart task management with priority levels\n✓  Real-time progress tracking and analytics\n✓  Weekly insights and productivity reports\n✓  Multi-category organization\n✓  Secure data backup and export options\n✓  Cross-device synchronization',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                            letterSpacing: 0.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Developer Information Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developer Information',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1,
                            letterSpacing: -0.30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDeveloperInfo(
                          'Susan Jong',
                          '231401014',
                          'susanjong05@gmail.com',
                        ),
                        const Divider(color: Color(0x9B999191)),
                        _buildDeveloperInfo(
                          'Parulian Dwi Reslia Simbolon',
                          '231401032',
                          'paruliandwireslia22@gmail.com',
                        ),
                        const Divider(color: Color(0x9B999191)),
                        _buildDeveloperInfo(
                          'Charissa Haya Qanita',
                          '231401113',
                          'charissa.qanita88@gmail.com',
                        ),
                        const Divider(color: Color(0x9B999191)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // USU Logo
                            SizedBox(
                              width: 43,
                              height: 43,
                              child: Image.asset(
                                'assets/images/USU_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Universitas Sumatera Utara\nFasilkom - TI\nIlmu Komputer',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                  letterSpacing: 0.22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
    }

  Widget _buildDeveloperInfo(String name, String id, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$id\n$email',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }
}