import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DeleteMode {
  single,
  following,
  all
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
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF2F2F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'Delete Recurring Event',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a repeating event.\nHow would you like to delete it?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
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
                  label: 'Delete This & Following Events',
                  onTap: () => onConfirm(DeleteMode.following),
                ),
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'Delete All Events in Series',
                  textColor: const Color(0xFFFF3B30),
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
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required String label,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF007AFF),
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 16,
            fontWeight: fontWeight,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: const Color(0xFF3C3C43).withValues(alpha: 0.36),
    );
  }
}

void showDeleteRepeatDialog({
  required BuildContext context,
  required Function(DeleteMode) onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => DeleteRepeatDialog(
      onCancel: () => Navigator.pop(context),
      onConfirm: onConfirm,
    ),
  );
}