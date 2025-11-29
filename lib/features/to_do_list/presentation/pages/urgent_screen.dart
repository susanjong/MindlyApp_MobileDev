import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/urgent_overdue_taskItem.dart';
import 'folder_screen.dart';

class UrgentTaskScreen extends StatefulWidget {
  const UrgentTaskScreen({Key? key}) : super(key: key);

  @override
  State<UrgentTaskScreen> createState() => _UrgentTaskScreenState();
}

class _UrgentTaskScreenState extends State<UrgentTaskScreen> {
  late List<Map<String, dynamic>> allTasks;
  List<Map<String, dynamic>> urgentTasks = [];

  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)],
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)],
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)],
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _filterUrgentTasks();
  }

  void _initializeData() {
    final now = DateTime.now();
    allTasks = [
      {
        'title': 'Paper metopel',
        'category': 'PKM 2025',
        'deadline': now.add(const Duration(minutes: 30)),
        'completed': false,
      },
      {
        'title': 'Buat pesanan cookies',
        'category': 'PKM 2025',
        'deadline': now.add(const Duration(hours: 5)),
        'completed': false,
      },
      {
        'title': 'Projek Akhir',
        'category': 'Kuliah',
        'deadline': now.add(const Duration(hours: 15)),
        'completed': false,
      },
      {
        'title': 'Riset Data',
        'category': 'PKM 2025',
        'deadline': now.add(const Duration(days: 2)),
        'completed': true,
      },
    ];
  }

  void _filterUrgentTasks() {
    final now = DateTime.now();
    setState(() {
      urgentTasks = allTasks.where((task) {
        final deadline = task['deadline'] as DateTime;
        final difference = deadline.difference(now);
        final isCompleted = task['completed'];

        return !isCompleted &&
            difference.inSeconds > 0 &&
            difference.inHours <= 12;
      }).toList();
    });
  }

  String _getTimeLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} Minutes left';
    } else {
      return '${difference.inHours} Hours left';
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
            Expanded(
              child: urgentTasks.isEmpty
                  ? Center(child: Text("No urgent tasks!", style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                itemCount: urgentTasks.length,
                itemBuilder: (context, index) {
                  final task = urgentTasks[index];
                  // ✅ Integrated the shared widget
                  return UrgentOverdueTaskItem(
                    task: task,
                    themeColor: const Color(0xFFE08E00), // Orange for Urgent
                    timeText: _getTimeLeft(task['deadline']),
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