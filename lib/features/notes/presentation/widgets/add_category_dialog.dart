import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(String name) onAdd;

  const AddCategoryDialog({super.key, required this.onAdd});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Delay focus untuk smooth keyboard animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    // ✅ FIX: Tutup keyboard dulu sebelum loading
    _focusNode.unfocus();

    setState(() => _isLoading = true);

    try {
      await widget.onAdd(name);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IOSDialog(
      title: 'New Category',
      message: 'Enter a name for this category.',
      confirmText: 'Add',
      cancelText: 'Cancel',
      confirmTextColor: const Color(0xFF007AFF),
      isLoading: _isLoading,
      autoDismiss: false,
      onConfirm: _handleAdd,
      onCancel: () {
        _focusNode.unfocus();
      },
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF007AFF)),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Category Name',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFFC7C7CC),
              fontSize: 14,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _handleAdd(),
        ),
      ),
    );
  }
}