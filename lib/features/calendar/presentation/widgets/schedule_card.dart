
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget kartu untuk menampilkan item jadwal dalam kalender
class ScheduleCardWidget extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final Color color;
  final double height;

  const ScheduleCardWidget({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.height = 64, // Tinggi default kartu
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      // Styling container dengan warna dinamis dan sudut membulat
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Menampilkan judul event
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.30,
            ),
            maxLines: 3, // Mencegah teks terlalu panjang
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
