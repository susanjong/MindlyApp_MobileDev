import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UrgentOverdueTaskItem extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color themeColor; // Warna tema (Orange utk Urgent, Merah utk Overdue)
  final String timeText; // Text waktu (ex: "30 Mins left" atau "overdue by...")
  final VoidCallback onTapArrow;

  const UrgentOverdueTaskItem({
    super.key,
    required this.task,
    required this.themeColor,
    required this.timeText,
    required this.onTapArrow,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime deadline = task['deadline'];
    final String day = DateFormat('dd').format(deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Today',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 2. Task Info (Menggunakan RichText)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF535353),
                      height: 1.4,
                    ),
                    children: [
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.0, bottom: 2.0),
                          child: Icon(Icons.access_time, size: 14, color: Color(0xFF535353)),
                        ),
                      ),
                      TextSpan(text: timeText),

                      const TextSpan(
                        text: "  |  ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      TextSpan(text: task['category'] ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // 3. Arrow Icon
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 28,
            ),
            onPressed: onTapArrow,
          ),
        ],
      ),
    );
  }
}