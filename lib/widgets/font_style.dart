import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontStyles {
  // Base Poppins TextTheme
  static final TextTheme poppinsTextTheme = GoogleFonts.poppinsTextTheme();

  // Style judul utama
  static TextStyle appTitle = GoogleFonts.poppins(
    color: const Color(0xFF0D5F5F),
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Main header
  static TextStyle mainHeader = GoogleFonts.poppins(
    fontSize: 26,
    color: const Color(0xFF0D5F5F),
    fontWeight: FontWeight.w700,
  );

  // Sub header
  static TextStyle subHeader = GoogleFonts.poppins(
    fontSize: 20,
    color: Colors.green,
    fontWeight: FontWeight.w600,
  );

  // Body text
  static TextStyle bodyText = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.black,
    fontWeight: FontWeight.normal,
  );
}