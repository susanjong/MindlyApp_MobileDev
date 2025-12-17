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
    // Deteksi orientasi layar untuk penyesuaian layout
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Batasi lebar maksimum agar tampilan tetap rapi di tablet/desktop
        double width = constraints.maxWidth;
        if (width > 600) width = 600;

        return Center(
          child: SizedBox(
            width: width,
            child: Padding(
              // Hilangkan padding vertikal saat landscape untuk menghemat ruang
              padding: EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: isLandscape ? 0 : 16
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

  // Membangun daftar widget hari selama seminggu
  List<Widget> _buildWeekDays(bool isCompact) {
    // Menentukan awal minggu (Senin) berdasarkan tanggal yang dipilih
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final now = DateTime.now();

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));

      // Cek apakah tanggal ini dipilih
      final isSelected = date.day == selectedDate.day &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year;

      // Cek apakah tanggal ini adalah hari ini
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
            isCompact: isCompact, // Teruskan status mode tampilan
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
  final bool isCompact;

  const _CalendarDayItem({
    required this.day,
    required this.weekday,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan ukuran font dinamis berdasarkan mode (compact/normal) dan status seleksi
    final double dayFontSize = isCompact
        ? (isSelected ? 14 : 13)
        : (isSelected ? 20 : 18);

    final double weekdayFontSize = isCompact
        ? (isSelected ? 10 : 9)
        : (isSelected ? 14 : 12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Padding lebih tipis saat mode compact
        padding: EdgeInsets.symmetric(vertical: isCompact ? 2 : 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x265784EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan angka tanggal
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: dayFontSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF5784EB) : const Color(0xFF1E293B),
                    height: 1.0,
                  ),
                ),
              ),
            ),

            // Jarak antar teks (hanya di mode normal)
            if (!isCompact) const SizedBox(height: 2),

            // Menampilkan nama hari (Sen, Sel, dst)
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  weekday,
                  style: GoogleFonts.poppins(
                    fontSize: weekdayFontSize,
                    color: isSelected ? const Color(0xFF5784EB) : const Color(0xFF94A3B8),
                    height: 1.0,
                  ),
                ),
              ),
            ),

            // Indikator titik biru untuk hari ini
            if (isToday) ...[
              SizedBox(height: isCompact ? 1 : 4),
              Container(
                width: isCompact ? 3 : 6,
                height: isCompact ? 3 : 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF5784EB),
                  shape: BoxShape.circle,
                ),
              ),
            ] else if (!isCompact) ...[
              // Spacer bawah tambahan hanya untuk mode portrait
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}