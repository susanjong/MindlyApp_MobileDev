import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/features/notes/presentation/pages/notes_main_page.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../../calendar/data/model/event_model.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../profile/presentation/pages/profile.dart';

//TODO: Task item ini masukkin ke modelnya bgian file task ya
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
  String _userName = 'User';
  bool _isLoadingUserData = false;

  // TODO: ubah data dummy ini berdasarkan firestore
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
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Load user data from Firestore with real-time updates
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
      if (_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
        });
      }
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

    // show snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All completed tasks cleared',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<TaskItem> get _pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<TaskItem> get _completedTasks => _tasks.where((task) => task.isCompleted).toList();

  List<EventModel> _getEvents() { //TODO: ubah ini ke data dari firestore
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

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 11) {
      return 'Good Morning';
    } else if (hour >= 11 && hour < 15) {
      return 'Good Afternoon';
    } else if (hour >= 15 && hour < 18) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  void _navigateToNotesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotesMainPage()),
    );
  }

  void _navigateToEventsPage() {
    // TODO: Implement navigation to events page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Events page coming soon!',
          style: GoogleFonts.poppins(),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEvents();
    /*final notes = _getNotes();*/
    final completedTasksCount = _completedTasks.length;
    final totalTasks = _tasks.length;
    final progress = totalTasks > 0 ? completedTasksCount / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            CustomTopAppBar(
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountProfilePage()),
                );
              },
              onNotificationTap: () {
                // TODO: Implement notification functionality
              },
            ),

            // content with proper padding
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // greeting section with StreamBuilder for real-time updates
                        _buildGreetingSectionWithStream(),
                        const SizedBox(height: 24),

                        // daily progress card
                        _buildDailyProgressCard(progress, completedTasksCount, totalTasks),
                        const SizedBox(height: 24),

                        // Needs Attention Section
                        if (_pendingTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            icon: Icons.error_outline,
                            iconColor: const Color(0xFFFF6B6B),
                            title: 'Needs Attention',
                          ),
                          const SizedBox(height: 12),
                          ..._pendingTasks.asMap().entries.map((entry) {
                            final index = _tasks.indexOf(entry.value);
                            final task = entry.value;
                            return _buildPendingTaskItem(task, index);
                          }).toList(),
                          const SizedBox(height: 24),
                        ],

                        // completed Section
                        if (_completedTasks.isNotEmpty) ...[
                          _buildCompletedSectionHeader(),
                          const SizedBox(height: 12),
                          ..._completedTasks.asMap().entries.map((entry) {
                            final index = _tasks.indexOf(entry.value);
                            final task = entry.value;
                            return _buildCompletedTaskItem(task, index);
                          }).toList(),
                          const SizedBox(height: 24),
                        ],

                        // Today's Event Section
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

                        // Today's Notes Section
                        _buildSectionHeaderWithAction(
                          icon: Icons.note_outlined,
                          iconColor: const Color(0xFFFF9800),
                          title: "Today's Notes",
                          actionText: 'View All →',
                          onActionTap: _navigateToNotesPage,
                        ),
                        const SizedBox(height: 12),
                        /*...notes.map((note) => _buildNoteCard(note)).toList(),*/
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // widget builders for better code organization
  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()}, $_userName',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's make today productive!",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  // NEW: Greeting section with real-time updates using StreamBuilder
  Widget _buildGreetingSectionWithStream() {
    final userDataStream = AuthService.getUserDataStream();

    if (userDataStream == null) {
      return _buildGreetingSection();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDataStream,
      builder: (context, snapshot) {
        String displayName = _userName;

        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data();
          if (userData != null && userData['displayName'] != null) {
            displayName = userData['displayName'];
          }
        } else if (!snapshot.hasData) {
          displayName = AuthService.getUserDisplayName() ?? 'User';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, $displayName',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Let's make today productive!",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B6B6B),
              ),
            ),
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
              Text(
                'Daily Progress',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
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
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderWithAction({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(
            actionText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF0D5F5F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 8),
            Text(
              'Completed',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _clearAllCompletedTasks,
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            'Clear All',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFFFF6B6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTaskItem(TaskItem task, int index) {
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
          GestureDetector(
            onTap: () => _toggleTaskCompletion(index),
            child: Container(
              width: 33,
              height: 33,
              decoration: const ShapeDecoration(
                color: Colors.transparent,
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1.50,
                    color: Color(0xFF5784EB),
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
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B6B6B),
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'urgent',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFFF9800),
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
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskItem(TaskItem task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
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
              decoration: const ShapeDecoration(
                color: Color(0xFF4CAF50),
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1.50,
                    color: Color(0xFF4CAF50),
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
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9E9E9E),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
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
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B6B6B),
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
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B6B6B),
                        ),
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

  Widget _buildNoteCard(NoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                note.timeAgo,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF4A4A4A),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: CustomNavBar(
              selectedIndex: 0,
              onItemTapped: (index) {
                if (index == 1) {
                  _navigateToNotesPage();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}