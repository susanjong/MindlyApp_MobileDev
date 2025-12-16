import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'alert_dialog.dart';

class GlobalAddCategoryDialog extends StatefulWidget {
  final Function(String name) onAdd;
  final String title;
  final String message;
  final String confirmText;
  final Color primaryColor;

  const GlobalAddCategoryDialog({
    super.key,
    required this.onAdd,
    this.title = 'New Category',
    this.message = 'Enter a name for this category.',
    this.confirmText = 'Add',
    this.primaryColor = const Color(0xFF5784EB), // Default Blue
  });

  @override
  State<GlobalAddCategoryDialog> createState() => _GlobalAddCategoryDialogState();
}

class _GlobalAddCategoryDialogState extends State<GlobalAddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Delay focus untuk animasi keyboard yang smooth
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

    _focusNode.unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.onAdd(name);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IOSDialog(
      title: widget.title,
      message: widget.message,
      confirmText: widget.confirmText,
      cancelText: 'Cancel',
      confirmTextColor: widget.primaryColor,
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
          border: Border.all(color: widget.primaryColor),
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