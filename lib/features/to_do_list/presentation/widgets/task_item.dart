import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/taskDetailScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    final DateTime? deadline = task['deadline'] as DateTime?;

    // 2. Tentukan Status (Overdue / Urgent)
    bool isOverdue = false;
    bool isUrgent = false;

    if (deadline != null && !task['completed']) {
      final now = DateTime.now();
      final difference = deadline.difference(now);

      if (difference.isNegative) {
        isOverdue = true; // Lewat deadline
      } else if (difference.inHours <= 12) {
        isUrgent = true; // Kurang dari 12 jam
      }
    }

    String dateDay = "01";
    String dateMonth = "Today";

    if (deadline != null) {
      dateDay = DateFormat('dd').format(deadline);
      // Jika tanggal hari ini, tampilkan "Today", jika tidak tampilkan Bulan (misal: "Nov")
      if (DateUtils.isSameDay(deadline, DateTime.now())) {
        dateMonth = "Today";
      } else {
        dateMonth = DateFormat('MMM').format(deadline);
      }
    }

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding disesuaikan
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
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
                        task['time'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // --- LOGIC BADGE (URGENT / OVERDUE) ---
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
                    task['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
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

            // --- 3. DATE CIRCLE (KANAN) ---
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
                    dateMonth, // "Today" atau "Nov"
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dateDay, // "01"
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

  // Helper widget untuk Badge Kecil (Urgent/Overdue)
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}