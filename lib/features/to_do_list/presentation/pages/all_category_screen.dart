import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ✅ Import Services & Models (Sesuaikan path jika berbeda)
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

// ✅ Import Widgets
import '../widgets/task_item.dart';
import 'folder_screen.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({super.key});

  @override
  State<AllCategoryScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<AllCategoryScreen> {
  // Services
  final TodoService _todoService = TodoService();
  final CategoryService _categoryService = CategoryService();

  // Gradients Static
  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)], // Hijau
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)], // Biru
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)], // Pink
  ];

  // Selection Mode State (Menggunakan ID Firestore)
  bool _isSelectMode = false;
  final Set<String> _selectedTaskIds = {};

  // -- Event Handlers --

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

  // ✅ LOGIC DELETE DENGAN IOS DIALOG & FIREBASE
  void _deleteSelectedTasks() {
    if (_selectedTaskIds.isEmpty) return;

    showIOSDialog(
      context: context,
      title: 'Delete Tasks',
      message: 'Are you sure you want to delete these ${_selectedTaskIds.length} tasks?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        // 1. Hapus dari Firebase
        for (String id in _selectedTaskIds) {
          await _todoService.deleteTodo(id);
        }

        // 2. Reset UI State
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
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const _IOSAddCategoryDialogContent();
      },
    );
  }

  // Format Helper
  Map<String, dynamic> _mapModelToTaskItem(TodoModel todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'time': DateFormat('h:mm a').format(todo.deadline),
      'date': DateFormat('dd MMM').format(todo.deadline),
      'deadline': todo.deadline,
      'completed': todo.isCompleted,
      'category': todo.category,
    };
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
                _selectedTaskIds.clear();
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
      body: StreamBuilder<List<TodoModel>>(
        stream: _todoService.getTodosStream(),
        builder: (context, snapshotTasks) {
          final allTasks = snapshotTasks.data ?? [];

          // Filter Uncategorized Tasks
          final uncategorizedList = allTasks
              .where((t) => t.category == 'Uncategorized' || t.category.isEmpty)
              .toList();

          return StreamBuilder<List<CategoryModel>>(
            stream: _categoryService.getCategoriesStream(),
            builder: (context, snapshotCategories) {
              final categories = snapshotCategories.data ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // --- HORIZONTAL CATEGORY LIST ---
                    SizedBox(
                      height: 110,
                      child: categories.isEmpty
                          ? const Center(child: Text("No categories"))
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          // Hitung statistik task
                          final categoryTasks = allTasks
                              .where((t) => t.category == category.name)
                              .toList();
                          final total = categoryTasks.length;
                          final completed = categoryTasks.where((t) => t.isCompleted).length;

                          return _buildCategoryCard(
                            category.name,
                            total,
                            completed,
                            category.gradientIndex,
                            categoryTasks,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // --- HEADER UNCATEGORIZED ---
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
                              if (uncategorizedList.isNotEmpty)
                                _buildPopupMenu(uncategorizedList),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- TASK LIST (VERTICAL) ---
                          if (uncategorizedList.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                "No uncategorized tasks",
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: uncategorizedList.length,
                              itemBuilder: (context, index) {
                                final task = uncategorizedList[index];
                                final isSelected = _selectedTaskIds.contains(task.id);

                                return _isSelectMode
                                    ? _buildSelectableTaskItem(task, isSelected)
                                    : TaskItem(
                                  task: _mapModelToTaskItem(task),
                                  onToggle: () => _toggleTaskStatus(task),
                                  onDelete: () => _todoService.deleteTodo(task.id),
                                );
                              },
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ✅ UI & LOGIC SESUAI PERMINTAAN ANDA
      floatingActionButton: _isSelectMode
          ? GestureDetector(
        onTap: _deleteSelectedTasks, // Logic delete firebase ada di method ini
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
          : Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 8),
        child: FloatingActionButton.extended(
          onPressed: _showAddCategoryDialog, // Logic add firebase ada di method ini
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

  // --- WIDGET BUILDERS ---

  Widget _buildPopupMenu(List<TodoModel> tasks) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFFF2F2F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
        ),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, color: Colors.black),
        offset: const Offset(0, 40),
        elevation: 2,
        onSelected: (value) async {
          if (value == 'select') {
            setState(() => _isSelectMode = true);
          } else if (value == 'complete') {
            for (var t in tasks) {
              if (!t.isCompleted) {
                await _todoService.toggleTodoStatus(t.id, false);
              }
            }
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
      ),
    );
  }

  Widget _buildCategoryCard(String name, int taskCount, int completedCount, int gradientIndex, List<TodoModel> tasks) {
    final gradient = availableGradients[gradientIndex % availableGradients.length];
    final List<Map<String, dynamic>> folderTasksMap = tasks.map((t) => _mapModelToTaskItem(t)).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderScreen(
              folderName: name,
              gradientIndex: gradientIndex,
              gradients: availableGradients,
              folderTasks: folderTasksMap,
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
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
                    style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500),
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
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.more_horiz, size: 24, color: Colors.black87),
              ],
            ),
          ],
        ),
      ),
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

void showIOSDialog({required BuildContext context, required String title, required String message, String cancelText = 'Cancel', String confirmText = 'Confirm', VoidCallback? onCancel, required VoidCallback onConfirm, Color? confirmTextColor}) {
  showDialog(context: context, barrierDismissible: true, builder: (_) => IOSDialog(title: title, message: message, cancelText: cancelText, confirmText: confirmText, onCancel: onCancel, onConfirm: onConfirm, confirmTextColor: confirmTextColor));
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
  // Panggil service di sini untuk menyimpan data
  final CategoryService _categoryService = CategoryService();

  int _selectedGradientIndex = 0;

  // Warna sesuai gambar (Hijau, Biru, Pink)
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
    // Warna garis pembatas
    const dividerColor = Color(0xFFE0E0E0);
    // Warna biru khas iOS/Gambar
    const blueColor = Color(0xFF007AFF);

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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- TITLE ---
                    Text(
                      'Add New Category',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: _nameController,
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Category Name',
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey),
                          contentPadding: const EdgeInsets.only(bottom: 12, left: 5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: blueColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: blueColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(availableGradients.length, (index) {
                        final isSelected = _selectedGradientIndex == index;
                        // Ambil warna utama dari gradient untuk ditampilkan
                        final mainColor = availableGradients[index][0];

                        return GestureDetector(
                          onTap: () => setState(() => _selectedGradientIndex = index),
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: availableGradients[index],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 18, color: Colors.black54)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // --- HORIZONTAL DIVIDER ---
              Container(
                width: double.infinity,
                height: 1,
                color: dividerColor,
              ),

              // --- BUTTONS ROW ---
              SizedBox(
                height: 45,
                child: Row(
                  children: [
                    // CANCEL BUTTON
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: blueColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // VERTICAL DIVIDER
                    Container(
                      width: 1,
                      height: double.infinity,
                      color: dividerColor,
                    ),

                    // ADD BUTTON (Dengan Logic Firebase)
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final name = _nameController.text.trim();

                          if (name.isNotEmpty) {
                            // ✅ LOGIC FIREBASE DISINI
                            // Langsung simpan ke database
                            await _categoryService.addCategory(
                              name,
                              _selectedGradientIndex,
                            );

                            // Tutup dialog
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: Center(
                          child: Text(
                            'Add',
                            style: GoogleFonts.poppins(
                              color: blueColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600, // Bold sesuai gambar
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