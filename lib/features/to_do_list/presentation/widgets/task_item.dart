import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/taskDetailScreen.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

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

  void _showCompletionDialog(BuildContext context) {
    showIOSDialog(
      context: context,
      title: 'Delete completed task',
      message: 'Do you want to delete this completed task?',
      cancelText: 'Keep', // Tombol kiri -> Keep
      confirmText: 'Delete', // Tombol kanan -> Delete (Merah)
      confirmTextColor: const Color(0xFFFF453A),

      // Action KEEP (Cancel)
      onCancel: () {
        // Task tetap di list, tapi tandai selesai
        // Kita panggil onToggle di sini agar status checkbox berubah jadi checked
        if (task['completed'] != true) {
          onToggle();
        }
      },

      // Action DELETE (Confirm)
      onConfirm: () {
        // Hapus task dari list
        if (onDelete != null) onDelete!();

        // Optional: Tampilkan snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task deleted")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data deadline
    final DateTime? deadline = task['deadline'] as DateTime?;

    // 2. Tentukan Status (Overdue / Urgent)
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

    // 3. Format Tanggal untuk Lingkaran Biru (Kanan)
    String dateDay = "--";
    String dateMonth = "--";

    if (deadline != null) {
      dateDay = DateFormat('dd').format(deadline);
      dateMonth = DateFormat('MMM').format(deadline);
    }

    // 4. Logic Tampilan Jam
    String displayTime = task['time'] ?? '';
    if (displayTime.isEmpty && deadline != null) {
      displayTime = DateFormat('h:mm a').format(deadline);
    }

    return GestureDetector(
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // --- CHECKBOX ---
            GestureDetector(
              onTap: () {
                // Jika task BELUM selesai -> Munculkan Dialog Tanya
                if (task['completed'] != true) {
                  _showCompletionDialog(context);
                } else {
                  // Jika sudah selesai -> Balikin jadi belum selesai (Toggle biasa)
                  onToggle();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF5784EB),
                      width: 2
                  ),
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

            // --- CONTENT TENGAH ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
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

            // --- DATE CIRCLE (KANAN) ---
            // Menampilkan Tanggal Deadline yang sebenarnya
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
                    dateMonth, // Sekarang menampilkan "Nov", "Dec", dll (Bukan "Today")
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dateDay,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
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