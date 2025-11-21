// lib/presentation/widgets/notes/note_card.dart
import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final Color color;
  final bool isFavorite;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.color,
    this.isFavorite = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Favorite Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF131313),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isFavorite)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.favorite,
                      color: Color(0xFFFF6B6B),
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),

            // Content
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  color: Color(0xFF131313),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              date,
              style: const TextStyle(
                color: Color(0xBF111827),
                fontSize: 10,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}