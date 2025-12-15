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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildWeekDays(),
      ),
    );
  }

  List<Widget> _buildWeekDays() {
    // Tentukan awal minggu berdasarkan tanggal yang dipilih
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    // Ambil waktu sekarang untuk pengecekan "Hari Ini"
    final now = DateTime.now();

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));

      // Cek apakah tanggal ini dipilih
      final isSelected = date.day == selectedDate.day &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year;

      // Cek apakah tanggal ini adalah HARI INI
      final isToday = date.day == now.day &&
          date.month == now.month &&
          date.year == now.year;

      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: index == 0 || index == 6 ? 0 : 2),
          child: _CalendarDayItem(
            day: date.day.toString(),
            weekday: _getWeekdayLabel(date.weekday),
            isSelected: isSelected,
            isToday: isToday,
            onTap: () => onDateSelected(date),
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

  const _CalendarDayItem({
    required this.day,
    required this.weekday,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x265784EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isSelected ? const Color(0xFF5784EB) : const Color(0xFF1E293B),
                  fontSize: isSelected ? 20 : 18,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  height: isSelected ? 1.30 : 1.44,
                  letterSpacing: 0.30,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                weekday,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: isSelected ? const Color(0xFF5784EB) : const Color(0xFF94A3B8),
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  height: isSelected ? 1.86 : 2.17,
                  letterSpacing: 0.30,
                ),
              ),
            ),

            if (isToday) ...[
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF5784EB),
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}