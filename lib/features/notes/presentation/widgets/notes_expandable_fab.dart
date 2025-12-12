import 'package:flutter/material.dart';
import 'package:notesapp/core/widgets/navigation/custom_navbar_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

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

  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late ScrollController _scrollController;
  List<DateTime> _calendarDates = [];

  @override
  void initState() {
    super.initState();
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

  void _showAddEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEventBottomSheet(),
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
                        'Hello Susan Jong!',
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
              child: GestureDetector(
                onTap: _showAddEventBottomSheet,
                child: Container(
                  width: 59,
                  height: 59,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD732A8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40D732A8),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
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
                        );
                      }).toList(),
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

// ============================================
// BOTTOM SHEET WIDGET (DI FILE YANG SAMA)
// ============================================

class AddEventBottomSheet extends StatefulWidget {
  const AddEventBottomSheet({super.key});

  @override
  State<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<AddEventBottomSheet> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedDate = '';
  String _startTime = '';
  String _endTime = '';
  String _location = '';
  String _reminder = '15 minutes before';
  String _repeat = 'Does not repeat';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Organisasi', 'color': const Color(0xFF004455), 'selected': false},
    {'name': 'Masak', 'color': const Color(0xFFFBAE38), 'selected': false},
    {'name': 'Belajar', 'color': const Color(0xFF5683EB), 'selected': false},
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    double? height,
  }) {
    return Container(
      height: height ?? 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF222B45),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFF8F9BB3),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _selectedDate = DateFormat('dd/MM/yyyy').format(date);
          });
        }
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D1D1)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate.isEmpty ? 'Date' : _selectedDate,
              style: GoogleFonts.poppins(
                color: _selectedDate.isEmpty ? const Color(0xFF8F9BB3) : const Color(0xFF222B45),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF8F9BB3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String hint,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D1D1)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value.isEmpty ? hint : value,
              style: GoogleFonts.poppins(
                color: value.isEmpty ? const Color(0xFF8F9BB3) : const Color(0xFF222B45),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8F9BB3),
                  width: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: Color(0xFF8F9BB3),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF222B45),
              ),
              decoration: InputDecoration(
                hintText: 'Add location',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF8F9BB3),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D1D1)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF8F9BB3),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color(0xFF8F9BB3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(15),
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.88,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle bar (drag indicator) dengan garis di atasnya
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 80,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header dengan judul dan tombol close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer untuk balance
                Text(
                  'Add New Event',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF222B45),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Color(0xFF222B45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Content yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name Field
                  _buildTextField(
                    controller: _eventNameController,
                    hint: 'Event name*',
                    isRequired: true,
                    height: 50,
                  ),

                  const SizedBox(height: 14),

                  // Note Field
                  _buildTextField(
                    controller: _noteController,
                    hint: 'Type the note here...',
                    maxLines: 3,
                    height: 70,
                  ),

                  const SizedBox(height: 14),

                  // Date Field
                  _buildDateField(),

                  const SizedBox(height: 14),

                  // Time Fields (Start & End)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          hint: 'Start time',
                          value: _startTime,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = time.format(context);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildTimeField(
                          hint: 'End time',
                          value: _endTime,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _endTime = time.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Location Field
                  _buildLocationField(),

                  const SizedBox(height: 14),

                  // Reminder Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF131313),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdownField(
                        value: _reminder,
                        onTap: () {
                          // Add reminder picker logic
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),

                  // Repeat Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF131313),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdownField(
                        value: _repeat,
                        onTap: () {
                          // Add repeat picker logic
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),

                  // Category Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF222B45),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.27,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _categories.map((category) {
                          return _buildCategoryChip(
                            label: category['name'],
                            color: category['color'],
                            isSelected: category['selected'],
                            onTap: () {
                              setState(() {
                                category['selected'] = !category['selected'];
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Add new category logic
                          },
                          child: Text(
                            '+ Add new',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD732A8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Create Event Button
                  GestureDetector(
                    onTap: () {
                      // Add create event logic
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD732A8),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          'Create Event',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF2F2F2),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.38,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}