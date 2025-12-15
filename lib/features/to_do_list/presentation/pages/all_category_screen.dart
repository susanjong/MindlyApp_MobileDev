import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ✅ Import Services & Models
import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

// ✅ Import Widgets (Termasuk Alert Dialog dari Core)
import '../../../../core/widgets/dialog/alert_dialog.dart';
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

  // Selection Mode State
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

  // ✅ LOGIC DELETE SELECTED TASKS
  void _deleteSelectedTasks() {
    if (_selectedTaskIds.isEmpty) return;

    showIOSDialog(
      context: context,
      title: 'Delete Tasks',
      message: 'Are you sure you want to delete these ${_selectedTaskIds.length} tasks?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        for (String id in _selectedTaskIds) {
          await _todoService.deleteTodo(id);
        }

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

  // ✅ LOGIC DELETE CATEGORY
  void _deleteCategory(String categoryId, String categoryName) {
    showIOSDialog(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "$categoryName"? All tasks inside will be moved to Uncategorized.',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        await _categoryService.deleteCategory(categoryId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Category deleted successfully")),
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
      'description': todo.description,
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

          uncategorizedList.sort((a, b) => b.deadline.compareTo(a.deadline));

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
                    // --- HORIZONTAL CATEGORY LIST ---
                    SizedBox(
                      // 1. TINGKATKAN TINGGI AGAR SHADOW TIDAK TERPOTONG
                      height: 130, // Sebelumnya 110, tambah jadi 130 atau lebih
                      child: categories.isEmpty
                          ? const Center(child: Text("No categories"))
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        // 2. TAMBAHKAN PADDING VERTIKAL
                        // Agar ada ruang untuk shadow di atas dan bawah
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            category,
                            total,
                            completed,
                            category.gradientIndex,
                            categoryTasks,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

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

      // FAB Logic
      floatingActionButton: _isSelectMode
          ? GestureDetector(
        onTap: _deleteSelectedTasks,
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
          onPressed: _showAddCategoryDialog,
          backgroundColor: const Color(0xFFD732A8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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

  Widget _buildCategoryPopupMenu(CategoryModel category) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
        ),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz, size: 24, color: Colors.black87),

        // Hapus padding default
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),

        offset: const Offset(0, 30),
        elevation: 2,
        onSelected: (value) {
          if (value == 'delete') {
            _deleteCategory(category.id, category.name);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'delete',
            height: 35,
            child: Row(
              children: [
                const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                    'Delete',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ WIDGET CATEGORY CARD (UPDATED WITH TRANSFORM)
  Widget _buildCategoryCard(CategoryModel category, int taskCount, int completedCount, int gradientIndex, List<TodoModel> tasks) {
    final gradient = availableGradients[gradientIndex % availableGradients.length];
    final List<Map<String, dynamic>> folderTasksMap = tasks.map((t) => _mapModelToTaskItem(t)).toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderScreen(
              folderName: category.name,
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
                    category.name,
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

                Transform.translate(
                  offset: const Offset(0, 13),
                  child: _buildCategoryPopupMenu(category),
                ),
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

class _IOSAddCategoryDialogContent extends StatefulWidget {
  const _IOSAddCategoryDialogContent({super.key});
  @override
  State<_IOSAddCategoryDialogContent> createState() => _IOSAddCategoryDialogContentState();
}

class _IOSAddCategoryDialogContentState extends State<_IOSAddCategoryDialogContent> {
  final TextEditingController _nameController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  int _selectedGradientIndex = 0;
  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)],
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)],
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)],
  ];

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF007AFF);
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: Colors.white,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(children: [
                      Text("Add New Category", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Container(
                          height: 40, padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(fontSize: 13),
                              decoration: InputDecoration(hintText: "Category Name", contentPadding: const EdgeInsets.only(bottom: 12, left: 5), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: blueColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: blueColor, width: 1.5)))
                          )
                      ),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => GestureDetector(
                          onTap: ()=>setState(()=>_selectedGradientIndex=index),
                          child: Container(width: 32, height: 32, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(gradient: LinearGradient(colors: availableGradients[index], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle, border: Border.all(color: _selectedGradientIndex==index ? Colors.black87 : Colors.black12, width: _selectedGradientIndex==index ? 2 : 0.5)), child: _selectedGradientIndex==index ? const Icon(Icons.check, size: 18, color: Colors.black54) : null)
                      ))),
                    ])
                ),
                Container(height: 1, color: const Color(0xFFE0E0E0)),
                SizedBox(height: 45, child: Row(children: [
                  Expanded(child: InkWell(onTap: ()=>Navigator.pop(context), child: Center(child: Text("Cancel", style: GoogleFonts.poppins(color: blueColor, fontSize: 15))))),
                  Container(width: 1, color: const Color(0xFFE0E0E0)),
                  Expanded(child: InkWell(onTap: () async {
                    if (_nameController.text.trim().isNotEmpty) {
                      await _categoryService.addCategory(_nameController.text.trim(), _selectedGradientIndex);
                      if (mounted) Navigator.pop(context);
                    }
                  }, child: Center(child: Text("Add", style: GoogleFonts.poppins(color: blueColor, fontSize: 15, fontWeight: FontWeight.w600))))),
                ]))
              ]),
            )
        )
    );
  }
}