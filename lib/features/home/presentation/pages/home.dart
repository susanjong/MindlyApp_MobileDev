import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../../notes/presentation/pages/note_editor_page.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/services/note_service.dart';
import '../../../calendar/data/models/event_model.dart';
import '../../../to_do_list/data/models/todo_model.dart';
import '../../../to_do_list/data/services/todo_services.dart';
import '../../../to_do_list/presentation/widgets/task_item.dart';
import '../../../calendar/data/services/event_service.dart';
import '../../../calendar/data/services/category_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isNavBarVisible = true;
  final ScrollController _scrollController = ScrollController();

  final TodoService _todoService = TodoService();
  final NoteService _noteService = NoteService();
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();

  Map<String, Category> _categories = {};
  String? _currentUserId;
  String _userName = 'User';

  // Variable untuk logika back button
  DateTime? currentBackPressTime;

  late Stream<List<TodoModel>> _todoStream;
  late Stream<List<NoteModel>> _noteStream;
  late Stream<List<Event>> _eventStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _todoStream = _todoService.getTodosStream();
    _noteStream = _noteService.getNotesStream();
    _eventStream = Stream.value([]);

    _scrollController.addListener(_onScroll);
    _loadUserData();
    _initCalendarData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _initCalendarData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _eventStream = _eventService.getEventsForDate(_currentUserId!, DateTime.now());

      _categoryService.getCategories(_currentUserId!).listen((categories) {
        if (mounted) {
          setState(() {
            _categories = {for (var cat in categories) cat.id!: cat};
          });
        }
      });
    }
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
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && userData['displayName'] != null) {
        if (mounted) {
          setState(() {
            _userName = userData['displayName'];
          });
        }
      } else {
        final displayName = AuthService.getUserDisplayName();
        if (mounted) {
          setState(() {
            _userName = displayName ?? 'User';
          });
        }
      }
    } catch (e) {
      final displayName = AuthService.getUserDisplayName();
      if (mounted) {
        setState(() {
          _userName = displayName ?? 'User';
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
    }
  }

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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return 'Good Morning';
    if (hour >= 11 && hour < 15) return 'Good Afternoon';
    if (hour >= 15 && hour < 18) return 'Good Evening';
    return 'Good Night';
  }

  void _navigateToNotesPage() => Navigator.pushNamed(context, AppRoutes.notes);
  void _navigateToEventsPage() => Navigator.pushNamed(context, AppRoutes.calendar);

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  // Extract plain text from JSON content
  String _getPlainText(String jsonContent) {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonContent);
      return jsonData.map((op) => op['insert'].toString()).join().trim();
    } catch (e) {
      return jsonContent;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ IMPLEMENTASI POPSCOPE UNTUK DOUBLE TAP EXIT
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        // Keluar aplikasi jika tekan 2x
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              CustomTopAppBar(
                onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notification),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadUserData();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: StreamBuilder<List<TodoModel>>(
                        stream: _todoStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final allTodos = snapshot.data ?? [];
                          final pendingTodos = allTodos.where((t) => !t.isCompleted).toList();
                          final topTwoNeedsAttention = pendingTodos.take(2).toList();
                          final totalTasks = allTodos.length;
                          final completedCount = allTodos.where((t) => t.isCompleted).length;
                          final progress = totalTasks > 0 ? completedCount / totalTasks : 0.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreetingSectionWithStream(),
                              const SizedBox(height: 24),
                              _buildDailyProgressCard(progress, completedCount, totalTasks),
                              const SizedBox(height: 24),

                              if (topTwoNeedsAttention.isNotEmpty) ...[
                                _buildSectionHeader(
                                  icon: Icons.error_outline,
                                  iconColor: const Color(0xFFFF6B6B),
                                  title: 'Needs Attention',
                                ),
                                const SizedBox(height: 12),
                                ...topTwoNeedsAttention.map((todo) => TaskItem(
                                  task: _mapModelToTaskItem(todo),
                                  onToggle: () async {
                                    await _todoService.toggleTodoStatus(todo.id, todo.isCompleted);
                                  },
                                  onDelete: () => _todoService.deleteTodo(todo.id),
                                )),
                                const SizedBox(height: 24),
                              ],

                              _buildSectionHeaderWithAction(
                                icon: Icons.calendar_today,
                                iconColor: const Color(0xFF0D5F5F),
                                title: "Today's Event",
                                actionText: 'View All →',
                                onActionTap: _navigateToEventsPage,
                              ),
                              const SizedBox(height: 12),
                              _buildEventsStream(),
                              const SizedBox(height: 24),

                              _buildSectionHeaderWithAction(
                                icon: Icons.note_outlined,
                                iconColor: const Color(0xFFFF9800),
                                title: "Today's Notes",
                                actionText: 'View All →',
                                onActionTap: _navigateToNotesPage,
                              ),
                              const SizedBox(height: 12),
                              _buildNotesStream(),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // --- WIDGET HELPERS --- (Sama seperti sebelumnya)

  Widget _buildNotesStream() {
    return StreamBuilder<List<NoteModel>>(
      stream: _noteStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return Text('Error loading notes', style: GoogleFonts.poppins(color: Colors.red));
        }

        final allNotes = snapshot.data ?? [];
        final todayNotes = allNotes.where((note) => _isToday(note.updatedAt)).toList();

        if (todayNotes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("No notes updated today", style: GoogleFonts.poppins(color: Colors.grey), textAlign: TextAlign.center),
          );
        }

        todayNotes.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: todayNotes.take(2).map((note) => _buildNoteCard(note)).toList(),
        );
      },
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    final plainTextContent = _getPlainText(note.content);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditorPage(noteId: note.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(note.color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title.isNotEmpty ? note.title : "Untitled Note",
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plainTextContent.isNotEmpty ? plainTextContent : "No additional content",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _noteService.toggleFavorite(note.id, note.isFavorite);
              },
              child: Icon(
                note.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: note.isFavorite ? Colors.red.shade400 : Colors.black54,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsStream() {
    if (_currentUserId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
        child: Text("Please sign in to view events", style: GoogleFonts.poppins(color: Colors.grey), textAlign: TextAlign.center),
      );
    }

    return StreamBuilder<List<Event>>(
      stream: _eventStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return Text('Error loading events', style: GoogleFonts.poppins(color: Colors.red));
        }

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Text("No events scheduled for today", style: GoogleFonts.poppins(color: Colors.grey), textAlign: TextAlign.center),
          );
        }

        return Column(
          children: events.take(3).map((event) {
            final category = _categories[event.categoryId];
            return _buildRealEventCard(event, category);
          }).toList(),
        );
      },
    );
  }

  Widget _buildRealEventCard(Event event, Category? category) {
    final categoryColor = category != null ? _getColorFromHex(category.color) : const Color(0xFF5683EB);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 40, decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Text('${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B6B6B))),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.description_outlined, size: 12, color: Color(0xFF6B6B6B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.description, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B6B6B)), overflow: TextOverflow.ellipsis),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSectionWithStream() {
    final userDataStream = AuthService.getUserDataStream();
    if (userDataStream == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_getGreeting()}, $_userName', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Text("Let's make today productive!", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B6B6B))),
        ],
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDataStream,
      builder: (context, snapshot) {
        String displayName = _userName;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          displayName = snapshot.data!.data()!['displayName'] ?? _userName;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getGreeting()}, $displayName', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Progress', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
              Text('${(progress * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50))),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFE8E8E8), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)), minHeight: 12),
          ),
          const SizedBox(height: 12),
          Text('$completed of $total tasks completed', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B6B6B))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required Color iconColor, required String title}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildSectionHeaderWithAction({required IconData icon, required Color iconColor, required String title, required String actionText, required VoidCallback onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
          ],
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(actionText, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF0D5F5F))),
        ),
      ],
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: SafeArea(child: CustomNavBar(selectedIndex: 0, onItemTapped: _handleNavigation)),
        ),
      ),
    );
  }
}