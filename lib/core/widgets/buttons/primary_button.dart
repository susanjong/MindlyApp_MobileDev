import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// custom button for profile page with small size
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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

// primary button make responsive
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool showArrow;
  final bool enabled;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.showArrow = true,
    this.enabled = true,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // responsive sizing
    final double buttonWidth = isFullWidth
        ? screenWidth - 80
        : (width ?? (screenWidth > 600 ? 360 : 312));

    final double buttonHeight = height ?? (screenWidth > 600 ? 45 : 38);
    final double fontSize = screenWidth > 600 ? 16 : 15;

    final buttonColor = enabled
        ? (backgroundColor ?? const Color(0xFFD732A8))
        : const Color(0x7FD732A8); // warna semi-transparent saat disabled

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

class SafeButtonArea extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SafeButtonArea({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // responsive padding
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

class ResponsiveButtonExample extends StatelessWidget {
  const ResponsiveButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                label: 'Edit Profile',
                onPressed: null,
              ),

              const SizedBox(height: 20),

              // primary button normal width
              PrimaryButton(
                label: 'Sign In',
                onPressed: () {
                  debugPrint('Sign In tapped');
                },
                enabled: true,
              ),

              const SizedBox(height: 20),

              // primary button full width responsive
              PrimaryButton(
                label: 'Create Account',
                onPressed: () {
                  debugPrint('Create Account tapped');
                },
                enabled: true,
                isFullWidth: true,
              ),

              const SizedBox(height: 20),

              // primary button disabled
              PrimaryButton(
                label: 'Submit',
                onPressed: () {
                  debugPrint('Submit tapped');
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