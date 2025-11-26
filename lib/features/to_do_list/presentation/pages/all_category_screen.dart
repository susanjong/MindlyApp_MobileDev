import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../widgets/task_item.dart';
import 'folder_screen.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({Key? key}) : super(key: key);

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

  // State untuk mode seleksi
  bool _isSelectMode = false;

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
          {'time': '4:50 PM', 'title': 'Diskusi project', 'completed': false},
          {'time': '4:50 PM', 'title': 'Meeting persiapan', 'completed': false},
        ],
      },
      {
        'name': 'semester 5',
        'gradientIndex': 1,
        'taskCount': 3,
        'completedCount': 1,
        'tasks': [
          {'time': '2:00 PM', 'title': 'Belajar Flutter', 'completed': true},
          {'time': '3:30 PM', 'title': 'Tugas Pemrograman', 'completed': false},
          {'time': '5:00 PM', 'title': 'Review materi', 'completed': false},
        ],
      },
      {
        'name': 'Internship',
        'gradientIndex': 2,
        'taskCount': 2,
        'completedCount': 0,
        'tasks': [
          {'time': '9:00 AM', 'title': 'Desain mockup', 'completed': false},
          {'time': '11:00 AM', 'title': 'Presentasi progress', 'completed': false},
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
        'selected': false,
      },
      {
        'time': '4:50 PM',
        'title': 'Diskusi project',
        'completed': false,
        'selected': false,
      },
      {
        'time': '4:50 PM',
        'title': 'Diskusi project',
        'completed': false,
        'selected': false,
      },
      {
        'time': '4:50 PM',
        'title': 'Diskusi project',
        'completed': false,
        'selected': false,
      },
      {
        'time': '4:50 PM',
        'title': 'beli sayur',
        'completed': false,
        'selected': true,
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
          onPressed: () {
            if (_isSelectMode) {
              setState(() {
                _isSelectMode = false;
                for (var task in uncategorizedTasks) {
                  task['selected'] = false;
                }
              });
            } else {
              Navigator.pop(context);
            }
          },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // HEADER Uncategorized + POPUP MENU
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

                      Theme(
                        data: Theme.of(context).copyWith(
                          popupMenuTheme: PopupMenuThemeData(
                            color: const Color(0xFFF2F2F2), // Background abu-abu
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, color: Colors.black),
                          offset: const Offset(0, 40), // Menggeser menu ke bawah icon
                          elevation: 2,
                          onSelected: (value) {
                            if (value == 'select') {
                              setState(() {
                                _isSelectMode = true;
                              });
                            } else if (value == 'complete') {
                              setState(() {
                                for (var task in uncategorizedTasks) {
                                  task['completed'] = true;
                                }
                              });
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'select',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select Task',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                  ),
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
                                  Text(
                                    'Complete All',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                  ),
                                  const Icon(Icons.check_circle_outline, color: Colors.black54, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Task List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: uncategorizedTasks.length,
                    itemBuilder: (context, index) {
                      return _isSelectMode
                          ? _buildSelectableTaskItem(index)
                          : TaskItem(
                        task: uncategorizedTasks[index],
                        onToggle: () {
                          setState(() {
                            bool current =
                                uncategorizedTasks[index]['completed'] ?? false;
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
          ],
        ),
      ),

      floatingActionButton: _isSelectMode
          ? GestureDetector(
        onTap: () {
          final selectedCount = uncategorizedTasks.where((i) => i['selected'] == true).length;
          if (selectedCount == 0) return;

          showIOSDialog(
            context: context,
            title: 'Delete Tasks',
            message: 'Are you sure you want to delete these $selectedCount tasks?',
            confirmText: 'Delete',
            confirmTextColor: const Color(0xFFFF453A),
            onConfirm: () {
              // Logika Hapus
              setState(() {
                uncategorizedTasks.removeWhere((item) => item['selected'] == true);
                _isSelectMode = false;
              });
            },
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            const SizedBox(height: 4),
            Text("Delete",
                style: GoogleFonts.poppins(
                    color: const Color(0xFFB90000),
                    fontWeight: FontWeight.w600,
                    fontSize: 12))
          ],
        ),
      )
          : Padding(
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
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
                    color: Colors.white.withOpacity(0.4),
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

  // ... Widget _buildSelectableTaskItem (Sama) ...
  Widget _buildSelectableTaskItem(int index) {
    final isSelected = uncategorizedTasks[index]['selected'] == true;

    return GestureDetector(
      onTap: () {
        setState(() {
          uncategorizedTasks[index]['selected'] = !isSelected;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAAAAAA) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: isSelected
              ? null
              : Border.all(color: Colors.black, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.black, width: 1.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isSelected ? Colors.black87 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        uncategorizedTasks[index]['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    uncategorizedTasks[index]['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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

// ... Widget _IOSAddCategoryDialogContent (Sama) ...
class _IOSAddCategoryDialogContent extends StatefulWidget {
  const _IOSAddCategoryDialogContent({Key? key}) : super(key: key);

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

// ==========================================
// IOS DIALOG & HELPER (Copy Paste ini)
// ==========================================

class IOSDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final Color? confirmTextColor;

  const IOSDialog({
    Key? key,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.onCancel,
    required this.onConfirm,
    this.confirmTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 270,
        decoration: ShapeDecoration(
          color: const Color(0xBFF2F2F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: Color(0xA5545458)),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onCancel?.call();
                      },
                      child: Center(
                        child: Text(
                          cancelText,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0A84FF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 0.5, thickness: 0.5, color: Color(0xA5545458)),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // Tutup dialog
                        onConfirm(); // Jalankan aksi
                      },
                      child: Center(
                        child: Text(
                          confirmText,
                          style: GoogleFonts.poppins(
                            color: confirmTextColor ?? const Color(0xFFFF453A),
                            fontSize: 14,
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
    );
  }
}
