import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessDialog {
  // show dialog with auto navigation after 2 seconds
  static Future<void> showWithNavigation({
    required BuildContext context,
    required String title,
    required String message,
    required String routeName,
    bool useReplacement = true,
    int delaySeconds = 2,
  }) async {
    // save the navigator state before showing dialog
    final navigator = Navigator.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // auto close after delay and navigate
        Future.delayed(Duration(seconds: delaySeconds), () {
          if (Navigator.canPop(dialogContext)) {
            Navigator.of(dialogContext).pop();

            // navigate using the saved navigator
            Future.delayed(const Duration(milliseconds: 100), () {
              if (useReplacement) {
                navigator.pushReplacementNamed(routeName);
              } else {
                navigator.pushNamed(routeName);
              }
            });
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 317,
            padding: const EdgeInsets.all(24.0),
            decoration: ShapeDecoration(
              color: const Color(0xFFF2F2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // success icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // message
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // loading indicator
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ),
                const SizedBox(height: 12),

                // redirecting text
                Text(
                  'Redirecting...',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // show dialog without navigation (manual close)
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 317,
            padding: const EdgeInsets.all(24.0),
            decoration: ShapeDecoration(
              color: const Color(0xFFF2F2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // success icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // message
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
        );
      },
    );
  }
}