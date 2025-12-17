import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
import '../../data/services/category_service.dart';

class MonthlyViewWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final List<Event> events;
  final Map<String, Category> categories;
  final Function(DateTime) onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthlyViewWidget({
    super.key,
    required this.currentMonth,
    this.selectedDate,
    required this.events,
    required this.categories,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    // Determine screen orientation for responsive layout
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding = constraints.maxWidth > 600 ? 32 : 16;

        // Use SingleChildScrollView to prevent overflow in landscape mode
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isLandscape ? 4 : 12 // Reduce padding in landscape
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevents infinite height error inside ScrollView
              children: [
                _buildHeader(isLandscape),
                SizedBox(height: isLandscape ? 8 : 20),
                _buildWeekDays(constraints.maxWidth, isLandscape),
                SizedBox(height: isLandscape ? 8 : 16),
                _buildCalendarGrid(constraints.maxWidth, isLandscape),
                const SizedBox(height: 20), // Bottom padding for scrolling space
              ],
            ),
          ),
        );
      },
    );
  }

  // Renders the month navigation and title
  Widget _buildHeader(bool isLandscape) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onPreviousMonth,
          child: _buildNavIcon(Icons.chevron_left, isLandscape),
        ),
        Column(
          children: [
            Text(
              DateFormat('MMMM').format(currentMonth),
              style: TextStyle(
                fontSize: isLandscape ? 16 : 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              DateFormat('yyyy').format(currentMonth),
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Color(0xFF8F9BB3),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onNextMonth,
          child: _buildNavIcon(Icons.chevron_right, isLandscape),
        ),
      ],
    );
  }

  Widget _buildNavIcon(IconData icon, bool isLandscape) {
    return Container(
      padding: EdgeInsets.all(isLandscape ? 4 : 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF4F5F7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: isLandscape ? 18 : 20),
    );
  }

  // Renders the row of weekday names (Mon, Tue, etc.)
  Widget _buildWeekDays(double maxWidth, bool isLandscape) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Dynamic font size based on available width
    double fontSize;
    if (isLandscape) {
      fontSize = 11.0;
    } else {
      fontSize = maxWidth < 350 ? 11.0 : (maxWidth > 600 ? 14.0 : 13.0);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8F9BB3),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Renders the main grid of days
  Widget _buildCalendarGrid(double containerWidth, bool isLandscape) {
    final daysInMonth = _getDaysInMonth();
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    // Adjust Aspect Ratio: Wider in landscape to save vertical space
    double childAspectRatio;
    if (isLandscape) {
      childAspectRatio = 1.4;
    } else {
      childAspectRatio = containerWidth > 600 ? 1.0 : 0.85;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: isLandscape ? 4 : 8,
        crossAxisSpacing: 8,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 42, // Fixed 6 rows (7 * 6) to maintain consistent height
      itemBuilder: (context, index) {
        final dayOffset = index - (startingWeekday - 1);

        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return _buildEmptyDay(dayOffset, startingWeekday, daysInMonth, isLandscape);
        }

        final day = dayOffset + 1;
        final date = DateTime(currentMonth.year, currentMonth.month, day);

        final isSelected = selectedDate != null &&
            date.year == selectedDate!.year &&
            date.month == selectedDate!.month &&
            date.day == selectedDate!.day;

        final isToday = _isToday(date);
        final dayEvents = _getEventsForDate(date);

        return _buildDayCell(day, date, isSelected, isToday, dayEvents, isLandscape);
      },
    );
  }

  // Renders placeholder dates for previous/next month
  Widget _buildEmptyDay(int dayOffset, int startingWeekday, int daysInMonth, bool isLandscape) {
    double fontSize = isLandscape ? 12 : 15;
    int displayDay;

    if (dayOffset < 0) {
      final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      final previousMonthDays = DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
      displayDay = previousMonthDays + dayOffset + 1;
    } else {
      displayDay = dayOffset - daysInMonth + 1;
    }

    return Center(
      child: Text(
        '$displayDay',
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8F9BB3),
        ),
      ),
    );
  }

  // Renders the active date cell
  Widget _buildDayCell(int day, DateTime date, bool isSelected, bool isToday, List<Event> dayEvents, bool isLandscape) {
    double fontSize = isLandscape ? 12 : 15;

    return InkWell(
      onTap: () => onDateSelected(date),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFFBAE38) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: const Color(0xFFFBAE38), width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: isToday ? 'SF UI Text' : 'Poppins',
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? Colors.white : const Color(0xFF222B45),
              ),
            ),
            SizedBox(height: isLandscape ? 2 : 4),
            _buildEventDots(dayEvents),
          ],
        ),
      ),
    );
  }

  // Renders small colored dots for events on that day
  Widget _buildEventDots(List<Event> dayEvents) {
    if (dayEvents.isEmpty) return const SizedBox(height: 8);

    final categoryColors = <Color>[];

    // Extract unique colors for the first 3 categories
    for (var event in dayEvents) {
      final category = categories[event.categoryId];
      if (category != null) {
        final color = _getColorFromHex(category.color);
        if (!categoryColors.contains(color)) {
          categoryColors.add(color);
          if (categoryColors.length >= 3) break;
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categoryColors.map((color) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.2),
          ),
        );
      }).toList(),
    );
  }

  // === Helper Functions ===

  int _getDaysInMonth() => DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  List<Event> _getEventsForDate(DateTime date) {
    return events.where((event) =>
    event.startTime.year == date.year &&
        event.startTime.month == date.month &&
        event.startTime.day == date.day
    ).toList();
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }
}