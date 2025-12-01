import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MonthlyViewWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Map<DateTime, List<dynamic>> events;

  const MonthlyViewWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(focusedDay.year, focusedDay.month);
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    return Column(
      children: [
        _buildDaysOfWeek(),

        // Gesture Detector untuk Swipe Kiri/Kanan ganti bulan
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe Right -> Prev Month
              onPageChanged(DateTime(focusedDay.year, focusedDay.month - 1));
            } else if (details.primaryVelocity! < 0) {
              // Swipe Left -> Next Month
              onPageChanged(DateTime(focusedDay.year, focusedDay.month + 1));
            }
          },
          child: Container(
            color: Colors.transparent, // Agar gesture terdeteksi di area kosong
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysInMonth + (startingWeekday - 1),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox.shrink();
                }

                final day = index - (startingWeekday - 1) + 1;
                final current = DateTime(focusedDay.year, focusedDay.month, day);
                final isSelected = isSameDay(current, selectedDay);
                final isToday = isSameDay(current, DateTime.now());

                // Cek apakah ada event di hari ini
                final hasEvent = events.containsKey(DateTime(current.year, current.month, current.day));

                return GestureDetector(
                  onTap: () => onDaySelected(current, focusedDay),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF5784EB)
                              : (isToday ? const Color(0xFFFBAE38).withOpacity(0.3) : Colors.transparent),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? Colors.white
                                  : (isToday ? const Color(0xFFFBAE38) : Colors.black),
                              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.grey, // Dot color
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) => Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}