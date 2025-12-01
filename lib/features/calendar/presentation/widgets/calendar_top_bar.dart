import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        titleDate,
        style: GoogleFonts.poppins(
          color: const Color(0xFFFBAE38), // Warna Kuning/Orange sesuai request
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Search Icon
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black, size: 28),
          onPressed: onSearchTap,
          tooltip: 'Search Events',
        ),

        // Add Event Icon
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black, size: 28),
          onPressed: onAddEvent,
          tooltip: 'Add New Event',
        ),

        // Calendar View Toggle (Month <-> Year)
        IconButton(
          onPressed: onToggleView,
          icon: Icon(
            isYearView ? Icons.calendar_view_month : Icons.calendar_today_outlined,
            color: const Color(0xFF004455), // Warna Brand
          ),
          tooltip: isYearView ? 'Show Monthly View' : 'Show Yearly View',
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}