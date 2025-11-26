import 'package:flutter/material.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../widgets/task_item.dart';
import 'package:notesapp/core/services/auth_service.dart';

class MainTodoScreen extends StatefulWidget {
  final String? username;

  const MainTodoScreen({super.key, this.username});

  @override
  State<MainTodoScreen> createState() => _MainTodoScreenState();
}

class _MainTodoScreenState extends State<MainTodoScreen> {
  int selectedDay = 16; // Tuesday selected
  String _username = 'User';
  int _selectedNavIndex = 2; // Todo tab selected
  bool _isLoading = true;

  final List<Map<String, dynamic>> tasks = [
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
  ];

  // Susan added for get full name and copy into hello 'user' from firestore
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // get data user from firestore
  Future<void> _loadUserData() async {
    try {
      if (widget.username != null && widget.username!.isNotEmpty) {
        setState(() {
          _username = widget.username!;
          _isLoading = false;
        });
        return;
      }

      final userData = await AuthService.getUserData();

      if (userData != null) {
        setState(() {
          // priority: displayName > email > 'user'
          _username = userData['displayName'] ??
              userData['email']?.split('@')[0] ??
              'User';
          _isLoading = false;
        });
      } else {
        // Fall back into firebase auth if error get data
        final displayName = AuthService.getUserDisplayName();
        final email = AuthService.getUserEmail();

        setState(() {
          _username = displayName ??
              email?.split('@')[0] ??
              'User';
          _isLoading = false;
        });
      }
    } catch (e) {
      // if error, use fallback
      setState(() {
        _username = AuthService.getUserDisplayName() ??
            AuthService.getUserEmail()?.split('@')[0] ??
            'User';
        _isLoading = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1: // Notes
        Navigator.pushReplacementNamed(context, AppRoutes.notes);
        break;
      case 2: // Todo (current page)
      // Already on Todo page
        break;
      case 3: // Calendar
        Navigator.pushReplacementNamed(context, AppRoutes.calendar);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopAppBar(
        onProfileTap: () {
          Navigator.pushNamed(context, AppRoutes.profile);
        },
        onNotificationTap: () {
          // Navigator.pushNamed(context, '/notifications');
        },
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          // Fixed Content Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Hello, $_username!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Task Summary
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'You have '),
                      TextSpan(
                        text: '## things to do',
                        style: TextStyle(color: Color(0xFFFFB74D)),
                      ),
                      TextSpan(text: '\nthis month'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status Cards
                SizedBox(
                  height: 130,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          '8',
                          'All',
                          const Color(0xFF318F61),
                          const Color(0xFFFEF4FC),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          '6',
                          'Urgent',
                          const Color(0xFFF4BF2A),
                          const Color(0xFFF6FAFD),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusCard(
                          '2',
                          'Overdue',
                          const Color(0xFFE5526E),
                          const Color(0xFFF8F4FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Add Task Button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        _showAddTaskDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Task',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Week Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayItem('Mon', 15, false),
                    _buildDayItem('Tue', 16, true),
                    _buildDayItem('Wed', 17, false),
                    _buildDayItem('Thu', 18, false),
                    _buildDayItem('Fri', 19, false),
                    _buildDayItem('Sat', 20, false),
                    _buildDayItem('Sun', 21, false),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Scrollable Task List Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: tasks[index],
                  onToggle: () {
                    setState(() {
                      tasks[index]['completed'] = !tasks[index]['completed'];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation using CustomNavBar
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }

  Widget _buildStatusCard(String count, String label, Color topColor, Color bottomColor) {
    return Container(
      height: 120,
      constraints: const BoxConstraints(
        minWidth: 100,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrow icon di pojok kanan atas
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ],
            ),
            const Spacer(),
            // Number
            Text(
              count,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(String day, int date, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = date;
        });
      },
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date.toString(),
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add task logic here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}