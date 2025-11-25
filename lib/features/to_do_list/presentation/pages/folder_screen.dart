import 'package:flutter/material.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';

class FolderScreen extends StatefulWidget {
  final String folderName;
  final int gradientIndex;
  final List<List<Color>> gradients;
  final List<Map<String, dynamic>> folderTasks;

  const FolderScreen({
    Key? key,
    required this.folderName,
    required this.gradientIndex,
    required this.gradients,
    required this.folderTasks,
  }) : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late List<Map<String, dynamic>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = List.from(widget.folderTasks);
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
  }

  int get _completedCount {
    return tasks.where((task) => task['completed']).length;
  }

  int get _progressPercentage {
    if (tasks.isEmpty) return 0;
    return ((_completedCount / tasks.length) * 100).toInt();
  }

  Color get _progressColor {
    return widget.gradients[widget.gradientIndex][0];
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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      '$_progressPercentage%',
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
                    value: _progressPercentage / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Task List
            if (tasks.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      TaskItem(
                        task: tasks[index],
                        onToggle: () => _toggleTask(index),
                      ),
                    ],
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD732A8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          _showAddTaskDialog();
        },
      ),
    );
  }

  void _showAddTaskDialog() {
    AddTaskBottomSheet.show(
      context,
      onSave: (taskData) {
        setState(() {
          // Tambahkan task baru ke list
          tasks.add({
            'time': '${taskData['day']} ${taskData['month']} ${taskData['year']}',
            'title': taskData['name'],
            'completed': false,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${taskData['name']}" added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

