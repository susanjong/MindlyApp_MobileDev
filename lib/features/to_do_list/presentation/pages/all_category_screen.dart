import 'package:flutter/material.dart';
import '../widgets/task_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'folder_screen.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({super.key});

  @override
  State<AllCategoryScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<AllCategoryScreen> {
  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)], // Hijau
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)], // Biru
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)], // Pink
  ];

  late List<Map<String, dynamic>> categories;
  late List<Map<String, dynamic>> uncategorizedTasks;

  @override
  void initState() {
    super.initState();
    categories = [
      {
        'name': 'PKM 2025',
        'gradientIndex': 0,
        'taskCount': 2,
        'completedCount': 0,
        'tasks': [
          {
            'time': '4:50 PM',
            'title': 'Diskusi project',
            'completed': false,
          },
          {
            'time': '4:50 PM',
            'title': 'Meeting persiapan',
            'completed': false,
          },
        ],
      },
      {
        'name': 'semester 5',
        'gradientIndex': 1,
        'taskCount': 3,
        'completedCount': 1,
        'tasks': [
          {
            'time': '2:00 PM',
            'title': 'Belajar Flutter',
            'completed': true,
          },
          {
            'time': '3:30 PM',
            'title': 'Tugas Pemrograman',
            'completed': false,
          },
          {
            'time': '5:00 PM',
            'title': 'Review materi',
            'completed': false,
          },
        ],
      },
      {
        'name': 'Internship',
        'gradientIndex': 2,
        'taskCount': 2,
        'completedCount': 0,
        'tasks': [
          {
            'time': '9:00 AM',
            'title': 'Desain mockup',
            'completed': false,
          },
          {
            'time': '11:00 AM',
            'title': 'Presentasi progress',
            'completed': false,
          },
        ],
      },
    ];

    uncategorizedTasks = [
      {
        'time': '9:50 PM',
        'title': 'Projek Pemmob',
        'date': '01',
        'month': 'NOV',
        'completed': false,
      },
      {
        'time': '4:50 PM',
        'title': 'Diskusi project',
        'completed': false,
      },
      {
        'time': '4:50 PM',
        'title': 'Beli sayur',
        'completed': true,
      },
    ];
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
        title: const Text(
          'All Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    categories[index]['name'],
                    categories[index]['taskCount'],
                    categories[index]['completedCount'],
                    categories[index]['gradientIndex'],
                    categories[index]['tasks'] ?? [],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uncategorized Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uncategorizedTasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: uncategorizedTasks[index],
                  onToggle: () {
                    setState(() {
                      bool current = uncategorizedTasks[index]['completed'] ?? false;
                      uncategorizedTasks[index]['completed'] = !current;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 8),
        child: FloatingActionButton.extended(
          onPressed: _showAddCategoryDialog,
          backgroundColor: const Color(0xFFD732A8),
          icon: const Icon(Icons.add, color: Colors.white, size: 22),
          label: const Text(
            'Add new category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryCard(
      String name,
      int taskCount,
      int completedCount,
      int gradientIndex,
      List<Map<String, dynamic>> tasks,
      ) {
    final gradient = availableGradients[gradientIndex % availableGradients.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderScreen(
              folderName: name,
              gradientIndex: gradientIndex,
              gradients: availableGradients,
              folderTasks: tasks,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount Completed',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$taskCount Tasks',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.more_horiz,
                  size: 24,
                  color: Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const _IOSAddCategoryDialogContent();
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          categories.add({
            'name': result['name'],
            'gradientIndex': result['gradientIndex'],
            'taskCount': 0,
            'completedCount': 0,
            'tasks': [],
          });
        });
      }
    });
  }
}

class _IOSAddCategoryDialogContent extends StatefulWidget {
  const _IOSAddCategoryDialogContent({super.key});

  @override
  State<_IOSAddCategoryDialogContent> createState() =>
      _IOSAddCategoryDialogContentState();
}

class _IOSAddCategoryDialogContentState
    extends State<_IOSAddCategoryDialogContent> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedGradientIndex = 0;

  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)], // Hijau
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)], // Biru
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)], // Pink
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xA5545458);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 270,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add New Category',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.29,
                        letterSpacing: -0.41,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF0A84FF)),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Category Name',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logic pemilihan warna
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1, 2].map((index) {
                        final isSelected = _selectedGradientIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGradientIndex = index),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: availableGradients[index],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                  color: Colors.black54, width: 2)
                                  : Border.all(
                                  color: Colors.black12, width: 1),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                size: 20, color: Colors.black54)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Garis Pembatas
              Container(
                width: double.infinity,
                height: 0.5,
                color: dividerColor,
              ),

              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0A84FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: double.infinity,
                      color: dividerColor,
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            if (_nameController.text.trim().isNotEmpty) {
                              Navigator.pop(context, {
                                'name': _nameController.text.trim(),
                                'gradientIndex': _selectedGradientIndex,
                              });
                            }
                          },
                          child: Center(
                            child: Text(
                              'Add',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF0A84FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}