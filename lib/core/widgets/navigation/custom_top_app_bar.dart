import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool isSelectionMode;
  final VoidCallback? onSelectAllTap;
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
    this.isCalendarMode = false,
    this.isYearView = false,
    this.onSearchTap,
    this.onToggleView,
  });

  @override
  // Gunakan kToolbarHeight (56.0) agar lebih standar dan muat di landscape
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Cek Orientasi
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Tentukan ukuran komponen berdasarkan orientasi
    final double logoSize = isLandscape ? 24.0 : 30.0;
    final double titleFontSize = isLandscape ? 22.0 : 30.0;
    final double iconSize = isLandscape ? 22.0 : 26.0;
    final double verticalPadding = isLandscape ? 4.0 : 10.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: verticalPadding),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Logo & Title ---
            Row(
              children: [
                SizedBox(
                  width: logoSize + 2, // sedikit margin
                  height: logoSize,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/Mindly_logo.svg',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: logoSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Gap dikurangi dikit
                Text(
                  'Mindly',
                  style: GoogleFonts.poppins(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004455),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // --- Actions Icons ---
            if (isSelectionMode)
              IconButton(
                icon: Icon(Icons.open_in_full_rounded, color: const Color(0xFF1A1A1A), size: iconSize),
                tooltip: 'Select All',
                onPressed: onSelectAllTap,
                padding: EdgeInsets.zero, // Remove padding bawaan agar lebih compact
                constraints: const BoxConstraints(),
              )
            else if (isCalendarMode)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.search, color: const Color(0xFF1A1A1A), size: iconSize),
                    tooltip: 'Search Events',
                    onPressed: onSearchTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isYearView ? Icons.calendar_view_month : Icons.calendar_today_outlined,
                      color: const Color(0xFF1A1A1A),
                      size: iconSize,
                    ),
                    tooltip: isYearView ? 'Show Monthly View' : 'Show Yearly View',
                    onPressed: onToggleView,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.person_outline, color: const Color(0xFF1A1A1A), size: iconSize),
                    onPressed: onProfileTap ?? () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.notifications_none_outlined, color: const Color(0xFF1A1A1A), size: iconSize),
                    onPressed: onNotificationTap ?? () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}