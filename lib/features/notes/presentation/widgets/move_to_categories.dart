import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/core/widgets/dialog/input_category_dialog.dart';
import '../../data/models/category_model.dart';
import '../../data/services/note_service.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import 'note_search_bar.dart';

// Helper function untuk menampilkan Modal Bottom Sheet pemindahan kategori
void showMoveToDialog({
  required BuildContext context,
  required NoteService noteService,
  required List<String> selectedNoteIds,
  required Function(String categoryId) onMoveConfirmed,
  required Function(String categoryName) onAddCategory,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MoveToCategoriesDialog(
      noteService: noteService,
      selectedNoteIds: selectedNoteIds,
      onMoveConfirmed: onMoveConfirmed,
      onAddCategory: onAddCategory,
    ),
  );
}

class MoveToCategoriesDialog extends StatefulWidget {
  final NoteService noteService;
  final List<String> selectedNoteIds;
  final Function(String categoryId) onMoveConfirmed;
  final Function(String categoryName) onAddCategory;

  const MoveToCategoriesDialog({
    super.key,
    required this.noteService,
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
    // Listener untuk mendeteksi input pencarian secara real-time
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter kategori: Hapus folder sistem ('all', 'bookmarks') dan filter berdasarkan search query
  List<CategoryModel> _filterCategories(List<CategoryModel> categories) {
    final validCategories = categories.where((c) => c.id != 'all' && c.id != 'bookmarks').toList();

    if (_searchQuery.isEmpty) return validCategories;
    return validCategories
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  // Menampilkan dialog untuk membuat kategori baru langsung dari bottom sheet ini
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => InputCategoryDialog(
        title: "New Note Folder",
        onSave: (name) async {
          await widget.onAddCategory(name);

          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // Validasi pilihan dan menampilkan konfirmasi sebelum memindahkan notes
  void _confirmMove(List<CategoryModel> currentCategories) {
    if (_selectedCategoryId == null) return;

    final selectedCategory = currentCategories.firstWhere(
          (c) => c.id == _selectedCategoryId,
      orElse: () => CategoryModel(id: '', name: 'Unknown'),
    );

    showIOSDialog(
      context: context,
      title: 'Move Notes',
      message: 'Move ${widget.selectedNoteIds.length} note${widget.selectedNoteIds.length > 1 ? 's' : ''} to\n"${selectedCategory.name}"?',
      confirmText: 'Move',
      confirmTextColor: const Color(0xFF5784EB),
      onConfirm: () {
        widget.onMoveConfirmed(_selectedCategoryId!);
        Navigator.pop(context); // Tutup dialog konfirmasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notes moved to "${selectedCategory.name}"')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // StreamBuilder memastikan daftar kategori selalu up-to-date dari database
      child: StreamBuilder<List<CategoryModel>>(
        stream: widget.noteService.getCategoriesStream(),
        builder: (context, snapshot) {
          final allCategories = snapshot.data ?? [];
          final displayCategories = _filterCategories(allCategories);

          return Column(
            children: [
              // Header UI: Judul, Tombol Tambah Folder, dan Tombol Konfirmasi (Checklist)
              Container(
                padding: const EdgeInsets.fromLTRB(25, 20, 20, 0),
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
                    IconButton(
                      icon: const Icon(Icons.create_new_folder_outlined, size: 26),
                      onPressed: _showAddCategoryDialog,
                      tooltip: 'Add Category',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        size: 28,
                        color: _selectedCategoryId != null
                            ? const Color(0xFF5784EB)
                            : Colors.grey.shade400,
                      ),
                      onPressed: _selectedCategoryId != null ? () => _confirmMove(allCategories) : null,
                      tooltip: 'Confirm Move',
                    ),
                  ],
                ),
              ),

              // Widget pencarian kategori
              NoteSearchBar(
                controller: _searchController,
                hintText: 'Search categories...',
                onClear: () {
                  setState(() => _searchQuery = '');
                },
              ),

              const SizedBox(height: 4),

              // List Kategori
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
                          // Toggle seleksi kategori
                          setState(() {
                            _selectedCategoryId = isSelected ? null : category.id;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          );
        },
      ),
    );
  }
}

// Widget item list kategori dengan animasi border dan indikator seleksi
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
          // Border biru jika dipilih, pink jika tidak
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
            // Tampilkan ikon hati kecil jika kategori ini favorit
            if (category.isFavorite)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red.shade400,
                  size: 18,
                ),
              ),
            // Radio button custom (lingkaran checklist)
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