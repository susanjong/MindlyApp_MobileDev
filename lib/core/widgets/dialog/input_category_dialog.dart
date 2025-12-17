import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

// Dialog reusable untuk input nama kategori baru
class InputCategoryDialog extends StatefulWidget {
  // Callback async untuk menangani logika penyimpanan data (bisa untuk Notes atau Calendar)
  final Future<void> Function(String name) onSave;
  final String title;
  final String hintText;

  const InputCategoryDialog({
    super.key,
    required this.onSave,
    this.title = 'New Category',
    this.hintText = 'Category Name',
  });

  @override
  State<InputCategoryDialog> createState() => _InputCategoryDialogState();
}

class _InputCategoryDialogState extends State<InputCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus pada text field setelah frame dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Menangani logika submit form
  Future<void> _handleSubmit() async {
    final name = _controller.text.trim();

    // Validasi input tidak boleh kosong
    if (name.isEmpty) return;

    _focusNode.unfocus();
    setState(() => _isLoading = true);

    try {
      // Eksekusi fungsi onSave yang dikirim dari parent widget
      await widget.onSave(name);

      if (mounted) {
        Navigator.pop(context); // Tutup dialog jika sukses
      }
    } catch (e) {
      // Reset loading jika terjadi error
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IOSDialog(
      title: widget.title,
      message: 'Enter a name for this category.',
      confirmText: 'Add',
      cancelText: 'Cancel',
      confirmTextColor: const Color(0xFF5784EB),
      isLoading: _isLoading,
      autoDismiss: false, // Dialog ditutup manual di _handleSubmit
      onConfirm: _handleSubmit,
      onCancel: () => _focusNode.unfocus(),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF5784EB)),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFFC7C7CC),
              fontSize: 14,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _handleSubmit(),
        ),
      ),
    );
  }
}