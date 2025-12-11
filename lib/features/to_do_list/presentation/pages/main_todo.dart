import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_bottom_sheet.dart';
import 'all_category_screen.dart';
import 'overdue_screen.dart';
import 'package:notesapp/features/to_do_list/presentation/pages/urgent_screen.dart';

class MainTodoScreen extends StatefulWidget {
  final String? username;
  const MainTodoScreen({super.key, this.username});

  @override
  State<MainTodoScreen> createState() => _MainTodoScreenState();
}

class _MainTodoScreenState extends State<MainTodoScreen> {
  int selectedDay = DateTime.now().day;
  String _username = 'User';

  final TodoService _todoService = TodoService();

  @override
  void initState() {
    super.initState();
    _username = widget.username ?? 'User';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final displayName = AuthService.getUserDisplayName();
    if (mounted) setState(() => _username = displayName ?? 'User');
  }

  void _handleNavigation(int index) {
    final routes = ['/home', '/notes', '/todo', '/calendar'];
    if (index != 2) Navigator.pushReplacementNamed(context, routes[index]);
  }

  // ubah Model ke Map agar cocok dengan TaskItem widget
  Map<String, dynamic> _mapModelToTaskItem(TodoModel todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'time': DateFormat('h:mm a').format(todo.deadline),
      'date': DateFormat('dd MMM').format(todo.deadline),
      'deadline': todo.deadline,
      'completed': todo.isCompleted,
      'category': todo.category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopAppBar(
        onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        onNotificationTap: () {},
      ),
      // Gunakan StreamBuilder untuk Realtime Update
      body: StreamBuilder<List<TodoModel>>(
        stream: _todoService.getTodosStream(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTodos = snapshot.data ?? [];

          //  2. Logic Hitung Statistik (Urgent, Overdue, All)
          final now = DateTime.now();
          final incompleteTodos = allTodos.where((t) => !t.isCompleted).toList();

          // Hitung Overdue
          final overdueCount = incompleteTodos.where((t) => t.deadline.isBefore(now)).length;

          // Hitung Urgent (<= 12 jam)
          final urgentCount = incompleteTodos.where((t) {
            final diff = t.deadline.difference(now);
            return diff.inHours <= 12 && !diff.isNegative;
          }).length;

          final allCount = incompleteTodos.length;

          // 3. Filter List untuk ditampilkan di bawah (Task hari ini/semua yang belum selesai)
          final displayList = incompleteTodos;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingStream(),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        children: [
                          const TextSpan(text: 'You have '),
                          TextSpan(
                            text: '$allCount things to do', // ✅ Data Realtime
                            style: const TextStyle(color: Color(0xFFFFB74D)),
                          ),
                          const TextSpan(text: '\nremaining'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status Cards (Data Realtime)
                    SizedBox(
                      height: 130,
                      child: Row(
                        children: [
                          Expanded(child: _buildStatusCard('$allCount', 'All', const Color(0xFF318F61), const Color(0xFFFEF4FC))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatusCard('$urgentCount', 'Urgent', const Color(0xFFF4BF2A), const Color(0xFFF6FAFD))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatusCard('$overdueCount', 'Overdue', const Color(0xFFE5526E), const Color(0xFFF8F4FF))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add Task Button
                    _buildAddTaskButton(),
                    const SizedBox(height: 20),

                    // Week Days (Static Visual Only)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final date = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
                        return _buildDayItem(DateFormat('E').format(date), date.day, date.day == selectedDay);
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Task List Realtime (Firebase)
              Expanded(
                child: displayList.isEmpty
                    ? const Center(child: Text("No tasks yet!"))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final todo = displayList[index];
                    return TaskItem(
                      // Konversi Model ke Map agar TaskItem widget tidak error
                      task: _mapModelToTaskItem(todo),

                      // Logic Toggle Status ke Firebase
                      onToggle: () => _todoService.toggleTodoStatus(todo.id, todo.isCompleted),

                      // Logic Delete ke Firebase
                      onDelete: () => _todoService.deleteTodo(todo.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: CustomNavBar(selectedIndex: 2, onItemTapped: _handleNavigation),
      ),
    );
  }

  // --- Widget Helpers ---
  Widget _buildGreetingStream() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AuthService.getUserDataStream(),
      builder: (context, snapshot) {
        String displayName = _username;
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data();
          if (userData != null && userData['displayName'] != null) {
            displayName = userData['displayName'];
          }
        }
        return Text(
          'Hello, $displayName!',
          style: const TextStyle(fontSize: 17, color: Colors.black87),
        );
      },
    );
  }

  Widget _buildAddTaskButton() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFFD8E4), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.black, width: 1.5)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _showAddTaskDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Task', style: TextStyle(fontSize: 16, color: Colors.black87)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Logic Simpan ke Firebase saat Add Task
  void _showAddTaskDialog() {
    AddTaskBottomSheet.show(
      context,
      onSave: (taskData) async {
        final now = DateTime.now();
        // Default deadline: Hari ini jam 23:59 (atau sesuaikan dengan inputan user jika ada)
        // Jika bottom sheet memberikan data tanggal, parse di sini.
        DateTime deadline = DateTime(now.year, now.month, now.day, 23, 59);

        // Panggil Service Firebase
        await _todoService.addTodo(
            taskData['name'],
            'Uncategorized', // Default category
            deadline
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task added successfully!'), backgroundColor: Colors.green),
          );
        }
      },
    );
  }

  Widget _buildStatusCard(String count, String label, Color topColor, Color bottomColor) {
    return GestureDetector(
      onTap: () {
        if (label == 'All') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AllCategoryScreen()),
          );
        } else if (label == 'Urgent') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UrgentTaskScreen()),
          );
        } else if (label == 'Overdue') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OverdueTaskScreen()),
          );
        }
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [topColor, bottomColor]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(alignment: Alignment.topRight, child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black54)),
              const Spacer(),
              Text(count, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(String day, int date, bool isSelected) {
    return Column(children: [Text(day, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey)), Text("$date", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.grey))]);
  }
}