import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum untuk menentukan cakupan penghapusan pada event berulang
enum DeleteMode {
  single,    // Hanya event ini saja
  following, // Event ini dan kejadian selanjutnya
  all        // Semua event dalam rangkaian (masa lalu & depan)
}

// Widget dialog konfirmasi khusus untuk menghapus event berulang (Recurring Event)
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
      backgroundColor: Colors.transparent, // Background transparan, styling ada di child container
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320), // Batasi lebar agar proporsional
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
                // Bagian Header: Judul & Deskripsi
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

                // Opsi 1: Hapus hanya event ini
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'Delete This Event Only',
                  onTap: () => onConfirm(DeleteMode.single),
                ),

                // Opsi 2: Hapus event ini dan ke depan
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'Delete This & Following Events',
                  onTap: () => onConfirm(DeleteMode.following),
                ),

                // Opsi 3: Hapus semua (Destructive action - Merah)
                _buildDivider(),
                _buildButton(
                  context,
                  label: 'Delete All Events in Series',
                  textColor: const Color(0xFFFF3B30),
                  onTap: () => onConfirm(DeleteMode.all),
                ),

                // Tombol Batal
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

  // Helper widget untuk membuat tombol aksi yang konsisten
  Widget _buildButton(BuildContext context, {
    required String label,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF007AFF),
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Tutup dialog sebelum menjalankan aksi
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

  // Helper widget untuk garis pemisah antar tombol
  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: const Color(0xFF3C3C43).withValues(alpha: 0.36),
    );
  }
}

// Fungsi global untuk memunculkan dialog hapus repeat
void showDeleteRepeatDialog({
  required BuildContext context,
  required Function(DeleteMode) onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: true, // Bisa ditutup dengan klik area luar
    builder: (context) => DeleteRepeatDialog(
      onCancel: () => Navigator.pop(context),
      onConfirm: onConfirm,
    ),
  );
}