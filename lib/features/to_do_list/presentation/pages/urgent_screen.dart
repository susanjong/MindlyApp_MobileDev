import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../widgets/urgent_overdue_taskItem.dart';
import 'folder_screen.dart';

class UrgentTaskScreen extends StatefulWidget {
  const UrgentTaskScreen({Key? key}) : super(key: key);

  @override
  State<UrgentTaskScreen> createState() => _UrgentTaskScreenState();
}

class _UrgentTaskScreenState extends State<UrgentTaskScreen> {
  final TodoService _todoService = TodoService();

  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)], // Hijau
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)], // Biru
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)], // Pink
  ];

  String _getTimeLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} Minutes left';
    } else {
      return '${difference.inHours} Hours left';
    }
  }

  void _navigateToFolder(String categoryName, List<TodoModel> allTodos) {
    // Filter task sesuai kategori untuk dikirim ke FolderScreen
    final folderTasksModel = allTodos.where((t) => t.category == categoryName).toList();

    // Convert Model ke Map
    final folderTasksMap = folderTasksModel.map((t) => {
      'id': t.id,
      'title': t.title,
      'time': DateFormat('h:mm a').format(t.deadline),
      'date': DateFormat('dd MMM').format(t.deadline),
      'deadline': t.deadline,
      'completed': t.isCompleted,
      'category': t.category,
    }).toList();

    // Tentukan warna (simulasi index)
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

      body: StreamBuilder<List<TodoModel>>(
        stream: _todoService.getTodosStream(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTodos = snapshot.data ?? [];
          final now = DateTime.now();

          final urgentTasks = allTodos.where((task) {
            final diff = task.deadline.difference(now);
            return !task.isCompleted &&
                !diff.isNegative && // Tidak boleh lewat deadline (overdue)
                diff.inHours <= 12; // Kurang dari atau sama dengan 12 jam
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
                      Icons.notifications_active_outlined,
                      color: Color(0xFFE08E00),
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Urgent',
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
                        text: '${urgentTasks.length}',
                        style: const TextStyle(
                          color: Color(0xFFE08E00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' urgent task'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // List Urgent Tasks
                Expanded(
                  child: urgentTasks.isEmpty
                      ? Center(
                    child: Text(
                      "No urgent tasks!",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: urgentTasks.length,
                    itemBuilder: (context, index) {
                      final taskModel = urgentTasks[index];

                      // Konversi Model ke Map agar widget shared bisa baca
                      final taskMap = _mapModelToItem(taskModel);

                      return UrgentOverdueTaskItem(
                        task: taskMap,
                        themeColor: const Color(0xFFE08E00), // Orange
                        timeText: _getTimeLeft(taskModel.deadline),
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
    );
  }
}