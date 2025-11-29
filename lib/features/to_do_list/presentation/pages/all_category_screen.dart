import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/todo_model.dart';
import '../../data/services/todo_services.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

import '../widgets/task_item.dart';
import 'folder_screen.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({Key? key}) : super(key: key);

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

  // ✅ LOGIC SELECTION MODE (SAMA SEPERTI NOTES PAGE)
  bool _isSelectMode = false;
  final Set<String> _selectedTaskIds = {}; // Menggunakan ID Firestore, bukan index

  // -- Event Handlers --

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

  // ✅ LOGIC DELETE DENGAN IOS DIALOG (SAMA SEPERTI NOTES PAGE)
  void _deleteSelectedTasks() {
    if (_selectedTaskIds.isEmpty) return;

    showIOSDialog(
      context: context,
      title: 'Delete Tasks',
      message: 'Are you sure you want to\ndelete these ${_selectedTaskIds.length} tasks?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        // Hapus task satu per satu berdasarkan ID
        for (String id in _selectedTaskIds) {
          await _todoService.deleteTodo(id);
        }

        // Reset state
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
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        _categoryService.addCategory(
          result['name'],
          result['gradientIndex'],
        );
      }
    });
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

          // Filter Uncategorized
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
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
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
                              // Popup Menu untuk masuk mode Select
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
                                  onToggle: () => _todoService.toggleTodoStatus(task.id, task.isCompleted),
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

      // ✅ FAB LOGIC (BERUBAH JADI DELETE SAAT SELECT MODE)
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
              await _todoService.toggleTodoStatus(t.id, false);
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

  // ✅ WIDGET ITEM SAAT MODE SELEKSI (CHECKBOX)
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

// -----------------------------------------------------------
// DIALOG & HELPER CLASS (Sama seperti NotesMainPage)
// -----------------------------------------------------------

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
                  Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: Color(0xA5545458)),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(child: InkWell(onTap: () { Navigator.pop(context); onCancel?.call(); }, child: Center(child: Text(cancelText, style: GoogleFonts.poppins(color: const Color(0xFF0A84FF), fontSize: 14))))),
                  const VerticalDivider(width: 0.5, thickness: 0.5, color: Color(0xA5545458)),
                  Expanded(child: InkWell(onTap: () { Navigator.pop(context); onConfirm(); }, child: Center(child: Text(confirmText, style: GoogleFonts.poppins(color: confirmTextColor ?? const Color(0xFFFF453A), fontSize: 14))))),
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

// Widget Dialog Add Category
class _IOSAddCategoryDialogContent extends StatefulWidget {
  const _IOSAddCategoryDialogContent({Key? key}) : super(key: key);
  @override
  State<_IOSAddCategoryDialogContent> createState() => _IOSAddCategoryDialogContentState();
}

class _IOSAddCategoryDialogContentState extends State<_IOSAddCategoryDialogContent> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedGradientIndex = 0;
  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)],
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)],
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)],
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("Add Category", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 16),
                TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Category Name", border: OutlineInputBorder())),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => GestureDetector(
                    onTap: ()=>setState(()=>_selectedGradientIndex=index),
                    child: Container(width: 36, height: 36, margin: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: LinearGradient(colors: availableGradients[index]), shape: BoxShape.circle, border: _selectedGradientIndex==index ? Border.all(width: 2) : null))
                ))),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context, {'name': _nameController.text, 'gradientIndex': _selectedGradientIndex});
                }, child: const Text("Add"))
              ]),
            )
        )
    );
  }
}