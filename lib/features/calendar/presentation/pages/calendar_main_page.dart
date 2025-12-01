import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/buttons/global_expandable_fab.dart';
import '../widgets/mini_calendar.dart';
import '../widgets/monthly_view.dart';
import '../widgets/yearly_view.dart';
import '../widgets/schedule_card.dart';
import '../widgets/reminder_card.dart';

// Enum untuk mengatur Mode Tampilan
enum CalendarViewMode { daily, monthly, yearly }

class CalendarMainPage extends StatefulWidget {
  const CalendarMainPage({super.key});

  @override
  State<CalendarMainPage> createState() => _CalendarMainPageState();
}

class _CalendarMainPageState extends State<CalendarMainPage> {
  // --- STATE ---
  CalendarViewMode _currentView = CalendarViewMode.daily; // Default: Daily
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  // Dummy Data Event
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2025, 12, 21): [{'title': 'Event A', 'color': Colors.blue}],
  };

  // --- LOGIC ---

  // Fungsi Toggle: Daily -> Monthly -> Yearly -> Daily
  void _toggleViewMode() {
    setState(() {
      if (_currentView == CalendarViewMode.daily) {
        _currentView = CalendarViewMode.monthly;
      } else if (_currentView == CalendarViewMode.monthly) {
        _currentView = CalendarViewMode.yearly;
      } else {
        _currentView = CalendarViewMode.daily;
      }
    });
  }

  // Dipanggil saat tanggal dipilih (dari Monthly/Yearly)
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedMonth = date;
      // Opsional: Jika user memilih tanggal di Monthly/Yearly,
      // otomatis kembali ke Daily view untuk melihat detail jam
      if (_currentView != CalendarViewMode.daily) {
        _currentView = CalendarViewMode.daily;
      }
    });
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _focusedMonth = month;
    });
  }

  void _handleNavigation(int index) {
    final routes = [
      AppRoutes.home,
      AppRoutes.notes,
      AppRoutes.todo,
      AppRoutes.calendar
    ];
    if (index != 3) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  void _showAddEventDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Event Clicked')),
    );
  }

  void _handleSearch() {
    // Logika pencarian event
    showSearch(
        context: context,
        delegate: _EventSearchDelegate(_events) // Buat class delegate di bawah
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. APP BAR (Desain disamakan dengan CustomTopAppBar)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20, // Padding kiri disesuaikan
        toolbarHeight: 70,

        // BAGIAN KIRI: Logo & Brand (Persis CustomTopAppBar)
        title: Row(
          children: [
            SizedBox(
              width: 32.36,
              height: 30,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/Mindly_logo.svg',
                  width: 32.36,
                  height: 30,
                  fit: BoxFit.contain,
                  // Fallback jika aset belum ada
                  placeholderBuilder: (context) => const Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF004455),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Mindly',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004455),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        // BAGIAN KANAN: Search, Calendar Toggle, Add
        actions: [
          // 1. Search Icon
          IconButton(
            onPressed: _handleSearch,
            tooltip: 'Search Events',
            icon: const Icon(Icons.search, color: Color(0xFF1A1A1A), size: 26),
          ),

          // 2. Calendar Toggle Icon (Berubah icon sesuai mode)
          IconButton(
            onPressed: _toggleViewMode,
            tooltip: _getToggleTooltip(),
            icon: Icon(
                _getToggleIcon(),
                color: const Color(0xFF1A1A1A),
                size: 26
            ),
          ),

          // 3. Add Event Icon (+)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _showAddEventDialog,
              tooltip: 'Add Event',
              icon: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 30),
            ),
          ),
        ],
      ),

      // 2. BODY (Switch antara Daily, Monthly, Yearly)
      body: _buildBodyContent(),

      // 3. FAB (Tetap ada di bawah)
      floatingActionButton: GlobalExpandableFab(
        actions: [
          FabActionModel(
            icon: Icons.edit_outlined,
            tooltip: 'Quick Note',
            onTap: () {},
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 4. BOTTOM NAVBAR
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 3,
        onItemTapped: _handleNavigation,
      ),
    );
  }

  // --- HELPERS UNTUK UI ---

  Widget _buildBodyContent() {
    switch (_currentView) {
      case CalendarViewMode.monthly:
        return MonthlyViewWidget(
          focusedDay: _focusedMonth,
          selectedDay: _selectedDate,
          events: _events,
          onDaySelected: (selected, focused) => _onDateSelected(selected),
          onPageChanged: _onMonthChanged,
        );
      case CalendarViewMode.yearly:
        return YearlyViewWidget(
          currentYear: _focusedMonth.year,
          events: _events,
          onMonthTap: (month) {
            // Zoom in: Dari Yearly ke Monthly
            setState(() {
              _focusedMonth = month;
              _currentView = CalendarViewMode.monthly;
            });
          },
        );
      case CalendarViewMode.daily:
      return _buildDailyView();
    }
  }

  IconData _getToggleIcon() {
    switch (_currentView) {
      case CalendarViewMode.daily:
        return Icons.calendar_month_outlined; // Icon untuk ke Monthly
      case CalendarViewMode.monthly:
        return Icons.calendar_view_week_outlined; // Icon untuk ke Yearly/Zoom out
      case CalendarViewMode.yearly:
        return Icons.view_day_outlined; // Icon untuk kembali ke Daily
    }
  }

  String _getToggleTooltip() {
    switch (_currentView) {
      case CalendarViewMode.daily: return "Switch to Monthly";
      case CalendarViewMode.monthly: return "Switch to Yearly";
      case CalendarViewMode.yearly: return "Switch to Daily";
    }
  }

  // --- WIDGET DAILY VIEW (Timeline Stack) ---
  Widget _buildDailyView() {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini Calendar Horizontal
              MiniCalendarWidget(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
              ),

              const SizedBox(height: 24),

              // Header Schedule
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Schedule Today',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    // Menampilkan Tanggal terpilih di sebelah kanan
                    Text(
                      DateFormat('d MMM yyyy').format(_selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Timeline Widget
              _buildScheduleTimeline(),

              const SizedBox(height: 32),

              // Reminder Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Don\'t forget schedule for tomorrow',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF565A60),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Reminder Cards
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ReminderCardWidget(
                      time: '12.00 - 16.00',
                      title: 'Design new UX flow for Michael',
                    ),
                    SizedBox(height: 12),
                    ReminderCardWidget(
                      time: '12.00 - 16.00',
                      title: 'Design new UX flow for Michael',
                    ),
                    SizedBox(height: 100), // Spacing bawah
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TIMELINE BUILDER ---
  Widget _buildScheduleTimeline() {
    return SizedBox(
      height: 320,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: 600,
          child: Stack(
            children: [
              // A. Time Labels
              Positioned(
                left: 24,
                top: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeLabel('08.00'),
                    const SizedBox(height: 45),
                    _buildTimeLabel('10.00'),
                    const SizedBox(height: 45),
                    _buildTimeLabel('12.00'),
                    const SizedBox(height: 45),
                    _buildTimeLabel('14.00'),
                    const SizedBox(height: 45),
                    _buildTimeLabel('16.00'),
                    const SizedBox(height: 45),
                    _buildTimeLabel('18.00'),
                    const SizedBox(height: 45),
                    _buildTimeLabel('20.00'),
                  ],
                ),
              ),

              // B. Schedule Cards
              Positioned(
                left: 70,
                right: 24,
                top: 0,
                child: Column(
                  children: [
                    const ScheduleCardWidget(
                      title: 'Rapat dengan Bruce Wayne',
                      startTime: '08.00',
                      endTime: '10.00',
                      color: Color(0xFFFBAE38),
                      height: 64,
                    ),
                    const SizedBox(height: 45),
                    const ScheduleCardWidget(
                      title: 'Test wawasan kebangasaan di Dusun Wakanda',
                      startTime: '12.00',
                      endTime: '14.00',
                      color: Color(0xFFFBAE38),
                      height: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLabel(String time) {
    return Text(
      time,
      style: GoogleFonts.poppins(
        color: const Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 2.17,
        letterSpacing: 0.30,
      ),
    );
  }
}

// --- SEARCH DELEGATE PLACEHOLDER ---
class _EventSearchDelegate extends SearchDelegate {
  final Map<DateTime, List<Map<String, dynamic>>> events;
  _EventSearchDelegate(this.events);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back)
  );

  @override
  Widget buildResults(BuildContext context) => Center(child: Text('Results for "$query"'));

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Suggest Event 1')),
        ListTile(title: Text('Suggest Event 2')),
      ],
    );
  }
}