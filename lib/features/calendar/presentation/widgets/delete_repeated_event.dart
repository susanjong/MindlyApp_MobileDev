import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DeleteMode {
  single,following, all
}

class DeleteRepeatDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final Function(DeleteMode) onConfirm;

  const DeleteRepeatDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Delete Recurring Event',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This is a repeating event. How would you like to delete it?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _buildDivider(),
            _buildButton(
              context,
              label: 'Delete This Event Only',
              onTap: () => onConfirm(DeleteMode.single),
            ),
            _buildDivider(),
            _buildButton(
              context,
              label: 'Delete This & Following',
              onTap: () => onConfirm(DeleteMode.following),
            ),
            _buildDivider(),
            _buildButton(
              context,
              label: 'Delete All Events in Series',
              textColor: Colors.red,
              onTap: () => onConfirm(DeleteMode.all),
            ),
            _buildDivider(),
            _buildButton(
              context,
              label: 'Cancel',
              fontWeight: FontWeight.w600,
              onTap: onCancel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required String label,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF0A84FF),
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Tutup dialog
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 17,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: const Color(0xA5545458),
    );
  }
}

// Helper function agar mudah dipanggil
void showDeleteRepeatDialog({
  required BuildContext context,
  required Function(DeleteMode) onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => DeleteRepeatDialog(
      onCancel: () {},
      onConfirm: onConfirm,
    ),
  );
}