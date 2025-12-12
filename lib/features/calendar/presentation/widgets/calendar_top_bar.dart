import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CalendarTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isYearView;
  final VoidCallback onToggleView;
  final VoidCallback onAddEvent;
  final VoidCallback onSearchTap;
  final String titleDate;

  const CalendarTopBar({
    super.key,
    required this.isYearView,
    required this.onToggleView,
    required this.onAddEvent,
    required this.onSearchTap,
    required this.titleDate,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // Padding disamakan persis dengan CustomTopAppBar (Home/Notes)
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- BAGIAN KIRI: Logo & Brand ---
            Row(
              children: [
                SizedBox(
                  width: 32.36,
                  height: 30,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/Mindly_logo.svg',
                      width: 32.36,
                      height: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Teks 'Mindly' disamakan style-nya
                Text(
                  'Mindly',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004455),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // --- BAGIAN KANAN: Icons ---
            Row(
              children: [
                // Search Icon
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFF1A1A1A),
                    size: 26, // Ukuran disamakan (sebelumnya 28)
                  ),
                  onPressed: onSearchTap,
                  tooltip: 'Search Events',
                  // Menghapus padding tambahan agar posisi pas
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(width: 20), // Jarak antar icon (disesuaikan agar tidak terlalu rapat/jauh)

                // Toggle View Icon
                IconButton(
                  onPressed: onToggleView,
                  icon: Icon(
                    isYearView ? Icons.calendar_view_month : Icons.calendar_today_outlined,
                    color: const Color(0xFF1A1A1A),
                    size: 26, // Ukuran disamakan (sebelumnya 28)
                  ),
                  tooltip: isYearView ? 'Show Monthly View' : 'Show Yearly View',
                  // Menghapus padding tambahan
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}