import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/urgent_overdue_taskItem.dart';
import 'folder_screen.dart';

class OverdueTaskScreen extends StatefulWidget {
  const OverdueTaskScreen({Key? key}) : super(key: key);

  @override
  State<OverdueTaskScreen> createState() => _OverdueTaskScreenState();
}

class _OverdueTaskScreenState extends State<OverdueTaskScreen> {
  late List<Map<String, dynamic>> allTasks;
  List<Map<String, dynamic>> overdueTasks = [];

  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)],
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)],
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)],
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _filterOverdueTasks();
  }

  void _initializeData() {
    final now = DateTime.now();
    allTasks = [
      {
        'title': 'Paper metopel',
        'category': 'PKM 2025',
        'deadline': now.subtract(const Duration(days: 20, hours: 20)),
        'completed': false,
      },
      {
        'title': 'Buat pesanan cookies',
        'category': 'PKM 2025',
        'deadline': now.subtract(const Duration(hours: 2)),
        'completed': false,
      },
      {
        'title': 'Tugas Panjang Sekali Namanya',
        'category': 'Kategori Sangat Panjang Juga',
        'deadline': now.subtract(const Duration(days: 5, hours: 10)),
        'completed': false,
      },
    ];
  }

  void _filterOverdueTasks() {
    final now = DateTime.now();
    setState(() {
      overdueTasks = allTasks.where((task) {
        final deadline = task['deadline'] as DateTime;
        final isCompleted = task['completed'];
        return !isCompleted && deadline.isBefore(now);
      }).toList();
    });
  }

  String _getOverdueTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = now.difference(deadline);

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

  void _navigateToFolder(String categoryName) {
    final folderTasks = allTasks.where((t) => t['category'] == categoryName).toList();
    int gradientIndex = categoryName.length % availableGradients.length;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderScreen(
          folderName: categoryName,
          folderTasks: folderTasks,
          gradientIndex: gradientIndex,
          gradients: availableGradients,
        ),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF535353),
                ),
                children: [
                  const TextSpan(text: 'You have '),
                  TextSpan(
                    text: '${overdueTasks.length}',
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
            Expanded(
              child: overdueTasks.isEmpty
                  ? Center(child: Text("No overdue tasks!", style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                itemCount: overdueTasks.length,
                itemBuilder: (context, index) {
                  final task = overdueTasks[index];
                  // ✅ Integrated the shared widget
                  return UrgentOverdueTaskItem(
                    task: task,
                    themeColor: primaryRed, // Red for Overdue
                    timeText: _getOverdueTime(task['deadline']),
                    onTapArrow: () => _navigateToFolder(task['category']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}