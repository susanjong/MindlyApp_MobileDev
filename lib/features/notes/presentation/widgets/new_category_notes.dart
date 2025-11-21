import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewCategoryDialog extends StatefulWidget {
  final Function(String) onCategoryCreated;

  const NewCategoryDialog({
    super.key,
    required this.onCategoryCreated,
  });

  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _handleOk() {
    final categoryName = _categoryController.text.trim();
    if (categoryName.isNotEmpty) {
      Navigator.pop(context);
      widget.onCategoryCreated(categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
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
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 238,
                    child: Text(
                      'New Category',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.29,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 238,
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: TextField(
                      controller: _categoryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter category',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.20,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.20,
                      ),
                      onSubmitted: (_) => _handleOk(),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: double.infinity,
              height: 0.50,
              decoration: const BoxDecoration(
                color: Color(0xA5545458),
              ),
            ),

            // Buttons Section
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                        ),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.57,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 0.50,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xA5545458),
                    ),
                  ),

                  // OK Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleOk,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(14),
                        ),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'OK',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.57,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function untuk menampilkan dialog dengan mudah
void showNewCategoryDialog({
  required BuildContext context,
  required Function(String) onCategoryCreated,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => NewCategoryDialog(
      onCategoryCreated: onCategoryCreated,
    ),
  );
}