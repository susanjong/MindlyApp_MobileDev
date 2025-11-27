import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// ✅ Import FolderScreen
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
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)], // Hijau
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)], // Biru
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)], // Pink
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
                  ? Center(
                  child: Text("No urgent tasks!",
                      style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.builder(
                itemCount: urgentTasks.length,
                itemBuilder: (context, index) {
                  return _buildUrgentTaskItem(urgentTasks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentTaskItem(Map<String, dynamic> task) {
    final DateTime deadline = task['deadline'];
    final String day = DateFormat('dd').format(deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFE08E00),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Today',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeLeft(deadline),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF535353),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 11,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task['category'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF535353),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {
              _navigateToFolder(task['category']);
            },
          ),
        ],
      ),
    );
  }
}