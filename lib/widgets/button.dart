import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom Button untuk profile page (ukuran kecil) - Responsive
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final double buttonWidth = screenWidth > 600 ? 100 : 88.81;
    final double buttonHeight = screenWidth > 600 ? 28 : 24;
    final double fontSize = screenWidth > 600 ? 13 : 12;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: -0.24,
            ),
          ),
        ),
      ),
    );
  }
}

// Primary Button untuk login/signup (ukuran besar dengan desain pink) - Responsive
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool showArrow;
  final bool enabled;
  final bool isFullWidth; // Opsi untuk full width responsif

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.showArrow = true,
    this.enabled = true,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final double buttonWidth = isFullWidth
        ? screenWidth - 80 // Full width dengan padding
        : (width ?? (screenWidth > 600 ? 360 : 312));

    final double buttonHeight = height ?? (screenWidth > 600 ? 45 : 38);
    final double fontSize = screenWidth > 600 ? 16 : 15;

    // Tentukan warna berdasarkan enabled state
    final buttonColor = enabled
        ? (backgroundColor ?? const Color(0xFFD732A8))
        : const Color(0x7FD732A8); // Warna semi-transparent saat disabled

    final buttonTextColor = enabled
        ? (textColor ?? Colors.white)
        : Colors.white;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: enabled ? const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            showArrow ? '$label  →  ' : label,
            style: GoogleFonts.poppins(
              color: buttonTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: -0.30,
            ),
          ),
        ),
      ),
    );
  }
}

// Wrapper widget untuk button dengan safe area
class SafeButtonArea extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SafeButtonArea({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding
    final EdgeInsets defaultPadding = EdgeInsets.symmetric(
      horizontal: screenWidth > 600 ? 40 : 30,
      vertical: 16,
    );

    return SafeArea(
      child: Padding(
        padding: padding ?? defaultPadding,
        child: child,
      ),
    );
  }
}

// Example usage dengan SafeArea
class ResponsiveButtonExample extends StatelessWidget {
  const ResponsiveButtonExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom Button (small)
              CustomButton(
                label: 'Edit Profile',
                onPressed: () {
                  print('Edit Profile tapped');
                },
              ),

              const SizedBox(height: 20),

              // Primary Button (normal width)
              PrimaryButton(
                label: 'Sign In',
                onPressed: () {
                  print('Sign In tapped');
                },
                enabled: true,
              ),

              const SizedBox(height: 20),

              // Primary Button (full width responsive)
              PrimaryButton(
                label: 'Create Account',
                onPressed: () {
                  print('Create Account tapped');
                },
                enabled: true,
                isFullWidth: true,
              ),

              const SizedBox(height: 20),

              // Primary Button (disabled)
              PrimaryButton(
                label: 'Submit',
                onPressed: () {
                  print('Submit tapped');
                },
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}