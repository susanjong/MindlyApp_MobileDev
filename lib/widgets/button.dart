import 'package:flutter/material.dart';

// Custom Button untuk profile page (ukuran kecil)
class CustomButton extends StatelessWidget {
  final String label;

  const CustomButton({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.81,
      height: 24,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 88.81,
              height: 24,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Primary Button untuk login/signup (ukuran besar dengan desain pink)
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Ubah jadi nullable untuk disable state
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool showArrow;
  final bool enabled;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tentukan warna berdasarkan enabled state
    final buttonColor = enabled
        ? (backgroundColor ?? const Color(0xFFD732A8))
        : const Color(0x7FD732A8); // Warna semi-transparent saat disabled

    final buttonTextColor = enabled
        ? (textColor ?? Colors.white)
        : Colors.white;

    return GestureDetector(
      onTap: enabled ? onPressed : null, // Disable ketika tidak aktif
      child: Container(
        width: width ?? 312,
        height: height ?? 38,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Center(
          child: Text(
            showArrow ? '$label  →  ' : label,
            style: TextStyle(
              color: buttonTextColor,
              fontSize: 20,
              fontFamily: 'Poppins',
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