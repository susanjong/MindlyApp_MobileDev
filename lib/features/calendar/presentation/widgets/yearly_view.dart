import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class YearlyViewWidget extends StatefulWidget {
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
  State<YearlyViewWidget> createState() => _YearlyViewWidgetState();
}

class _YearlyViewWidgetState extends State<YearlyViewWidget> {
  late PageController _pageController;
  // A large number to allow scrolling back many years (e.g., index 1000 = currentYear)
  final int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    // Initialize controller starting at the "middle" (current year)
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical, // Vertical scroll like standard calendar apps
      // Allows scrolling "infinitely" in both directions
      itemBuilder: (context, index) {
        // Calculate the year based on the page index
        // If index == _initialPage (1000), year = widget.currentYear
        // If index == 999, year = widget.currentYear - 1
        final int year = widget.currentYear + (index - _initialPage);

        return _buildYearPage(year);
      },
    );
  }

  Widget _buildYearPage(int year) {
    return Column(
      children: [
        // Year Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            year.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        // Months Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(), // Disable grid scroll, use PageView scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 Months per row
              childAspectRatio: 0.7, // Aspect ratio
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthDate = DateTime(year, index + 1);
              return GestureDetector(
                onTap: () => widget.onMonthTap(monthDate),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Month Name
                      Text(
                        DateFormat('MMMM').format(monthDate),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD732A8), // Pink accent for month name
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Mini Calendar Grid
                      Expanded(
                        child: _buildMiniMonthGrid(monthDate),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMonthGrid(DateTime monthDate) {
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;

    return AbsorbPointer(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          // Total cells = days in month + offset for starting day
          itemCount: daysInMonth + (firstWeekday - 1),
          itemBuilder: (context, index) {
            // Empty slots before the 1st of the month
            if (index < firstWeekday - 1) return const SizedBox.shrink();

            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(monthDate.year, monthDate.month, day);

            // Check for events using key equality
            // Note: Ensure your events map keys normalize time to 00:00:00 for accurate matching
            final bool hasEvent = widget.events.keys.any((eventDate) =>
            eventDate.year == date.year &&
                eventDate.month == date.month &&
                eventDate.day == date.day
            );

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasEvent ? const Color(0xFFFBAE38) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 8,
                  color: hasEvent ? Colors.white : Colors.black54,
                  fontWeight: hasEvent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}