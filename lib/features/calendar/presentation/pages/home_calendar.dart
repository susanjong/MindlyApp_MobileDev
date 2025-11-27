import 'package:flutter/material.dart';
import 'package:notesapp/features/notes/presentation/widgets/notes_expandable_fab.dart';
import 'package:notesapp/core/widgets/navigation/custom_navbar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/core/services/auth_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<Map<String, dynamic>> _scheduleItems = [
    {
      'time': '08.00 - 10.00',
      'title': 'Rapat dengan Bruce Wayne',
      'color': const Color(0xFFFBAE38),
      'startHour': 8,
      'endHour': 10,
    },
    {
      'time': '12.00 - 16.00',
      'title': 'Test wawasan kebangasaan di Dusun Wakanda',
      'color': const Color(0xFFFBAE38),
      'startHour': 12,
      'endHour': 16,
    },
  ];

  final List<Map<String, dynamic>> _reminderItems = [
    {
      'time': '12.00 - 16.00',
      'title': 'Design new UX flow for Michael',
      'icon': Icons.design_services,
    },
    {
      'time': '12.00 - 16.00',
      'title': 'Design new UX flow for Michael',
      'icon': Icons.design_services,
    },
    {
      'time': '12.00 - 16.00',
      'title': 'Design new UX flow for Michael',
      'icon': Icons.design_services,
    },
  ];
  late String _userName;
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late ScrollController _scrollController;
  List<DateTime> _calendarDates = [];

  @override
  void initState() {
    super.initState();
    _userName = AuthService.getUserDisplayName() ?? 'User';
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _scrollController = ScrollController();
    _generateCalendarDates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateCalendarDates() {
    _calendarDates.clear();
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    for (int i = 0; i <= lastDayOfMonth.day - 1; i++) {
      _calendarDates.add(firstDayOfMonth.add(Duration(days: i)));
    }
  }

  void _scrollToSelectedDate() {
    final selectedIndex = _calendarDates.indexWhere(
          (date) =>
      date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day,
    );

    if (selectedIndex != -1 && _scrollController.hasClients) {
      final offset = (selectedIndex * 60.0) - (MediaQuery.of(context).size.width / 2) + 30;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _generateCalendarDates();
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _generateCalendarDates();
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
      _generateCalendarDates();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  String _getMonthYear() {
    return DateFormat('MMMM yyyy').format(_currentMonth);
  }

  void _showAddScheduleDialog(double tapPositionY) {
    // Calculate which hour was tapped based on position
    final tappedHour = 8 + (tapPositionY / 60).floor();

    final TextEditingController titleController = TextEditingController();
    TimeOfDay startTime = TimeOfDay(hour: tappedHour, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: tappedHour + 1, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Schedule', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: GoogleFonts.poppins(),
                    border: const OutlineInputBorder(),
                  ),
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              startTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              Text(startTime.format(context), style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) {
                            setDialogState(() {
                              endTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                              Text(endTime.format(context), style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _scheduleItems.add({
                      'time': '${startTime.format(context)} - ${endTime.format(context)}',
                      'title': titleController.text,
                      'color': const Color(0xFF5784EB),
                      'startHour': startTime.hour,
                      'endHour': endTime.hour,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5784EB),
              ),
              child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Hello  $_userName !',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF444444),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMonthNavigation(),
                    const SizedBox(height: 12),
                    _buildWeekDaysSelector(),
                    const SizedBox(height: 20),
                    _buildScheduleSection(),
                    const SizedBox(height: 20),
                    _buildReminderSection(),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 15,
              child: const NotesExpandableFab(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildMonthNavigation() {
    final isCurrentMonth = _currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: _goToPreviousMonth,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 24,
                    color: Color(0xFF5784EB),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getMonthYear(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.30,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _goToNextMonth,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Color(0xFF5784EB),
                  ),
                ),
              ),
            ],
          ),
          if (!isCurrentMonth)
            InkWell(
              onTap: _goToToday,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5784EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF004455),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/Mindly_logo.svg',
                    width: 32.36,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Mindly',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF004455),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -0.60,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.search),
              const SizedBox(width: 20),
              _buildIconButton(Icons.calendar_today),
              const SizedBox(width: 20),
              _buildIconButton(Icons.add),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Icon(icon, size: 20, color: const Color(0xFF004455)),
    );
  }

  Widget _buildWeekDaysSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _calendarDates.length,
        itemBuilder: (context, index) {
          final date = _calendarDates[index];
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _scrollToSelectedDate();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: isSelected ? 53 : 50,
              margin: const EdgeInsets.only(right: 10),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (isSelected)
                    Container(
                      width: 53,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0x265784EB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? const Color(0xFF5784EB)
                              : isToday
                              ? const Color(0xFFFBAE38)
                              : const Color(0xFF1E293B),
                          fontSize: isSelected ? 20 : 18,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          height: 1.44,
                          letterSpacing: 0.30,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE').format(date).substring(0, 2),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? const Color(0xFF5784EB)
                              : const Color(0xFF94A3B8),
                          fontSize: isSelected ? 14 : 12,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                          height: 2.17,
                          letterSpacing: 0.30,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5784EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleSection() {
    final List<String> timeSlots = ['08.00', '10.00', '12.00', '14.00', '16.00'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Today',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.73,
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: timeSlots.map((time) {
                    return SizedBox(
                      height: 48,
                      child: Text(
                        time,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 2.17,
                          letterSpacing: 0.30,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTapDown: (details) {
                      _showAddScheduleDialog(details.localPosition.dy);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: _scheduleItems.map((item) {
                          final topPosition = ((item['startHour'] - 8) * 60.0);
                          final height = ((item['endHour'] - item['startHour']) * 60.0) - 8;

                          return Positioned(
                            left: 0,
                            top: topPosition,
                            right: 0,
                            child: Draggable(
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 120,
                                  height: height,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: item['color'].withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    item['title'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.33,
                                      letterSpacing: 0.30,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(),
                              onDragEnd: (details) {
                                setState(() {});
                              },
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Schedule', style: GoogleFonts.poppins()),
                                      content: Text(item['title'], style: GoogleFonts.poppins()),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _scheduleItems.remove(item);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Close', style: GoogleFonts.poppins()),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  height: height,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: item['color'],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    item['title'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.33,
                                      letterSpacing: 0.30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.86,
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dont forget schedule for tomorrow',
            style: GoogleFonts.inter(
              color: const Color(0xFF565A60),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 2.17,
              letterSpacing: 0.50,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reminderItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _reminderItems[index];
              return _buildReminderCard(
                time: item['time'],
                title: item['title'],
                icon: item['icon'],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required String time,
    required String title,
    required IconData icon,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5784EB), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5683EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 2.60,
                    letterSpacing: 0.50,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.58,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}