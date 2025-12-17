import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum untuk menentukan cakupan update pada event berulang
enum UpdateMode {
  single,    // Hanya event ini
  following, // Event ini dan setelahnya
  all        // Semua event dalam rangkaian
}

// Widget dialog konfirmasi untuk mengedit Recurring Event (mirip gaya iOS)
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
      backgroundColor: Colors.transparent, // Background transparan, styling diatur di child
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320), // Membatasi lebar dialog agar proporsional
        child: Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF2F2F2), // Warna abu-abu terang khas dialog iOS
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan konten
              children: [
                // Header Dialog: Judul dan Deskripsi
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

                // Opsi 1: Hanya event ini
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'This event only',
                  onTap: () => onConfirm(UpdateMode.single),
                ),

                // Opsi 2: Event ini dan ke depan
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'This and following events',
                  onTap: () => onConfirm(UpdateMode.following),
                ),

                // Opsi 3: Semua event (masa lalu & depan)
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'All events',
                  onTap: () => onConfirm(UpdateMode.all),
                ),

                // Tombol Batal
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'Cancel',
                  fontWeight: FontWeight.w600,
                  textColor: Colors.red, // Warna merah untuk aksi destruktif/batal
                  onTap: onCancel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat tombol yang konsisten
  Widget _buildButton(BuildContext context, {
    required String label,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF007AFF), // Warna biru iOS default
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Tutup dialog sebelum eksekusi callback
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

  // Widget helper untuk garis pemisah tipis
  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: const Color(0xFF3C3C43).withValues(alpha: 0.36),
    );
  }
}

// Fungsi global untuk memanggil dialog ini dengan mudah dari mana saja
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