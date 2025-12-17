import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';

// Widget untuk menampilkan kalender dalam tampilan tahunan
class YearlyViewWidget extends StatefulWidget {
  final int currentYear;
  final List<Event> events;
  final Function(DateTime) onMonthTap;

  const YearlyViewWidget({
    super.key,
    required this.currentYear,
    required this.events, // Data event diterima untuk konsistensi, meski tidak dirender di view ini
    required this.onMonthTap,
  });

  @override
  State<YearlyViewWidget> createState() => _YearlyViewWidgetState();
}

class _YearlyViewWidgetState extends State<YearlyViewWidget> {
  late PageController _pageController;
  // Menggunakan index awal besar agar user bisa scroll ke tahun sebelumnya (infinite scroll effect)
  final int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper untuk membandingkan apakah tanggal sama persis (hari, bulan, tahun)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    // PageView memungkinkan geser kanan/kiri untuk ganti tahun
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final int year = widget.currentYear + (index - _initialPage);
        return _buildYearPage(year);
      },
    );
  }

  Widget _buildYearPage(int year) {
    // LayoutBuilder digunakan untuk responsivitas (Portrait vs Landscape)
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

        // Penyesuaian jumlah kolom dan rasio aspek berdasarkan orientasi layar
        int crossAxisCount;
        double childAspectRatio;

        if (isLandscape) {
          crossAxisCount = 4;
          childAspectRatio = 1.1;
        } else {
          crossAxisCount = 3;
          childAspectRatio = 0.75;
        }

        double horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 16.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Tahun (Contoh: 2024)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  year.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: isLandscape ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),

              // Grid yang menampilkan 12 bulan
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthDate = DateTime(year, index + 1);
                    return _buildMonthCard(monthDate);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthCard(DateTime monthDate) {
    return GestureDetector(
      onTap: () => widget.onMonthTap(monthDate),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            // Nama Bulan (Contoh: January)
            Text(
              DateFormat('MMMM').format(monthDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD732A8),
              ),
            ),
            const SizedBox(height: 4),

            // Grid tanggal kecil untuk preview bulan
            Expanded(
              child: _buildMiniMonthGrid(monthDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMonthGrid(DateTime monthDate) {
    // Hitung jumlah hari dan hari pertama dalam bulan tersebut
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final DateTime now = DateTime.now();

    return LayoutBuilder(
        builder: (context, constraints) {
          // Kalkulasi ukuran font dinamis berdasarkan tinggi container
          double cellHeight = constraints.maxHeight / 6;
          double fontSize = cellHeight * 0.5;
          if (fontSize > 11) fontSize = 11;
          if (fontSize < 8) fontSize = 8;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 hari dalam seminggu
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            // Total item = hari kosong di awal bulan + jumlah hari
            itemCount: daysInMonth + (firstWeekday - 1),
            itemBuilder: (context, index) {
              // Render spasi kosong jika belum tanggal 1
              if (index < firstWeekday - 1) return const SizedBox.shrink();

              final day = index - (firstWeekday - 1) + 1;
              final dateToCheck = DateTime(monthDate.year, monthDate.month, day);
              final bool isToday = _isSameDay(dateToCheck, now);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Indikator lingkaran oranye khusus hari ini
                  if (isToday)
                    Container(
                      width: cellHeight * 0.9,
                      height: cellHeight * 0.9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBAE38),
                        shape: BoxShape.circle,
                      ),
                    ),

                  // Angka tanggal
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: isToday ? Colors.white : const Color(0xFF475569),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          );
        }
    );
  }
}