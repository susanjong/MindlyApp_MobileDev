import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final Color color;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.color,
    this.isFavorite = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onFavoriteTap,
  });

  String get plainTextContent {
    try {
      final doc = quill.Document.fromJson(jsonDecode(content));
      return doc.toPlainText().trim();
    } catch (e) {
      return content; // Fallback jika masih format lama
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBABABA) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Heart Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title.isEmpty ? 'Untitled' : title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF131313),
                    ),
                    maxLines: 1, // ✅ Batasi judul 1 baris
                    overflow: TextOverflow.ellipsis, // ✅ Potong jika kepanjangan
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? const Color(0xFFFF6B6B) : const Color(0xFF777777),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ Content Preview dengan Expanded
            // Expanded memastikan teks mengambil sisa ruang yang ada, tidak lebih.
            Expanded(
              child: Text(
                content.isEmpty ? 'No content' : content,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4A4A4A),
                  height: 1.4,
                ),
                maxLines: 6, // ✅ Pastikan jumlah baris dibatasi (misal 5 atau 6)
                overflow: TextOverflow.ellipsis, // ✅ Wajib ada
              ),
            ),

            const SizedBox(height: 8),
            // Date
            Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7C7B7B),
              ),
              maxLines: 1, // ✅ Batasi tanggal juga
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}