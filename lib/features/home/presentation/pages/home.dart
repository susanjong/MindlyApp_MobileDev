import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../../calendar/data/model/event_model.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/services/note_service.dart';
import '../../../notes/presentation/pages/notes_main_page.dart';
import '../../../profile/presentation/pages/profile.dart';
class TaskItem {
  String title;
  String time;
  String priority;
  bool isCompleted;

  TaskItem({
    required this.title,
    required this.time,
    required this.priority,
    this.isCompleted = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isNavBarVisible = true;
  final ScrollController _scrollController = ScrollController();
  final NoteService _noteService = NoteService();

  // List untuk menyimpan tasks
  List<TaskItem> _tasks = [
    TaskItem(
      title: 'Meeting with marketing team',
      time: 'Today',
      priority: 'urgent',
      isCompleted: false,
    ),
    TaskItem(
      title: 'Update website content',
      time: 'Today',
      priority: 'normal',
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // === Event Handlers (Scroll & Navigation) ===

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
    }
  }

  // ✅ FIX: Logic Navigasi disamakan dengan NotesMainPage
  void _handleNavigation(int index) {
    final routes = ['/home', '/notes', '/todo', '/calendar'];
    // Index 0 adalah Home, jadi jika bukan 0, pindah halaman
    if (index != 0) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  // Method for toggle task completion
  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _clearAllCompletedTasks() {
    setState(() {
      _tasks.removeWhere((task) => task.isCompleted);
    });
  }

  List<TaskItem> get _pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<TaskItem> get _completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

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
      EventModel(
        title: 'Review Design Mockup',
        time: 'Today, 4:00 PM',
        location: 'Coffee Shop',
        color: const Color(0xFF66BB6A),
      ),
    ];
  }

  List<NoteModel> _getRecentNotes() {
    final allNotes = List<NoteModel>.from(_noteService.allNotes);
    allNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return allNotes.take(2).toList();
  }

  // === Build Methods ===

  @override
  Widget build(BuildContext context) {
    final events = _getEvents();
    final notes = _getRecentNotes();
    final completedTasksCount = _completedTasks.length;
    final totalTasks = _tasks.length;
    final progress = totalTasks > 0 ? completedTasksCount / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ FIX: Menambahkan Bottom Navigation Bar ke Scaffold
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            CustomTopAppBar(
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountProfilePage()),
                );
              },
              onNotificationTap: () {},
            ),

            // Content with proper padding
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Greeting Section
                      const Text(
                        'Good Morning, Susan Jong',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Let's make today productive!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6B6B),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ========== Daily progress card ==========
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daily Progress',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFFE8E8E8),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8BC34A),
                                ),
                                minHeight: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$completedTasksCount of $totalTasks tasks completed',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B6B6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ========== NEEDS ATTENTION SECTION ==========
                      if (_pendingTasks.isNotEmpty) ...[
                        Row(
                          children: const [
                            Icon(Icons.error_outline,
                                color: Color(0xFFFF6B6B), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Needs Attention',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._pendingTasks.asMap().entries.map((entry) {
                          final index = _tasks.indexOf(entry.value);
                          final task = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _toggleTaskCompletion(index),
                                  child: Container(
                                    width: 33,
                                    height: 33,
                                    decoration: ShapeDecoration(
                                      color: Colors.transparent,
                                      shape: OvalBorder(
                                        side: BorderSide(
                                          width: 1.50,
                                          color: const Color(0xFF5784EB),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Color(0xFF6B6B6B),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            task.time,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B6B6B),
                                            ),
                                          ),
                                          if (task.priority == 'urgent') ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3E0),
                                                borderRadius:
                                                BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'urgent',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFFF9800),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],

                      // ========== COMPLETED SECTION ==========
                      if (_completedTasks.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.check_circle,
                                    color: Color(0xFF4CAF50), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _clearAllCompletedTasks,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                              ),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFF6B6B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._completedTasks.asMap().entries.map((entry) {
                          final index = _tasks.indexOf(entry.value);
                          final task = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _toggleTaskCompletion(index),
                                  child: Container(
                                    width: 33,
                                    height: 33,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF4CAF50),
                                      shape: OvalBorder(
                                        side: BorderSide(
                                          width: 1.50,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF9E9E9E),
                                          decoration:
                                          TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],

                      // ========== TODAY'S EVENT SECTION ==========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calendar_today,
                                  color: Color(0xFF0D5F5F), size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Today's Event",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // ✅ FIX: Gunakan named route agar konsisten dengan navbar
                              Navigator.pushReplacementNamed(context, '/calendar');
                            },
                            child: const Text(
                              'View All →',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0D5F5F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Event Cards
                      ...events
                          .map((event) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE0E0E0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 40,
                              decoration: BoxDecoration(
                                color: event.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Color(0xFF6B6B6B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B6B6B),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 12,
                                        color: Color(0xFF6B6B6B),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B6B6B),
                                          ),
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      const SizedBox(height: 24),

                      // ========== TODAY'S NOTES SECTION ==========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.note_outlined,
                                  color: Color(0xFFFF9800), size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Today's Notes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // ✅ FIX: Gunakan replacement named route agar bottom nav aktif di tab 'Notes'
                              Navigator.pushReplacementNamed(context, '/notes');
                            },
                            child: const Text(
                              'View All →',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0D5F5F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Note Cards
                      if (notes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.note_outlined,
                                  size: 48,
                                  color: Color(0xFFE0E0E0),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No notes yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...notes
                            .map((note) => GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-note',
                              arguments: note.id,
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(note.color),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (note.isFavorite)
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                right: 8),
                                            child: Icon(
                                              Icons.favorite,
                                              color: Color(0xFFFF6B6B),
                                              size: 16,
                                            ),
                                          ),
                                        Text(
                                          note.timeAgo,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B6B6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  note.content,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4A4A4A),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ))
                            .toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // agar bisa mengakses context dan variable navigasi
  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _isNavBarVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isNavBarVisible ? 1.0 : 0.0,
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: 0, // Index 0 untuk HOME
            onItemTapped: _handleNavigation,
          ),
        ),
      ),
    );
  }
}