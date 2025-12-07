import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/taskDetailScreen.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggle,
    this.onDelete,
  }) : super(key: key);

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onDelete: onDelete ?? () {},
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showIOSDialog(
      context: context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${task['title']}"?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () {
        if (onDelete != null) onDelete!();
      },
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showIOSDialog(
      context: context,
      title: 'Delete completed task',
      message: 'Do you want to delete this completed task?',
      cancelText: 'Keep',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onCancel: () {
        if (task['completed'] != true) {
          onToggle();
        }
      },
      onConfirm: () {
        if (onDelete != null) onDelete!();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Data Deadline
    final DateTime? deadline = task['deadline'] as DateTime?;

    // 2. Status Overdue/Urgent
    bool isOverdue = false;
    bool isUrgent = false;

    if (deadline != null && task['completed'] != true) {
      final now = DateTime.now();
      final difference = deadline.difference(now);
      if (difference.isNegative) {
        isOverdue = true;
      } else if (difference.inHours <= 12) {
        isUrgent = true;
      }
    }

    // 3. Format Tanggal
    String dateDay = "--";
    String dateMonth = "--";
    if (deadline != null) {
      dateDay = DateFormat('dd').format(deadline);
      dateMonth = DateFormat('MMM').format(deadline);
    }

    String displayTime = task['time'] ?? '';
    if (displayTime.isEmpty && deadline != null) {
      displayTime = DateFormat('h:mm a').format(deadline);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task['id'] ?? task['title']),

        // ✅ ACTION PANE SESUAI GAMBAR
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.6, // Lebar area geser
          children: [
            const SizedBox(width: 8), // Spasi antara item dan tombol

            // Tombol EDIT (Kuning)
            CustomSlidableAction(
              onPressed: (context) => _navigateToDetail(context),
              backgroundColor: const Color(0xFFFFA726),
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(50), // Bulat Penuh
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit, size: 20),
                  SizedBox(height: 4),
                  Text("Edit", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(width: 8), // Spasi antar tombol

            // Tombol DELETE (Merah)
            CustomSlidableAction(
              onPressed: (context) => _showDeleteDialog(context),
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(50), // Bulat Penuh
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete, size: 20),
                  SizedBox(height: 4),
                  Text("Delete", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),

        // TAMPILAN ITEM UTAMA
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(
                  task: task,
                  onDelete: onDelete ?? () {},
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.black, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    if (task['completed'] != true) {
                      _showCompletionDialog(context);
                    } else {
                      onToggle();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5784EB), width: 2),
                      color: task['completed'] == true
                          ? const Color(0xFF5784EB)
                          : Colors.transparent,
                    ),
                    child: task['completed'] == true
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Info Task
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            displayTime,
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            _buildBadge('Overdue', const Color(0xFFD4183D)),
                          ] else if (isUrgent) ...[
                            const SizedBox(width: 8),
                            _buildBadge('Urgent', const Color(0xFFF9C474)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task['title'] ?? 'No Title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          decoration: task['completed'] == true
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Date Circle
                Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5784EB),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateMonth,
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        dateDay,
                        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold, height: 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}