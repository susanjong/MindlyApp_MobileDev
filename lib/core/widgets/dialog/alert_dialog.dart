import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IOSDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final Color? confirmTextColor;
  final bool autoDismiss;
  final bool isLoading;
  final bool singleButton;

  const IOSDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancel,
    required this.onConfirm,
    this.confirmTextColor,
    this.autoDismiss = true,
    this.isLoading = false,
    this.singleButton = false,
  }) : assert(message != null || content != null, 'Message or content must be provided');

  @override
  Widget build(BuildContext context) {
    const separatorColor = Color(0xA5545458);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Mengatur inset padding agar dialog tidak terlalu mepet saat keyboard muncul
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
            // --- PERBAIKAN DI SINI ---
            // 1. Bungkus konten dengan Flexible agar bisa menyusut saat keyboard muncul
            Flexible(
              child: SingleChildScrollView(
                // 2. Tambahkan SingleChildScrollView agar bisa di-scroll jika menyusut
                physics: const ClampingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Text(
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
                      const SizedBox(height: 4),
                      if (message != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.38,
                            letterSpacing: -0.08,
                          ),
                        ),
                      ],
                      if (content != null) ...[
                        const SizedBox(height: 12),
                        content!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // --- AKHIR PERBAIKAN ---

            // Horizontal Divider (Tetap diam di tempat)
            Container(
              width: double.infinity,
              height: 0.5,
              color: separatorColor,
            ),

            // Buttons Row (Tetap diam di tempat, tidak ikut scroll)
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  // Cancel Button
                  if (!singleButton) ...[
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : () {
                            Navigator.pop(context);
                            onCancel?.call();
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              cancelText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0A84FF),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                height: 1.29,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Vertical Divider
                    Container(
                      width: 0.5,
                      height: double.infinity,
                      color: separatorColor,
                    ),
                  ],

                  // Confirm Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isLoading ? null : () {
                          if (autoDismiss) {
                            Navigator.pop(context);
                          }
                          onConfirm();
                        },
                        borderRadius: BorderRadius.only(
                          bottomRight: const Radius.circular(14),
                          bottomLeft: singleButton ? const Radius.circular(14) : Radius.zero,
                        ),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(confirmTextColor ?? const Color(0xFF0A84FF))
                              )
                          )
                              : Text(
                            confirmText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: confirmTextColor ?? const Color(0xFF0A84FF),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.29,
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

// Helper Function Update
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
  bool singleButton = false, // Tambahkan ini
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
      autoDismiss: true,
      singleButton: singleButton, // Pass ke widget
    ),
  );
}