import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

/// Dialog untuk memindahkan notes ke kategori lain
/// Simpan di: lib/features/notes/presentation/widgets/move_to_categories.dart
void showMoveToDialog({
  required BuildContext context,
  required List<CategoryModel> categories,
  required List<String> selectedNoteIds,
  required Function(String categoryId) onMoveConfirmed,
  required Function(String categoryName) onAddCategory,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MoveToCategoriesDialog(
      categories: categories,
      selectedNoteIds: selectedNoteIds,
      onMoveConfirmed: onMoveConfirmed,
      onAddCategory: onAddCategory,
    ),
  );
}

class MoveToCategoriesDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<String> selectedNoteIds;
  final Function(String categoryId) onMoveConfirmed;
  final Function(String categoryName) onAddCategory;

  const MoveToCategoriesDialog({
    super.key,
    required this.categories,
    required this.selectedNoteIds,
    required this.onMoveConfirmed,
    required this.onAddCategory,
  });

  @override
  State<MoveToCategoriesDialog> createState() => _MoveToCategoriesDialogState();
}

class _MoveToCategoriesDialogState extends State<MoveToCategoriesDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _filteredCategories {
    if (_searchQuery.isEmpty) return widget.categories;
    return widget.categories
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddCategoryDialog(
        onAdd: (name) async {
          await widget.onAddCategory(name);
          if (mounted) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Category "$name" created')),
            );
          }
        },
      ),
    );
  }

  void _confirmMove() {
    if (_selectedCategoryId == null) return;

    final selectedCategory = widget.categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
    );

    showIOSDialog(
      context: context,
      title: 'Move Notes',
      message: 'Move ${widget.selectedNoteIds.length} note${widget.selectedNoteIds.length > 1 ? 's' : ''} to\n"${selectedCategory.name}"?',
      confirmText: 'Move',
      confirmTextColor: const Color(0xFF5784EB),
      onConfirm: () {
        widget.onMoveConfirmed(_selectedCategoryId!);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notes moved to "${selectedCategory.name}"')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayCategories = _filteredCategories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(25, 20, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Move to...',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                // Add Category Button
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined, size: 26),
                  onPressed: _showAddCategoryDialog,
                  tooltip: 'Add Category',
                ),
                // Confirm Button
                IconButton(
                  icon: Icon(
                    Icons.check,
                    size: 28,
                    color: _selectedCategoryId != null
                        ? const Color(0xFF5784EB)
                        : Colors.grey.shade400,
                  ),
                  onPressed: _selectedCategoryId != null ? _confirmMove : null,
                  tooltip: 'Confirm Move',
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.5),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF6A6E76), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6A6E76),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.clear, color: Color(0xFF6A6E76), size: 18),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Categories List
          Expanded(
            child: displayCategories.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No categories yet'
                        : 'No categories found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 22.5, vertical: 8),
              itemCount: displayCategories.length,
              itemBuilder: (context, index) {
                final category = displayCategories[index];
                final isSelected = _selectedCategoryId == category.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CategoryItem(
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = isSelected ? null : category.id;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF5784EB) : const Color(0xFFD732A8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x3F000000),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            // Favorite Icon
            if (category.isFavorite)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red.shade400,
                  size: 18,
                ),
              ),
            // Selection Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5784EB) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF5784EB) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog untuk menambahkan kategori baru
class _AddCategoryDialog extends StatefulWidget {
  final Function(String name) onAdd;

  const _AddCategoryDialog({required this.onAdd});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await widget.onAdd(name);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    'New Category',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.29,
                      letterSpacing: -0.41,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Input Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Category name',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF999999),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _handleAdd(),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: double.infinity,
              height: 0.5,
              decoration: const BoxDecoration(color: Color(0xA5545458)),
            ),

            // Buttons
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : () => Navigator.pop(context),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                        ),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.57,
                              letterSpacing: -0.41,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 0.5,
                    height: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xA5545458)),
                  ),

                  // Add Button
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _handleAdd,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(14),
                        ),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0A84FF),
                              ),
                            ),
                          )
                              : Text(
                            'Add',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0A84FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.57,
                              letterSpacing: -0.41,
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
    );
  }
}