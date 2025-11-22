import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';
import 'note_card.dart';

class CategoriesTab extends StatefulWidget {
  final NoteService noteService;
  final Function(String) onNoteSelected;
  final VoidCallback? onRefresh;

  const CategoriesTab({
    super.key,
    required this.noteService,
    required this.onNoteSelected,
    this.onRefresh,
  });

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final Set<String> _expandedCategories = {};
  String? _selectedCategoryId;

  // === Event Handlers ===

  void _toggleExpand(String categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  void _selectCategory(String categoryId) {
    if (categoryId == 'all') return; // Cannot select "All" category
    setState(() => _selectedCategoryId = categoryId);
  }

  void _clearSelection() {
    setState(() => _selectedCategoryId = null);
  }

  // === Actions ===

  void _editCategory(CategoryModel category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != category.name) {
                widget.noteService.updateCategory(category.copyWith(name: name));
                widget.onRefresh?.call();
              }
              Navigator.pop(ctx);
              _clearSelection();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Category'),
        content: Text(
          'Delete "${category.name}"?\nNotes will be moved to All Notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              widget.noteService.deleteCategory(category.id);
              widget.onRefresh?.call();
              Navigator.pop(ctx);
              _clearSelection();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(CategoryModel category) {
    widget.noteService.toggleCategoryFavorite(category.id);
    widget.onRefresh?.call();
    _clearSelection();
  }

  // === Build ===

  @override
  Widget build(BuildContext context) {
    final categories = widget.noteService.categories;
    final allNotes = widget.noteService.allNotes;

    return Stack(
      children: [
        // Category List
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final notes = category.id == 'all'
                ? allNotes
                : widget.noteService.getNotesByCategory(category.id);

            return _CategoryItem(
              category: category,
              noteCount: notes.length,
              isExpanded: _expandedCategories.contains(category.id),
              isSelected: _selectedCategoryId == category.id,
              notes: notes,
              onTap: () => _toggleExpand(category.id),
              onLongPress: () => _selectCategory(category.id),
              onNoteSelected: widget.onNoteSelected,
            );
          },
        ),

        // Action Bar (saat category dipilih)
        if (_selectedCategoryId != null && _selectedCategoryId != 'all')
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CategoryActionBar(
              onEdit: () {
                final cat = widget.noteService.getCategoryById(_selectedCategoryId!);
                if (cat != null) _editCategory(cat);
              },
              onDelete: () {
                final cat = widget.noteService.getCategoryById(_selectedCategoryId!);
                if (cat != null) _deleteCategory(cat);
              },
              onFavorite: () {
                final cat = widget.noteService.getCategoryById(_selectedCategoryId!);
                if (cat != null) _toggleFavorite(cat);
              },
              onCancel: _clearSelection,
            ),
          ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final int noteCount;
  final bool isExpanded;
  final bool isSelected;
  final List<NoteModel> notes;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onNoteSelected;

  const _CategoryItem({
    required this.category,
    required this.noteCount,
    required this.isExpanded,
    required this.isSelected,
    required this.notes,
    required this.onTap,
    required this.onLongPress,
    required this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Header
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: const Color(0xFF5784EB), width: 2)
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Favorite Icon
                if (category.isFavorite) ...[
                  const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 20),
                  const SizedBox(width: 12),
                ],

                // Category Name
                Expanded(
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                // Note Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004455),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    noteCount.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Expand Arrow
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Color(0xFF5784EB),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expanded Notes Grid
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: notes.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  title: note.title,
                  content: note.content,
                  date: note.formattedDate,
                  color: Color(note.color),
                  isFavorite: note.isFavorite,
                  onTap: () => onNoteSelected(note.id),
                );
              },
            ),
          )
              : const SizedBox.shrink(),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

// === Category Action Bar ===

class _CategoryActionBar extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final VoidCallback? onCancel;

  const _CategoryActionBar({
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
              _ActionButton(
                icon: Icons.favorite_border,
                label: 'Favorite',
                onTap: onFavorite,
              ),
              _ActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.red,
                onTap: onDelete,
              ),
              _ActionButton(
                icon: Icons.close,
                label: 'Cancel',
                color: Colors.grey,
                onTap: onCancel,
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
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1A1A1A);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: c),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}