import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../widgets/urgent_overdue_taskItem.dart';
import 'folder_screen.dart';

class OverdueTaskScreen extends StatefulWidget {
  const OverdueTaskScreen({super.key});

  @override
  State<OverdueTaskScreen> createState() => _OverdueTaskScreenState();
}

class _OverdueTaskScreenState extends State<OverdueTaskScreen> {

  final TodoService _todoService = TodoService();

  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)],
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)],
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)],
  ];

  String _getOverdueTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = now.difference(deadline); // Selisih dari sekarang ke belakang

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      if (hours > 0) {
        return 'overdue by $days days $hours hours';
      }
      return 'overdue by $days days';
    } else if (difference.inHours > 0) {
      return 'overdue by ${difference.inHours} hours';
    } else {
      return 'overdue by ${difference.inMinutes} minutes';
    }
  }

  // Helper: Navigasi ke Folder
  void _navigateToFolder(String categoryName, List<TodoModel> allTodos) {
    // Filter task sesuai kategori
    final folderTasksModel = allTodos.where((t) => t.category == categoryName).toList();

    // Convert Model ke Map untuk FolderScreen
    final folderTasksMap = folderTasksModel.map((t) => {
      'id': t.id,
      'title': t.title,
      'time': DateFormat('h:mm a').format(t.deadline),
      'date': DateFormat('dd MMM').format(t.deadline),
      'deadline': t.deadline,
      'completed': t.isCompleted,
      'category': t.category,
    }).toList();

    int gradientIndex = categoryName.length % availableGradients.length;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderScreen(
          folderName: categoryName,
          gradientIndex: gradientIndex,
          gradients: availableGradients,
          folderTasks: folderTasksMap,
        ),
      ),
    );
  }

  // Helper: Convert TodoModel -> Map untuk widget item
  Map<String, dynamic> _mapModelToItem(TodoModel t) {
    return {
      'id': t.id,
      'title': t.title,
      'category': t.category,
      'deadline': t.deadline,
      'completed': t.isCompleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TodoModel>>(
          stream: _todoService.getTodosStream(),
          builder: (context, snapshot) {
            // Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allTodos = snapshot.data ?? [];
            final now = DateTime.now();

            final overdueTasks = allTodos.where((task) {
              // isBefore(now) berarti waktu deadline sudah berlalu
              return !task.isCompleted && task.deadline.isBefore(now);
            }).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: primaryRed,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Overdue',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Subtitle Count
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF535353),
                      ),
                      children: [
                        const TextSpan(text: 'You have '),
                        TextSpan(
                          text: '${overdueTasks.length}', // Hitung realtime
                          style: const TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' overdue task'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // List Overdue Tasks
                  Expanded(
                    child: overdueTasks.isEmpty
                        ? Center(
                      child: Text(
                        "No overdue tasks! Great job.",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: overdueTasks.length,
                      itemBuilder: (context, index) {
                        final taskModel = overdueTasks[index];
                        final taskMap = _mapModelToItem(taskModel);

                        return UrgentOverdueTaskItem(
                          task: taskMap,
                          themeColor: primaryRed, // Warna Merah
                          timeText: _getOverdueTime(taskModel.deadline),
                          onTapArrow: () => _navigateToFolder(taskModel.category, allTodos),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}