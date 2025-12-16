import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

class InputCategoryDialog extends StatefulWidget {
  // Callback ini yang akan membedakan logicnya nanti
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

  Future<void> _handleSubmit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    _focusNode.unfocus();
    setState(() => _isLoading = true);

    try {
      // Panggil fungsi yang dilempar dari parent (Calendar atau Notes)
      await widget.onSave(name);

      if (mounted) {
        Navigator.pop(context); // Tutup dialog setelah sukses
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Bisa tambah snackbar error disini
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
      autoDismiss: false, // Kita handle dismiss manual saat sukses
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