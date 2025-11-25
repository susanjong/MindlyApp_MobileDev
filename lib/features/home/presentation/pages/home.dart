import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../../../config/routes/routes.dart';
import '../../../calendar/data/model/event_model.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/services/note_service.dart';

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

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
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

  @override
  Widget build(BuildContext context) {
    final events = _getEvents();
    final completedTasksCount = _completedTasks.length;
    final totalTasks = _tasks.length;
    final progress = totalTasks > 0 ? completedTasksCount / totalTasks : 0.0;

    // ✅ GUNAKAN STREAMBUILDER untuk get recent notes
    return StreamBuilder<List<NoteModel>>(
      stream: _noteService.getNotesStream(),
      builder: (context, snapshot) {
        // Get 2 notes terbaru
        final allNotes = snapshot.data ?? [];
        final recentNotes = allNotes.take(2).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: _buildBottomNavBar(),
          body: SafeArea(
            child: Column(
              children: [
                CustomTopAppBar(
                  onProfileTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                  onNotificationTap: () {},
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          // Daily Progress Card
                          _buildDailyProgressCard(progress, completedTasksCount, totalTasks),

                          const SizedBox(height: 24),

                          // Pending Tasks
                          if (_pendingTasks.isNotEmpty) ...[
                            _buildSectionHeader('Needs Attention', Icons.error_outline, const Color(0xFFFF6B6B)),
                            const SizedBox(height: 12),
                            ..._buildTasksList(_pendingTasks, false),
                            const SizedBox(height: 24),
                          ],

                          // Completed Tasks
                          if (_completedTasks.isNotEmpty) ...[
                            _buildCompletedHeader(),
                            const SizedBox(height: 12),
                            ..._buildTasksList(_completedTasks, true),
                            const SizedBox(height: 24),
                          ],

                          // Today's Events
                          _buildEventsSection(events),

                          const SizedBox(height: 24),

                          // Today's Notes
                          _buildNotesSection(recentNotes),

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
      },
    );
  }

  // === HELPER METHODS ===

  Widget _buildDailyProgressCard(double progress, int completed, int total) {
    return Container(
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
            '$completed of $total tasks completed',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
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
    );
  }

  List<Widget> _buildTasksList(List<TaskItem> tasks, bool isCompleted) {
    return tasks.asMap().entries.map((entry) {
      final index = _tasks.indexOf(entry.value);
      final task = entry.value;
      return _buildTaskCard(task, index, isCompleted);
    }).toList();
  }

  Widget _buildTaskCard(TaskItem task, int index, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTaskCompletion(index),
            child: Container(
              width: 33,
              height: 33,
              decoration: ShapeDecoration(
                color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1.50,
                    color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF5784EB),
                  ),
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCompleted)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFF6B6B6B)),
                      const SizedBox(width: 4),
                      Text(
                        task.time,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
                      ),
                      if (task.priority == 'urgent') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4),
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
                  )
                else
                  Text(
                    task.time,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? const Color(0xFF9E9E9E) : const Color(0xFF1A1A1A),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(List<EventModel> events) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_today, color: Color(0xFF0D5F5F), size: 20),
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
                Navigator.pushReplacementNamed(context, AppRoutes.calendar);
              },
              child: const Text(
                'View All →',
                style: TextStyle(fontSize: 13, color: Color(0xFF0D5F5F)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...events.map((event) => _buildEventCard(event)).toList(),
      ],
    );
  }

  Widget _buildEventCard(EventModel event) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Icon(Icons.access_time, size: 12, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Text(event.time, style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B))),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(List<NoteModel> notes) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.note_outlined, color: Color(0xFFFF9800), size: 20),
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
                Navigator.pushReplacementNamed(context, AppRoutes.notes);
              },
              child: const Text(
                'View All →',
                style: TextStyle(fontSize: 13, color: Color(0xFF0D5F5F)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.note_outlined, size: 48, color: Color(0xFFE0E0E0)),
                  SizedBox(height: 8),
                  Text(
                    'No notes yet',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _isNavBarVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isNavBarVisible ? 1.0 : 0.0,
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: 0,
            onItemTapped: _handleNavigation,
          ),
        ),
      ),
    );
  }
}