import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;

  const NoteSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search notes...',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21.5, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6A6E76), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    // ✅ FIX: Pastikan autofocus false
                    autofocus: false,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF6A6E76), fontSize: 12, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // ... (Clear button code remains same)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () { controller.clear(); onClear?.call(); },
                      child: const Icon(Icons.clear, color: Color(0xFF6A6E76), size: 18),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}