import 'package:flutter/material.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_bottom_sheet.dart';
import 'all_category_screen.dart';

class MainTodoScreen extends StatefulWidget {
  final String? username;

  const MainTodoScreen({Key? key, this.username}) : super(key: key);

  @override
  State<MainTodoScreen> createState() => _MainTodoScreenState();
}

class _MainTodoScreenState extends State<MainTodoScreen> {
  int selectedDay = 16; // Tuesday selected
  String _username = 'User';

  final List<Map<String, dynamic>> tasks = [
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
    {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _username = widget.username ?? 'User';
  }

  // PERBAIKAN: Handler navigation yang konsisten
  void _handleNavigation(int index) {
    print('📝 Todo - Navigation tapped: index=$index');

    // Routes sesuai urutan navbar: Home(0), Notes(1), Todo(2), Calendar(3)
    final routes = ['/home', '/notes', '/todo', '/calendar'];

    // Jangan navigate jika sudah di halaman yang sama (Todo = index 2)
    if (index != 2) {
      print('📝 Todo - Navigating to: ${routes[index]}');
      Navigator.pushReplacementNamed(context, routes[index]);
    } else {
      print('📝 Todo - Already on Todo page');
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
      body: Column(
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
      // PERBAIKAN: Tambahkan bottomNavigationBar seperti di NotesMainPage
      bottomNavigationBar: SafeArea(
        child: CustomNavBar(
          selectedIndex: 2, // Todo tab (index 2)
          onItemTapped: _handleNavigation,
        ),
      ),
    );
  }

  Widget _buildStatusCard(String count, String label, Color topColor, Color bottomColor) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke All Category Screen saat tap card "All"
        if (label == 'All') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllCategoryScreen(),
            ),
          );
        }
      },
      child: Container(
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
              color: Colors.black.withOpacity(0.08),
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
                    color: Colors.black.withOpacity(0.6),
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
    AddTaskBottomSheet.show(
      context,
      onSave: (taskData) {
        setState(() {
          // Tambahkan task baru ke list
          tasks.add({
            'time': '${taskData['day']} ${taskData['month']} ${taskData['year']}',
            'title': taskData['name'],
            'completed': false,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${taskData['name']}" added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}