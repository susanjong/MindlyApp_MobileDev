import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class YearlyViewWidget extends StatelessWidget {
  final int currentYear;
  final Map<DateTime, List<dynamic>> events;
  final Function(DateTime) onMonthTap;

  const YearlyViewWidget({
    super.key,
    required this.currentYear,
    required this.events,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 Bulan per baris
        childAspectRatio: 0.7, // Rasio tinggi/lebar kotak bulan
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = DateTime(currentYear, index + 1);
        return GestureDetector(
          onTap: () => onMonthTap(monthDate),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Nama Bulan
                Text(
                  DateFormat('MMMM').format(monthDate),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Mini Grid Kalender Bulan Itu
                Expanded(
                  child: _buildMiniMonthGrid(monthDate),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniMonthGrid(DateTime monthDate) {
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;

    return AbsorbPointer( // Agar grid kecil tidak bisa di-scroll/klik per tanggal (hanya klik bulan)
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: daysInMonth + (firstWeekday - 1),
        itemBuilder: (context, index) {
          if (index < firstWeekday - 1) return const SizedBox.shrink();

          final day = index - (firstWeekday - 1) + 1;
          final date = DateTime(monthDate.year, monthDate.month, day);
          final hasEvent = events.containsKey(date);

          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Jika ada event, beri warna background kecil/dot
              color: hasEvent ? const Color(0xFFFBAE38) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 8,
                color: hasEvent ? Colors.white : Colors.black54,
              ),
            ),
          );
        },
      ),
    );
  }
}