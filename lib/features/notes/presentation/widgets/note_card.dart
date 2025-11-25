import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gray background when selected, original color when not
          color: isSelected ? const Color(0xFFBABABA) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Heart Icon
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      // Red filled if favorite, Gray outline if not
                      color: isFavorite ? const Color(0xFFFF6B6B) : const Color(0xFF777777),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Content Preview
            Expanded(
              child: Text(
                content.isEmpty ? 'No content' : content,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4A4A4A),
                  height: 1.4,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }
}