import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum UpdateMode {
  single,
  following,
  all
}

class UpdateRepeatDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final Function(UpdateMode) onConfirm;

  const UpdateRepeatDialog({
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
                        'Edit Recurring Event',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How would you like to apply these changes?',
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
                  label: 'This event only',
                  onTap: () => onConfirm(UpdateMode.single),
                ),
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'This and following events',
                  onTap: () => onConfirm(UpdateMode.following),
                ),
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'All events',
                  onTap: () => onConfirm(UpdateMode.all),
                ),
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'Cancel',
                  fontWeight: FontWeight.w600,
                  textColor: Colors.red,
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

// Helper function
void showUpdateRepeatDialog({
  required BuildContext context,
  required Function(UpdateMode) onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => UpdateRepeatDialog(
      onCancel: () => Navigator.pop(context),
      onConfirm: onConfirm,
    ),
  );
}