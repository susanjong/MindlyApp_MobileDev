import 'package:flutter/material.dart';

/// Widget untuk nampilin popup success dengan animasi keren
/// Simpan file ini di: lib/widgets/success_dialog.dart
/// 
/// Cara pakai:
/// 1. Import dulu di halaman yang mau pake:
///    import 'package:nama_project_kamu/widgets/success_dialog.dart';
/// 
/// 2. Panggil pas mau nampilin popup:
///    SuccessDialog.show(
///      context,
///      title: 'Berhasil!',
///      message: 'Data kamu udah tersimpan',
///    );
/// 
/// 3. Kalo mau tambah action setelah popup nutup:
///    SuccessDialog.show(
///      context,
///      title: 'Akun Terhapus',
///      message: 'Akun kamu berhasil dihapus',
///      onClose: () {
///        // misalnya balik ke halaman login
///        Navigator.pushReplacementNamed(context, '/login');
///      },
///    );
/// 
/// 4. Mau popup-nya lebih lama nutupnya? tambahin ini:
///    autoCloseDuration: Duration(seconds: 3),  // 3 detik baru nutup
/// 
/// Contoh lengkap di halaman Delete Account:
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     // proses hapus akun dulu...
///     await deleteAccount();
///     
///     // kalo udah berhasil, tampilin popup
///     SuccessDialog.show(
///       context,
///       title: 'Akun Terhapus!',
///       message: 'Akun kamu udah berhasil\ndihapus dari sistem.',
///       onClose: () {
///         Navigator.pushReplacementNamed(context, '/login');
///       },
///     );
///   },
///   child: Text('Hapus Akun'),
/// )
/// ```
/// 
/// Contoh di halaman Reset Password:
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     // kirim email reset password
///     await sendResetEmail();
///     
///     // tampilin popup sukses
///     SuccessDialog.show(
///       context,
///       title: 'Email Terkirim!',
///       message: 'Cek email kamu untuk\nreset password ya.',
///     );
///   },
///   child: Text('Reset Password'),
/// )
/// ```
/// 
/// Contoh di halaman Update Profile:
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     // update data profile
///     await updateProfile();
///     
///     // kasih tau kalo udah berhasil
///     SuccessDialog.show(
///       context,
///       title: 'Profile Diupdate!',
///       message: 'Data profile kamu\nudah tersimpan nih.',
///       autoCloseDuration: Duration(seconds: 3), // lebih lama dikit
///     );
///   },
///   child: Text('Simpan'),
/// )
/// ```

class SuccessDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onClose,
    Duration autoCloseDuration = const Duration(seconds: 2),
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto close setelah durasi tertentu
        Future.delayed(autoCloseDuration, () {
          if (context.mounted) {
            Navigator.of(context).pop();
            onClose?.call();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: SuccessDialogContent(
            title: title,
            message: message,
          ),
        );
      },
    );
  }
}

class SuccessDialogContent extends StatefulWidget {
  final String title;
  final String message;

  const SuccessDialogContent({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  State<SuccessDialogContent> createState() => _SuccessDialogContentState();
}

class _SuccessDialogContentState extends State<SuccessDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _checkmarkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // icon centang hijau dengan animasi
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34A853),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: FadeTransition(
                opacity: _checkmarkAnimation,
                child: const Icon(
                  Icons.check,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // judul popup - isi sendiri pas manggil
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          // pesan popup - isi sendiri pas manggil
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}