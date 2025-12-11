import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/features/calendar/data/model/event_model.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildWeekDays(),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onPreviousMonth,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF4F5F7)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left, size: 20),
          ),
        ),
        Column(
          children: [
            Text(
              DateFormat('MMMM').format(currentMonth),
              style: const TextStyle(
                fontSize: 20,
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
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF4F5F7)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return SizedBox(
          width: 40,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Color(0xFF8F9BB3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth();
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: 42, // 6 weeks max
      itemBuilder: (context, index) {
        final dayOffset = index - (startingWeekday - 1);

        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          // Previous or next month days
          return _buildEmptyDay(dayOffset, startingWeekday, daysInMonth);
        }

        final day = dayOffset + 1;
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final isSelected = selectedDate != null &&
            date.year == selectedDate!.year &&
            date.month == selectedDate!.month &&
            date.day == selectedDate!.day;
        final isToday = _isToday(date);
        final dayEvents = _getEventsForDate(date);

        return _buildDayCell(day, date, isSelected, isToday, dayEvents);
      },
    );
  }

  Widget _buildEmptyDay(int dayOffset, int startingWeekday, int daysInMonth) {
    if (dayOffset < 0) {
      // Previous month
      final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      final previousMonthDays = DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
      final day = previousMonthDays + dayOffset + 1;
      return Center(
        child: Text(
          '$day',
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Color(0xFF8F9BB3),
          ),
        ),
      );
    } else {
      // Next month
      final day = dayOffset - daysInMonth + 1;
      return Center(
        child: Text(
          '$day',
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Color(0xFF8F9BB3),
          ),
        ),
      );
    }
  }

  Widget _buildDayCell(int day, DateTime date, bool isSelected, bool isToday, List<Event> dayEvents) {
    return InkWell(
      onTap: () => onDateSelected(date),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFFBAE38) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 15,
                fontFamily: isToday ? 'SF UI Text' : 'Poppins',
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? Colors.white : const Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 4),
            _buildEventDots(dayEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDots(List<Event> dayEvents) {
    if (dayEvents.isEmpty) {
      return const SizedBox(height: 8);
    }

    // Get unique category colors for this day's events
    final categoryColors = <Color>[];
    for (var event in dayEvents) {
      final category = categories[event.categoryId];
      if (category != null) {
        final color = _getColorFromHex(category.color);
        if (!categoryColors.contains(color)) {
          categoryColors.add(color);
          if (categoryColors.length >= 3) break; // Max 3 dots
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

  int _getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  List<Event> _getEventsForDate(DateTime date) {
    return events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}