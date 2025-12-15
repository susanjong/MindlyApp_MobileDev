import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/buttons/global_expandable_fab.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import 'calendar_search_page.dart';
import '../widgets/mini_calendar.dart';
import '../widgets/monthly_view.dart';
import '../widgets/yearly_view.dart';
import '../widgets/schedule_card.dart';
import '../widgets/add_event.dart';
import '../widgets/event_detail_sheet.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
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

  Future<void> _handleSearch() async {
    try {
      // Ambil data events sekali saja
      final allEvents = await _eventService.getAllEvents(userId).first;

      if (!mounted) return;

      // Navigasi ke Halaman Custom Search
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarSearchPage(
            allEvents: allEvents,
            categories: _categories,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load events for search: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. APP BAR
      appBar: CustomTopAppBar(
        isCalendarMode: true, // Aktifkan mode kalender
        isYearView: _currentView == CalendarViewMode.yearly,
        onSearchTap: _handleSearch,
        onToggleView: _toggleViewMode,
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        onNotificationTap: () {},
      ),

      // 2. BODY CONTENT (SWITCHER)
      body: _buildBodyContent(),

      // 3. GLOBAL EXPANDABLE FAB (Replaces standard FAB)
      floatingActionButton: GlobalExpandableFab(
        actions: [
          FabActionModel(
            icon: Icons.edit_calendar_rounded, // Icon untuk Add Event
            tooltip: 'Add Event',
            onTap: _showAddEventDialog,
          ),
          // Anda bisa menambahkan aksi lain di sini jika perlu (misal Add Task)
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
                    child: GestureDetector(
                      // Tambahkan interaksi tap untuk membuka detail
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EventDetailSheet(
                            event: event,
                            category: category,
                          ),
                        );
                      },
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
                              height: 80,
                            ),
                          ),
                        ],
                      ),
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
}