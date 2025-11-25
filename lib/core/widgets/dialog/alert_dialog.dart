import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IOSDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final Color? confirmTextColor;

  const IOSDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancel,
    required this.onConfirm,
    this.confirmTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 270,
        decoration: ShapeDecoration(
          color: const Color(0xBFF2F2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 238,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.29,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 238,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.38,
                        letterSpacing: -0.08,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: double.infinity,
              height: 0.50,
              decoration: const BoxDecoration(
                color: Color(0xA5545458),
              ),
            ),

            // Buttons Section
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                        ),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            cancelText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.57,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 0.50,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xA5545458),
                    ),
                  ),

                  // Confirm Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(14),
                        ),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            confirmText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: confirmTextColor ?? const Color(0xFFFF453A),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.57,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function untuk menampilkan dialog dengan mudah
void showIOSDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelText = 'Cancel',
  String confirmText = 'Confirm',
  VoidCallback? onCancel,
  required VoidCallback onConfirm,
  Color? confirmTextColor,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => IOSDialog(
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: confirmText,
      onCancel: onCancel,
      onConfirm: onConfirm,
      confirmTextColor: confirmTextColor,
    ),
  );
}