import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Standard Props
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  // Selection Mode Props
  final bool isSelectionMode;
  final VoidCallback? onSelectAllTap;

  // Calendar Mode Props (NEW)
  final bool isCalendarMode;
  final bool isYearView;
  final VoidCallback? onSearchTap;
  final VoidCallback? onToggleView;

  const CustomTopAppBar({
    super.key,
    this.onProfileTap,
    this.onNotificationTap,
    this.isSelectionMode = false,
    this.onSelectAllTap,
    // Initialize Calendar props
    this.isCalendarMode = false,
    this.isYearView = false,
    this.onSearchTap,
    this.onToggleView,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // Padding ini DIJAMIN SAMA untuk semua halaman
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- BAGIAN KIRI (LOGO & TEXT) - SAMA UNTUK SEMUA ---
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

            // --- BAGIAN KANAN (BERUBAH SESUAI MODE) ---
            if (isSelectionMode)
            // 1. Mode Seleksi (Select All)
              IconButton(
                icon: const Icon(
                  Icons.open_in_full_rounded,
                  color: Color(0xFF1A1A1A),
                  size: 26,
                ),
                tooltip: 'Select All',
                onPressed: onSelectAllTap,
              )
            else if (isCalendarMode)
            // 2. Mode Calendar (Search + Toggle View)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF1A1A1A),
                      size: 26, // Ukuran disamakan
                    ),
                    tooltip: 'Search Events',
                    onPressed: onSearchTap,
                  ),
                  // Add sedikit jarak antar icon jika perlu, tapi default IconButton punya padding
                  IconButton(
                    icon: Icon(
                      isYearView
                          ? Icons.calendar_view_month
                          : Icons.calendar_today_outlined,
                      color: const Color(0xFF1A1A1A),
                      size: 26, // Ukuran disamakan
                    ),
                    tooltip: isYearView ? 'Show Monthly View' : 'Show Yearly View',
                    onPressed: onToggleView,
                  ),
                ],
              )
            else
            // 3. Mode Standard (Profile + Notif) - Default Home/Notes/Todo
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF1A1A1A),
                      size: 26,
                    ),
                    onPressed: onProfileTap ?? () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 26,
                    ),
                    onPressed: onNotificationTap ?? () {},
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}