import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_bottom_sheet.dart';

class FolderScreen extends StatefulWidget {
  final String folderName;
  final int gradientIndex;
  final List<List<Color>> gradients;
  final List<Map<String, dynamic>> folderTasks;

  const FolderScreen({
    super.key,
    required this.folderName,
    required this.gradientIndex,
    required this.gradients,
    required this.folderTasks,
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  // Panggil Service
  final TodoService _todoService = TodoService();

  bool _isSelectMode = false;
  final Set<String> _selectedTaskIds = {};

  // Event Handler

  void _toggleTaskStatus(TodoModel task) {
    _todoService.toggleTodoStatus(task.id, task.isCompleted);
  }

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
        if (_selectedTaskIds.isEmpty) _isSelectMode = false;
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _deleteSelectedTasks() {
    if (_selectedTaskIds.isEmpty) return;

    showIOSDialog(
      context: context,
      title: 'Delete Tasks',
      message: 'Are you sure you want to delete ${_selectedTaskIds.length} tasks?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        for (String id in _selectedTaskIds) {
          await _todoService.deleteTodo(id);
        }

        setState(() {
          _selectedTaskIds.clear();
          _isSelectMode = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tasks deleted successfully")),
          );
        }
      },
    );
  }

  Color get _progressColor {
    return widget.gradients[widget.gradientIndex % widget.gradients.length][0];
  }

  // Format Helper
  Map<String, dynamic> _mapModelToTaskItem(TodoModel todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description, // Pastikan deskripsi ikut terbawa
      'time': DateFormat('h:mm a').format(todo.deadline),
      'date': DateFormat('dd MMM').format(todo.deadline),
      'deadline': todo.deadline,
      'completed': todo.isCompleted,
      'category': todo.category,
    };
  }

  void _showAddTaskDialog() {
    AddTaskBottomSheet.show(
      context,
      initialCategory: widget.folderName,
      isCategoryLocked: false,
      onSave: (taskData) async {
        // Show Loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          DateTime deadline = taskData['deadline'] ?? DateTime.now();
          String category = taskData['category'] ?? widget.folderName;
          String title = taskData['title'] ?? '';
          String description = taskData['description'] ?? '';

          await _todoService.addTodo(
            title,
            category,
            deadline,
            description,
          );

          if (mounted) Navigator.pop(context);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) Navigator.pop(context);
          if (mounted) {
            print("Error saving task: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add task: $e'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
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
        actions: [
          StreamBuilder<List<TodoModel>>(
            stream: _todoService.getTodosStream(),
            builder: (context, snapshot) {
              final allTodos = snapshot.data ?? [];
              final folderTasks = allTodos.where((t) => t.category == widget.folderName).toList();
              return _buildPopupMenu(folderTasks);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TodoModel>>(
          stream: _todoService.getTodosStream(),
          builder: (context, snapshot) {
            final allTodos = snapshot.data ?? [];

            // Filter tasks untuk folder ini
            final folderTasks = allTodos
                .where((t) => t.category == widget.folderName)
                .toList();

            // Hitung Progress
            final total = folderTasks.length;
            final completed = folderTasks.where((t) => t.isCompleted).length;
            final progress = total > 0 ? (completed / total) : 0.0;
            final percentage = (progress * 100).toInt();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.folderName,
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Progress Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFE8E8E8),
                          valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Task List
                  if (folderTasks.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: folderTasks.length,
                      itemBuilder: (context, index) {
                        final task = folderTasks[index];
                        final isSelected = _selectedTaskIds.contains(task.id);

                        return _isSelectMode
                            ? _buildSelectableTaskItem(task, isSelected)
                            : TaskItem(
                          task: _mapModelToTaskItem(task),
                          onToggle: () => _toggleTaskStatus(task),
                          onDelete: () => _todoService.deleteTodo(task.id),
                        );
                      },
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No tasks yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          }
      ),

      floatingActionButton: _isSelectMode
          ? GestureDetector(
        onTap: _deleteSelectedTasks,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            const SizedBox(height: 4),
            Text(
              "Delete",
              style: GoogleFonts.poppins(
                color: const Color(0xFFB90000),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            )
          ],
        ),
      )
          : FloatingActionButton(
        backgroundColor: const Color(0xFFD732A8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: _showAddTaskDialog,
      ),
    );
  }

  Widget _buildPopupMenu(List<TodoModel> folderTasks) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Colors.black),
      offset: const Offset(0, 40),
      elevation: 2,
      color: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        if (value == 'select') {
          setState(() => _isSelectMode = true);
        } else if (value == 'complete') {
          // Filter task yang belum selesai saja
          final incompleteTasks = folderTasks.where((t) => !t.isCompleted).toList();

          if (incompleteTasks.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("All tasks are already completed!")),
            );
            return;
          }

          showIOSDialog(
            context: context,
            title: 'Complete All Tasks?',
            message: 'Are you sure you want to mark all ${incompleteTasks.length} pending tasks as completed?',
            confirmText: 'Complete All',
            confirmTextColor: Colors.blue,
            onConfirm: () async {
              // Loop update status
              for (var task in incompleteTasks) {
                await _todoService.toggleTodoStatus(task.id, false); // false di sini artinya currentStatus=false -> jadi true
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All tasks marked as completed")),
                );
              }
            },
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'select',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Task', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const Icon(Icons.list, color: Colors.black54, size: 20),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'complete',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Complete All', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const Icon(Icons.check_circle_outline, color: Colors.black54, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableTaskItem(TodoModel task, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAAAAAA) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: isSelected ? null : Border.all(color: Colors.black, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
                border: isSelected ? null : Border.all(color: Colors.black, width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: isSelected ? Colors.black87 : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(task.deadline),
                        style: TextStyle(fontSize: 12, color: isSelected ? Colors.black87 : Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}