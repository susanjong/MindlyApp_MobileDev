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

// Enum untuk menentukan mode tampilan kalender
enum CalendarViewMode { daily, monthly, yearly }

class CalendarMainPage extends StatefulWidget {
  const CalendarMainPage({super.key});

  @override
  State<CalendarMainPage> createState() => _CalendarMainPageState();
}

class _CalendarMainPageState extends State<CalendarMainPage> {
  // Service Instances
  final EventService _eventService = EventService();
  final EventCategoryService _categoryService = EventCategoryService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // State Tampilan Kalender
  CalendarViewMode _currentView = CalendarViewMode.daily;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // State Data
  Map<String, Category> _categories = {};
  StreamSubscription? _categorySubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _checkPendingNotifications(); // Debugging notifikasi
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // --- DATA LOADING & HELPERS ---

  // Memuat kategori event dari Firebase secara realtime
  void _loadCategories() {
    _categorySubscription =
        _categoryService.getCategories(userId).listen((categories) {
          if (!mounted) return;

          setState(() {
            // Mapping list kategori ke Map agar akses lebih cepat by ID
            _categories = {
              for (final cat in categories) cat.id!: cat,
            };
          });
        });
  }

  // Debugging: Memeriksa antrian notifikasi lokal yang tertunda
  Future<void> _checkPendingNotifications() async {
    try {
      final pending = await _eventService.getPendingNotifications();
      debugPrint('📋 Total pending notifications: ${pending.length}');

      for (var notif in pending) {
        debugPrint('  - ID: ${notif.id}, Title: ${notif.title}, Payload: ${notif.payload}');
      }
    } catch (e) {
      debugPrint('❌ Error checking pending notifications: $e');
    }
  }

  // Helper konversi Hex String ke Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // --- LOGIC: UI INTERACTION ---

  // Mengganti mode tampilan (Harian -> Bulanan -> Tahunan -> Harian)
  void _toggleViewMode() {
    setState(() {
      switch (_currentView) {
        case CalendarViewMode.daily:
          _currentView = CalendarViewMode.monthly;
          break;
        case CalendarViewMode.monthly:
          _currentView = CalendarViewMode.yearly;
          break;
        case CalendarViewMode.yearly:
          _currentView = CalendarViewMode.daily;
          break;
      }
    });
  }

  // Handler saat tanggal dipilih
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedMonth = date;
      // Otomatis kembali ke tampilan harian saat tanggal dipilih
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
      AppRoutes.calendar,
    ];

    if (index != 3) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  // Menampilkan Bottom Sheet untuk tambah event
  void _showAddEventDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEventBottomSheet(),
    ).then((_) {
      // Refresh debug log notifikasi setelah event baru dibuat
      _checkPendingNotifications();
    });
  }

  // Menangani pencarian event
  Future<void> _handleSearch() async {
    try {
      // Ambil snapshot data sekali saja untuk pencarian
      final allEvents = await _eventService.getAllEvents(userId).first;
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarSearchPage(
            allEvents: allEvents,
            categories: _categories,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load events for search: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    // Menangani tombol kembali fisik (Back Button Android)
    // Urutan prioritas: View Tahunan -> Bulanan -> Harian -> Home Page
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (_currentView == CalendarViewMode.yearly) {
          setState(() => _currentView = CalendarViewMode.monthly);
          return;
        }

        if (_currentView == CalendarViewMode.monthly) {
          setState(() => _currentView = CalendarViewMode.daily);
          return;
        }

        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: CustomTopAppBar(
          isCalendarMode: true,
          isYearView: _currentView == CalendarViewMode.yearly,
          onSearchTap: _handleSearch,
          onToggleView: _toggleViewMode,
          onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notification),
        ),
        body: _buildBodyContent(),
        floatingActionButton: GlobalExpandableFab(
          actions: [
            FabActionModel(
              icon: Icons.edit_calendar_rounded,
              tooltip: 'Add Event',
              onTap: _showAddEventDialog,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: CustomNavBar(
          selectedIndex: 3,
          onItemTapped: _handleNavigation,
        ),
      ),
    );
  }

  // Switcher konten utama berdasarkan mode tampilan
  Widget _buildBodyContent() {
    switch (_currentView) {
      case CalendarViewMode.daily:
        return _buildDailyView();

      case CalendarViewMode.monthly:
        return StreamBuilder<List<Event>>(
          stream: _eventService.getEventsForMonth(userId, _focusedMonth),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final monthEvents = snapshot.data ?? [];
            return MonthlyViewWidget(
              currentMonth: _focusedMonth,
              selectedDate: _selectedDate,
              events: monthEvents,
              categories: _categories,
              onDateSelected: _onDateSelected,
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

      case CalendarViewMode.yearly:
        return StreamBuilder<List<Event>>(
          stream: _eventService.getAllEvents(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allEvents = snapshot.data ?? [];

            return YearlyViewWidget(
              currentYear: _focusedMonth.year,
              events: allEvents,
              onMonthTap: (month) {
                setState(() {
                  _focusedMonth = month;
                  _currentView = CalendarViewMode.monthly;
                });
              },
            );
          },
        );
    }
  }

  // Widget Tampilan Harian (Mini Calendar + Schedule List)
  Widget _buildDailyView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kalender Mini Horizontal
            MiniCalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
            ),
            const SizedBox(height: 10),

            // Header Daftar Jadwal
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

            // Daftar Event (Schedule List)
            Expanded(
              child: StreamBuilder<List<Event>>(
                stream: _eventService.getEventsForDate(userId, _selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data ?? [];

                  // Tampilan jika tidak ada event
                  if (events.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events for this date',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Render Daftar Event
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
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => EventDetailSheet(
                                event: event,
                                category: category,
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kolom Waktu
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
                              // Kartu Jadwal
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
        ),
      ),
    );
  }
}