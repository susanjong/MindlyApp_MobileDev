import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/widgets/note_card.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  // Sample data - replace with your actual data management
  List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'Work', noteIds: ['n1', 'n2']),
    CategoryModel(id: '2', name: 'Personal', noteIds: ['n3']),
    CategoryModel(id: '3', name: 'Ideas', noteIds: ['n4', 'n5', 'n6']),
  ];

  // Sample notes - replace with your actual notes
  final Map<String, NoteData> notes = {
    'n1': NoteData(
      id: 'n1',
      title: 'Meeting Notes',
      content: 'Discuss Q4 targets and team allocations...',
      date: 'September 30, 2025',
      color: const Color(0xFFFFE4B5),
    ),
    'n2': NoteData(
      id: 'n2',
      title: 'Project Plan',
      content: 'Timeline and deliverables for next sprint...',
      date: 'September 29, 2025',
      color: const Color(0xFFE0BBE4),
    ),
    'n3': NoteData(
      id: 'n3',
      title: 'Grocery List',
      content: 'Milk, eggs, bread, vegetables...',
      date: 'September 30, 2025',
      color: const Color(0xFFB5E7A0),
    ),
    'n4': NoteData(
      id: 'n4',
      title: 'App Feature',
      content: 'New notification system with customizable alerts...',
      date: 'September 28, 2025',
      color: const Color(0xFFFFDAB9),
    ),
    'n5': NoteData(
      id: 'n5',
      title: 'Blog Post',
      content: 'Flutter best practices for state management...',
      date: 'September 27, 2025',
      color: const Color(0xFFAEC6CF),
    ),
    'n6': NoteData(
      id: 'n6',
      title: 'Recipe',
      content: 'Pasta carbonara with creamy sauce...',
      date: 'September 26, 2025',
      color: const Color(0xFFFDFD96),
    ),
  };

  Set<String> expandedCategories = {};
  String? selectedCategoryId;

  void _toggleCategory(String categoryId) {
    setState(() {
      if (expandedCategories.contains(categoryId)) {
        expandedCategories.remove(categoryId);
      } else {
        expandedCategories.add(categoryId);
      }
    });
  }

  void _onCategoryLongPress(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedCategoryId = null;
    });
  }

  void _editCategory(CategoryModel category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => EditCategoryDialog(
        initialName: category.name,
        onCategoryRenamed: (newName) {
          setState(() {
            final index = categories.indexWhere((c) => c.id == category.id);
            if (index != -1) {
              categories[index] = category.copyWith(name: newName);
            }
          });
          _clearSelection();
        },
      ),
    );
  }

  void _deleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDeleteDialog(
        categoryName: category.name,
        onConfirm: () {
          setState(() {
            categories.removeWhere((c) => c.id == category.id);
          });
          _clearSelection();
        },
      ),
    );
  }

  void _toggleFavorite(CategoryModel category) {
    setState(() {
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = category.copyWith(isFavorite: !category.isFavorite);
      }
    });
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final allNotesCount = notes.length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // "All" Category
            CategoryTile(
              category: CategoryModel(
                id: 'all',
                name: 'All',
                noteIds: notes.keys.toList(),
              ),
              noteCount: allNotesCount,
              isExpanded: expandedCategories.contains('all'),
              isSelected: false,
              onTap: () => _toggleCategory('all'),
              onLongPress: () {},
              notes: notes.values.toList(),
            ),

            // User Categories
            ...categories.map((category) {
              final categoryNotes = category.noteIds
                  .map((id) => notes[id])
                  .where((note) => note != null)
                  .cast<NoteData>()
                  .toList();

              return CategoryTile(
                key: ValueKey(category.id),
                category: category,
                noteCount: categoryNotes.length,
                isExpanded: expandedCategories.contains(category.id),
                isSelected: selectedCategoryId == category.id,
                onTap: () => _toggleCategory(category.id),
                onLongPress: () => _onCategoryLongPress(category.id),
                notes: categoryNotes,
              );
            }),
          ],
        ),

        // Action Bar
        if (selectedCategoryId != null && selectedCategoryId != 'all')
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CategoryActionBar(
              onEdit: () {
                final category = categories.firstWhere(
                      (c) => c.id == selectedCategoryId,
                );
                _editCategory(category);
              },
              onDelete: () {
                final category = categories.firstWhere(
                      (c) => c.id == selectedCategoryId,
                );
                _deleteCategory(category);
              },
              onFavorite: () {
                final category = categories.firstWhere(
                      (c) => c.id == selectedCategoryId,
                );
                _toggleFavorite(category);
              },
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// CATEGORY TILE
// ============================================================================
class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int noteCount;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final List<NoteData> notes;

  const CategoryTile({
    super.key,
    required this.category,
    required this.noteCount,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: const Color(0xFF5784EB), width: 2)
                  : null,
            ),
            child: Row(
              children: [
                if (category.isFavorite) ...[
                  const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF131313),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004455),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    noteCount.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down, size: 24),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded && notes.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 170 / 201.90,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  title: note.title,
                  content: note.content,
                  date: note.date,
                  color: note.color,
                );
              },
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ============================================================================
// CATEGORY ACTION BAR
// ============================================================================
class CategoryActionBar extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;

  const CategoryActionBar({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit),
              _ActionButton(icon: Icons.favorite_border, label: 'Favorite', onTap: onFavorite),
              _ActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                labelColor: const Color(0xFFB90000),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? Colors.black;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EDIT CATEGORY DIALOG
// ============================================================================
class EditCategoryDialog extends StatefulWidget {
  final String initialName;
  final Function(String) onCategoryRenamed;

  const EditCategoryDialog({
    super.key,
    required this.initialName,
    required this.onCategoryRenamed,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleOk() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && name != widget.initialName) {
      Navigator.pop(context);
      widget.onCategoryRenamed(name);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: const Color(0xBFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Edit Category',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _handleOk(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5, color: Color(0xA5545458)),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: Text('Cancel',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                            )),
                      ),
                    ),
                  ),
                  Container(width: 0.5, color: const Color(0xA5545458)),
                  Expanded(
                    child: InkWell(
                      onTap: _handleOk,
                      child: Center(
                        child: Text('OK',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                            )),
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

// ============================================================================
// CONFIRM DELETE DIALOG
// ============================================================================
class ConfirmDeleteDialog extends StatelessWidget {
  final String categoryName;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.categoryName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: const Color(0xBFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Delete Category',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to delete "$categoryName"?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5, color: Color(0xA5545458)),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: Text('Cancel',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                            )),
                      ),
                    ),
                  ),
                  Container(width: 0.5, color: const Color(0xA5545458)),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: Center(
                        child: Text('Delete',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFB90000),
                              fontWeight: FontWeight.w600,
                            )),
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

// ============================================================================
// MODELS
// ============================================================================
class CategoryModel {
  final String id;
  String name;
  bool isFavorite;
  List<String> noteIds;

  CategoryModel({
    required this.id,
    required this.name,
    this.isFavorite = false,
    List<String>? noteIds,
  }) : noteIds = noteIds ?? [];

  CategoryModel copyWith({
    String? id,
    String? name,
    bool? isFavorite,
    List<String>? noteIds,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
      noteIds: noteIds ?? this.noteIds,
    );
  }
}

class NoteData {
  final String id;
  final String title;
  final String content;
  final String date;
  final Color color;

  NoteData({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.color,
  });
}