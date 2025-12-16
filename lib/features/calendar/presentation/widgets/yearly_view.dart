import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/features/calendar/data/model/event_model.dart';

class YearlyViewWidget extends StatefulWidget {
  final int currentYear;
  final List<Event> events;
  final Function(DateTime) onMonthTap;

  const YearlyViewWidget({
    super.key,
    required this.currentYear,
    required this.events, // Masih diterima tapi tidak digunakan untuk visual di sini
    required this.onMonthTap,
  });

  @override
  State<YearlyViewWidget> createState() => _YearlyViewWidgetState();
}

class _YearlyViewWidgetState extends State<YearlyViewWidget> {
  late PageController _pageController;
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
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
    // CATATAN: Filter event dihapus karena tidak lagi ditampilkan di view tahunan ini

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

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
              // Header Tahun
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

              // Grid Bulan
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
            // Nama Bulan
            Text(
              DateFormat('MMMM').format(monthDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD732A8),
              ),
            ),
            const SizedBox(height: 4),

            // Grid Tanggal Mini
            Expanded(
              child: _buildMiniMonthGrid(monthDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMonthGrid(DateTime monthDate) {
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final DateTime now = DateTime.now();

    return LayoutBuilder(
        builder: (context, constraints) {
          double cellHeight = constraints.maxHeight / 6;

          double fontSize = cellHeight * 0.5; // Font sedikit diperbesar karena tidak ada dot
          if (fontSize > 11) fontSize = 11;
          if (fontSize < 8) fontSize = 8;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: daysInMonth + (firstWeekday - 1),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox.shrink();

              final day = index - (firstWeekday - 1) + 1;
              final dateToCheck = DateTime(monthDate.year, monthDate.month, day);

              final bool isToday = _isSameDay(dateToCheck, now);

              // Stack tetap digunakan untuk background lingkaran hari ini
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Lingkaran Background Hari Ini (Hanya jika Today)
                  if (isToday)
                    Container(
                      width: cellHeight * 0.9,
                      height: cellHeight * 0.9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBAE38),
                        shape: BoxShape.circle,
                      ),
                    ),

                  // 2. Angka Tanggal
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: fontSize,
                      // Warna: Putih jika hari ini, Hitam pudar (biasa) jika bukan
                      color: isToday ? Colors.white : const Color(0xFF475569),
                      // Bold: Hanya jika hari ini
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