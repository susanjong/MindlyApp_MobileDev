import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

// Import Routes & Widgets
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../widgets/mini_calendar.dart';
import '../widgets/monthly_view.dart';
import '../widgets/yearly_view.dart';
import '../widgets/schedule_card.dart';
import '../widgets/reminder_card.dart';
import '../widgets/add_event.dart';

// Import Models & Services
import '../../data/models/event_model.dart';
import '../../data/services/category_service.dart';
import '../../data/services/event_service.dart';

// Enum untuk mengatur Mode Tampilan
enum CalendarViewMode { daily, monthly, yearly }

class CalendarMainPage extends StatefulWidget {
  const CalendarMainPage({super.key});

  @override
  State<CalendarMainPage> createState() => _CalendarMainPageState();
}

class _CalendarMainPageState extends State<CalendarMainPage> {
  // --- SERVICES & DATA ---
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // --- STATE ---
  CalendarViewMode _currentView = CalendarViewMode.daily; // Default Daily
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now(); // Untuk Monthly/Yearly navigation

  Map<String, Category> _categories = {};
  StreamSubscription? _categorySubscription;
  final ScrollController _scrollController = ScrollController();

  // Dummy data untuk Yearly View (karena logic yearly complex)
  // Anda bisa menggantinya nanti dengan logic fetch setahun
  final Map<DateTime, List<dynamic>> _yearlyEventsDummy = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIC DATA ---

  void _loadCategories() {
    _categorySubscription = _categoryService.getCategories(userId).listen((categories) {
      if (mounted) {
        setState(() {
          _categories = {for (var cat in categories) cat.id!: cat};
        });
      }
    });
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // --- LOGIC UI & NAVIGASI ---

  // Toggle: Daily -> Monthly -> Yearly -> Daily
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

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedMonth = date;
      // Jika user memilih tanggal di monthly/yearly, kembali ke daily view
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

  // Navigasi Bottom Bar
  void _handleNavigation(int index) {
    final routes = [
      AppRoutes.home,
      AppRoutes.notes,
      AppRoutes.todo,
      AppRoutes.calendar
    ];
    // Index 3 adalah halaman ini sendiri
    if (index != 3) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  void _showAddEventDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEventBottomSheet(),
    );
  }

  void _handleSearch() {
    // TODO: Implement Real Search with Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Search feature coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        toolbarHeight: 70,

        // KIRI: Logo
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

        // KANAN: Actions
        actions: [
          IconButton(
            onPressed: _handleSearch,
            tooltip: 'Search Events',
            icon: const Icon(Icons.search, color: Color(0xFF1A1A1A), size: 26),
          ),
          IconButton(
            onPressed: _toggleViewMode,
            tooltip: _getToggleTooltip(),
            icon: Icon(
              _getToggleIcon(),
              color: const Color(0xFF1A1A1A),
              size: 26,
            ),
          ),
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

      // 2. BODY CONTENT (SWITCHER)
      body: _buildBodyContent(),

      // 3. FAB
      floatingActionButton: GestureDetector(
        onTap: _showAddEventDialog,
        child: Container(
          width: 59,
          height: 59,
          decoration: const ShapeDecoration(
            color: Color(0xFFD732A8),
            shape: OvalBorder(),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 4. BOTTOM NAVBAR
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 3,
        onItemTapped: _handleNavigation,
      ),
    );
  }

  // --- WIDGET SWITCHER ---

  Widget _buildBodyContent() {
    switch (_currentView) {

    // TAMPILAN HARIAN (DEFAULT)
      case CalendarViewMode.daily:
        return _buildDailyView();

    // TAMPILAN BULANAN (MENGGUNAKAN LOGIC LAMA/FIREBASE)
      case CalendarViewMode.monthly:
        return StreamBuilder<List<Event>>(
          stream: _eventService.getEventsForMonth(userId, _focusedMonth),
          builder: (context, snapshot) {
            List<Event> monthEvents = [];
            if (snapshot.hasData) {
              monthEvents = snapshot.data!;
            }

            // Konversi List<Event> ke format widget MonthlyView
            // atau gunakan widget MonthlyView yang sudah support List<Event>
            return MonthlyViewWidget(
              currentMonth: _focusedMonth,
              selectedDate: _selectedDate,
              events: monthEvents, // Pass real events
              categories: _categories,
              onDateSelected: (date) {
                // Saat tanggal dipilih di monthly view, masuk ke daily view tanggal tsb
                _onDateSelected(date);
              },
              onPreviousMonth: () {
                setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                });
              },
              onNextMonth: () {
                setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                });
              },
            );
          },
        );

    // TAMPILAN TAHUNAN
      case CalendarViewMode.yearly:
        return YearlyViewWidget(
          currentYear: _focusedMonth.year,
          events: _yearlyEventsDummy, // Sementara dummy/kosong
          onMonthTap: (month) {
            setState(() {
              _focusedMonth = month;
              _currentView = CalendarViewMode.monthly;
            });
          },
        );
    }
  }

  // --- DAILY VIEW IMPLEMENTATION ---

  Widget _buildDailyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Mini Calendar (Horizontal)
        MiniCalendarWidget(
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
        ),

        const SizedBox(height: 10),

        // 2. Header Schedule
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

        // 3. Timeline / List Event (Real-time Firebase)
        Expanded(
          child: StreamBuilder<List<Event>>(
            stream: _eventService.getEventsForDate(userId, _selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'No events for this date',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Render Timeline List
              return ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final category = _categories[event.categoryId];
                  final color = category != null
                      ? _getColorFromHex(category.color)
                      : const Color(0xFF5683EB);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Label
                        SizedBox(
                          width: 50,
                          child: Text(
                            DateFormat('HH:mm').format(event.startTime),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Schedule Card
                        Expanded(
                          child: ScheduleCardWidget(
                            title: event.title,
                            startTime: DateFormat('HH:mm').format(event.startTime),
                            endTime: DateFormat('HH:mm').format(event.endTime),
                            color: color,
                            height: 80, // Dynamic height if needed
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- HELPERS UI ---

  IconData _getToggleIcon() {
    switch (_currentView) {
      case CalendarViewMode.daily:
        return Icons.calendar_month_outlined;
      case CalendarViewMode.monthly:
        return Icons.calendar_view_week_outlined;
      case CalendarViewMode.yearly:
        return Icons.view_day_outlined;
    }
  }

  String _getToggleTooltip() {
    switch (_currentView) {
      case CalendarViewMode.daily:
        return "Switch to Monthly";
      case CalendarViewMode.monthly:
        return "Switch to Yearly";
      case CalendarViewMode.yearly:
        return "Switch to Daily";
    }
  }
}

// Delegate Search (Placeholder)
class _EventSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => Center(child: Text('Results for "$query"'));

  @override
  Widget buildSuggestions(BuildContext context) => const Center(child: Text('Search events...'));
}