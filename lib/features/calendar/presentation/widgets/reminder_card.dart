import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReminderCardWidget extends StatelessWidget {
  final String time;
  final String title;

  const ReminderCardWidget({
    super.key,
    required this.time,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF5784EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 51.38,
            height: 48,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5683EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 24,
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 2.60,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.58,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // More Options Icon
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.more_vert,
              color: const Color(0xFF2D2D2D).withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}