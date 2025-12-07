import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ✅ Import Routes & Auth
import '../../../../config/routes/routes.dart';
import '../../../../core/services/auth_service.dart';

// ✅ Import Navigation Widgets
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';

// ✅ Import Feature Pages
import '../../../notes/presentation/pages/notes_main_page.dart';
import '../../../calendar/data/model/event_model.dart';
import '../../../profile/presentation/pages/profile.dart';

// ✅ Import Todo Service, Model, & TaskItem Widget
import '../../../to_do_list/data/models/todo_model.dart';
import '../../../to_do_list/data/services/todo_services.dart';
import '../../../to_do_list/presentation/widgets/task_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isNavBarVisible = true;
  final ScrollController _scrollController = ScrollController();

  // ✅ Service Firebase
  final TodoService _todoService = TodoService();

  String _userName = 'User';

  // ✅ STATE BARU: Menyimpan ID task yang baru saja diselesaikan di sesi ini
  final Set<String> _recentlyCompletedIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index) {
    final routes = [
      AppRoutes.home,
      AppRoutes.notes,
      AppRoutes.todo,
      AppRoutes.calendar,
    ];
    if (index != 0) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  Future<void> _loadUserData() async {
    final displayName = AuthService.getUserDisplayName();
    if (mounted) setState(() => _userName = displayName ?? 'User');
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
    }
  }

  // Helper: Convert Model ke Map
  Map<String, dynamic> _mapModelToTaskItem(TodoModel todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'time': DateFormat('h:mm a').format(todo.deadline),
      'date': DateFormat('dd MMM').format(todo.deadline),
      'deadline': todo.deadline,
      'completed': todo.isCompleted,
      'category': todo.category,
    };
  }

  // Logic Clear All (Hanya menghapus yang ada di list tampilan)
  void _clearAllCompletedTasks(List<TodoModel> displayedCompletedTasks) async {
    for (var task in displayedCompletedTasks) {
      await _todoService.deleteTodo(task.id);
    }
    // Bersihkan local state juga
    setState(() {
      _recentlyCompletedIds.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cleared tasks')),
      );
    }
  }

  List<EventModel> _getEvents() {
    return [
      EventModel(
        title: 'Team meeting preparation',
        time: 'Today, 3:00 PM',
        location: 'PT XYZ (Office)',
        color: const Color(0xFFFF6B6B),
      ),
      EventModel(
        title: 'Update Website Client',
        time: 'Today, 2:00 PM',
        location: 'Remote',
        color: const Color(0xFFFFA726),
      ),
    ];
  }

  void _navigateToNotesPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesMainPage()));
  }

  void _navigateToEventsPage() {
    // Navigator.pushNamed(context, AppRoutes.calendar);
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEvents();

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<TodoModel>>(
        stream: _todoService.getTodosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTodos = snapshot.data ?? [];

          // 1. Needs Attention (Belum Selesai, Ambil 2 Teratas)
          final pendingTodos = allTodos.where((t) => !t.isCompleted).toList();
          final topTwoNeedsAttention = pendingTodos.take(2).toList();

          // ✅ 2. Completed (Hanya yang baru saja diklik user di sesi ini)
          // Logic: Task harus statusnya complete DI DATABASE && ID-nya ada di _recentlyCompletedIds
          final recentCompletedTodos = allTodos.where((t) {
            return t.isCompleted && _recentlyCompletedIds.contains(t.id);
          }).toList();

          // Hitung Progress Global (Tetap pakai data asli database)
          final totalTasks = allTodos.length;
          // Hitung completed asli dari DB untuk progress bar yang akurat
          final totalCompletedDB = allTodos.where((t) => t.isCompleted).length;
          final progress = totalTasks > 0 ? totalCompletedDB / totalTasks : 0.0;

          return SafeArea(
            child: Column(
              children: [
                CustomTopAppBar(
                  onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  onNotificationTap: () {},
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUserData,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGreetingSectionWithStream(),
                            const SizedBox(height: 24),

                            _buildDailyProgressCard(progress, totalCompletedDB, totalTasks),
                            const SizedBox(height: 24),

                            // --- NEEDS ATTENTION SECTION ---
                            if (topTwoNeedsAttention.isNotEmpty) ...[
                              _buildSectionHeader(
                                icon: Icons.error_outline,
                                iconColor: const Color(0xFFFF6B6B),
                                title: 'Needs Attention',
                              ),
                              const SizedBox(height: 12),
                              ...topTwoNeedsAttention.map((todo) => TaskItem(
                                task: _mapModelToTaskItem(todo),
                                onToggle: () {
                                  // ✅ LOGIC PENTING:
                                  // 1. Update ke Firebase
                                  _todoService.toggleTodoStatus(todo.id, todo.isCompleted);

                                  // 2. Masukkan ID ke list "Recently Completed" agar tampil di bawah
                                  if (!todo.isCompleted) { // Jika tadinya belum selesai
                                    setState(() {
                                      _recentlyCompletedIds.add(todo.id);
                                    });
                                  }
                                },
                                onDelete: () => _todoService.deleteTodo(todo.id),
                              )).toList(),
                              const SizedBox(height: 24),
                            ],

                            // --- COMPLETED SECTION (Hanya yang baru diklik) ---
                            if (recentCompletedTodos.isNotEmpty) ...[
                              _buildCompletedSectionHeader(recentCompletedTodos),
                              const SizedBox(height: 12),
                              ...recentCompletedTodos.map((todo) => TaskItem(
                                task: _mapModelToTaskItem(todo),
                                onToggle: () {
                                  // Kalau di-uncheck, hapus dari recent list dan update DB
                                  _todoService.toggleTodoStatus(todo.id, todo.isCompleted);
                                  setState(() {
                                    _recentlyCompletedIds.remove(todo.id);
                                  });
                                },
                                onDelete: () => _todoService.deleteTodo(todo.id),
                              )).toList(),
                              const SizedBox(height: 24),
                            ],

                            // Events & Notes
                            _buildSectionHeaderWithAction(
                              icon: Icons.calendar_today,
                              iconColor: const Color(0xFF0D5F5F),
                              title: "Today's Event",
                              actionText: 'View All →',
                              onActionTap: _navigateToEventsPage,
                            ),
                            const SizedBox(height: 12),
                            ...events.map((event) => _buildEventCard(event)).toList(),
                            const SizedBox(height: 24),

                            _buildSectionHeaderWithAction(
                              icon: Icons.note_outlined,
                              iconColor: const Color(0xFFFF9800),
                              title: "Today's Notes",
                              actionText: 'View All →',
                              onActionTap: _navigateToNotesPage,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ... (Sisa Widget Helpers tetap sama seperti sebelumnya) ...
  // _buildGreetingSectionWithStream, _buildDailyProgressCard, dll.

  Widget _buildGreetingSectionWithStream() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService.getUserDataStream(),
      builder: (context, snapshot) {
        String displayName = _userName;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          displayName = snapshot.data!.data()!['displayName'] ?? _userName;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, $displayName', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            Text("Let's make today productive!", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B6B6B))),
          ],
        );
      },
    );
  }

  Widget _buildDailyProgressCard(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0E0E0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Daily Progress', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
            Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50))),
          ]),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFE8E8E8), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)), minHeight: 12)),
          const SizedBox(height: 12),
          Text('$completed of $total tasks completed', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B6B6B))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required Color iconColor, required String title}) {
    return Row(children: [Icon(icon, color: iconColor, size: 20), const SizedBox(width: 8), Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)))]);
  }

  Widget _buildCompletedSectionHeader(List<TodoModel> completedTodos) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20), const SizedBox(width: 8), Text('Completed', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)))]),
      TextButton(
        onPressed: () => _clearAllCompletedTasks(completedTodos),
        style: TextButton.styleFrom(backgroundColor: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
        child: Text('Clear All', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Widget _buildSectionHeaderWithAction({required IconData icon, required Color iconColor, required String title, required String actionText, required VoidCallback onActionTap}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [Icon(icon, color: iconColor, size: 20), const SizedBox(width: 8), Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)))]),
      TextButton(onPressed: onActionTap, child: Text(actionText, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF0D5F5F)))),
    ]);
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE0E0E0))),
      child: Row(children: [
        Container(width: 8, height: 40, decoration: BoxDecoration(color: event.color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time, size: 12, color: Color(0xFF6B6B6B)),
            const SizedBox(width: 4),
            Text(event.time, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B6B6B))),
            const SizedBox(width: 12),
            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF6B6B6B)),
            const SizedBox(width: 4),
            Expanded(child: Text(event.location, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B6B6B)), overflow: TextOverflow.ellipsis)),
          ])
        ]))
      ]),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isNavBarVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isNavBarVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: SafeArea(child: CustomNavBar(selectedIndex: 0, onItemTapped: _handleNavigation)),
        ),
      ),
    );
  }
}