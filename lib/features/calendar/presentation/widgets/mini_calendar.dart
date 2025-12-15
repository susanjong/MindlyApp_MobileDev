import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiniCalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const MiniCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Deteksi Landscape
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        if (width > 600) width = 600;

        return Center(
          child: SizedBox(
            width: width,
            child: Padding(
              // Padding luar diperkecil saat landscape agar hemat tempat
              padding: EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: isLandscape ? 0 : 16 // 0 padding vertical saat landscape
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildWeekDays(isLandscape),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildWeekDays(bool isCompact) {
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final now = DateTime.now();

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));

      final isSelected = date.day == selectedDate.day &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year;

      final isToday = date.day == now.day &&
          date.month == now.month &&
          date.year == now.year;

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _CalendarDayItem(
            day: date.day.toString(),
            weekday: _getWeekdayLabel(date.weekday),
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onDateSelected(date),
            isCompact: isCompact, // 3. Kirim status compact ke item
          ),
        ),
      );
    });
  }

  String _getWeekdayLabel(int weekday) {
    const labels = ['Mo', 'Tu', 'Wed', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[weekday - 1];
  }
}

class _CalendarDayItem extends StatelessWidget {
  final String day;
  final String weekday;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;
  final bool isCompact; // Parameter baru

  const _CalendarDayItem({
    required this.day,
    required this.weekday,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.isCompact = false, // Default false (Portrait)
  });

  @override
  Widget build(BuildContext context) {
    // Ukuran font yang disesuaikan
    final double dayFontSize = isCompact
        ? (isSelected ? 14 : 13)
        : (isSelected ? 20 : 18);

    final double weekdayFontSize = isCompact
        ? (isSelected ? 10 : 9)
        : (isSelected ? 14 : 12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Padding internal sangat tipis saat compact
        padding: EdgeInsets.symmetric(vertical: isCompact ? 2 : 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x265784EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Angka Tanggal
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: dayFontSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF5784EB) : const Color(0xFF1E293B),
                    height: 1.0, // Rapatkan line height
                  ),
                ),
              ),
            ),

            // Spacing (HILANGKAN total saat compact)
            if (!isCompact) const SizedBox(height: 2),

            // 2. Nama Hari
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  weekday,
                  style: GoogleFonts.poppins(
                    fontSize: weekdayFontSize,
                    color: isSelected ? const Color(0xFF5784EB) : const Color(0xFF94A3B8),
                    height: 1.0, // Rapatkan line height
                  ),
                ),
              ),
            ),

            // 3. Dot Indikator Hari Ini
            if (isToday) ...[
              SizedBox(height: isCompact ? 1 : 4), // Jarak tipis saat compact
              Container(
                width: isCompact ? 3 : 6, // Dot lebih kecil
                height: isCompact ? 3 : 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF5784EB),
                  shape: BoxShape.circle,
                ),
              ),
            ] else if (!isCompact) ...[
              // Spacer bawah hanya untuk mode portrait
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}