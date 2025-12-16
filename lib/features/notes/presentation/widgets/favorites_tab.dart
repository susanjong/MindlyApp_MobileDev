import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class FavoritesTab extends StatefulWidget {
  final List<NoteModel> notes;
  final List<CategoryModel> favoriteCategories;
  final Function(String) onNoteSelected;
  final Function(String) onCategoryToggleFavorite;
  final String searchQuery;

  // Note Selection Props
  final bool isSelectionMode; // Note selection mode
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;
  final Function(String) onToggleFavorite;

  // Category Selection Props
  final bool isCategorySelectionMode;
  final Set<String> selectedCategoryIds;
  final Function(String) onCategoryTap;
  final Function(String) onCategoryLongPress;

  const FavoritesTab({
    super.key,
    required this.notes,
    required this.favoriteCategories,
    required this.onNoteSelected,
    required this.onCategoryToggleFavorite,
    this.searchQuery = '',
    // Note Params
    required this.isSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
    required this.onToggleFavorite,
    // Category Params
    required this.isCategorySelectionMode,
    required this.selectedCategoryIds,
    required this.onCategoryTap,
    required this.onCategoryLongPress,
  });

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  bool _isCategoriesExpanded = true;
  bool _isAllNotesExpanded = true;

  // State untuk melacak kategori favorit mana yang sedang dibuka
  final Set<String> _expandedCategories = {};

  String _getPlainText(String jsonContent) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(jsonContent));
      return doc.toPlainText().trim();
    } catch (e) {
      return jsonContent;
    }
  }

  // Logika toggle expand kategori (mirip dengan CategoriesTab)
  void _toggleCategoryExpand(String categoryId) {
    // Jika sedang mode seleksi kategori, tap berfungsi sebagai select, bukan expand
    if (widget.isCategorySelectionMode) {
      widget.onCategoryTap(categoryId);
      return;
    }

    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600 ? 2 : (width < 900 ? 3 : 4);
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Portrait: 0.85, Landscape: 1.25
    return width < 600 ? 0.85 : 1.25;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty && widget.favoriteCategories.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // === Categories Section ===
        if (widget.favoriteCategories.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Categories',
            isExpanded: _isCategoriesExpanded,
            onTap: () => setState(() => _isCategoriesExpanded = !_isCategoriesExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.favoriteCategories.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final category = widget.favoriteCategories[index];
                final isCatSelected = widget.selectedCategoryIds.contains(category.id);

                // Cari notes yang termasuk dalam kategori ini
                // Catatan: Ini mengambil dari widget.notes (yang mungkin hanya berisi Favorite Notes)
                final notesInCategory = widget.notes
                    .where((n) => n.categoryId == category.id)
                    .toList();

                return _FavoriteCategoryItem(
                  category: category,
                  notes: notesInCategory,
                  isSelected: widget.isCategorySelectionMode && isCatSelected,
                  isSelectionMode: widget.isCategorySelectionMode,
                  isExpanded: _expandedCategories.contains(category.id),
                  getPlainText: _getPlainText,

                  // Logic Expand / Select Category
                  onTap: () => _toggleCategoryExpand(category.id),
                  onLongPress: () {
                    if (!widget.isSelectionMode) {
                      widget.onCategoryLongPress(category.id);
                    }
                  },
                  onFavoriteTap: () {
                    if (!widget.isCategorySelectionMode && !widget.isSelectionMode) {
                      widget.onCategoryToggleFavorite(category.id);
                    }
                  },

                  // Logic Note Selection didalam Kategori
                  isNoteSelectionMode: widget.isSelectionMode,
                  selectedNoteIds: widget.selectedNoteIds,
                  onNoteTap: widget.onNoteTap,
                  onNoteLongPress: widget.onNoteLongPress,
                );
              },
            ),
            crossFadeState: _isCategoriesExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],

        // === All Favorites Section ===
        // Menampilkan semua note favorit (sebagai fallback atau akses cepat)
        if (widget.notes.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'All Favorite Notes',
            isExpanded: _isAllNotesExpanded,
            onTap: () => setState(() => _isAllNotesExpanded = !_isAllNotesExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: _getChildAspectRatio(context),
                ),
                itemCount: widget.notes.length,
                itemBuilder: (context, index) {
                  final note = widget.notes[index];
                  final isNoteSelected = widget.selectedNoteIds.contains(note.id);

                  return NoteCard(
                    title: note.title,
                    content: _getPlainText(note.content),
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,
                    isSelected: widget.isSelectionMode && isNoteSelected,
                    onTap: () => widget.onNoteTap(note.id),
                    onLongPress: () {
                      if (!widget.isCategorySelectionMode) {
                        widget.onNoteLongPress(note.id);
                      }
                    },
                    onFavoriteTap: () {
                      if (!widget.isSelectionMode && !widget.isCategorySelectionMode) {
                        widget.onToggleFavorite(note.id);
                      }
                    },
                  );
                },
              ),
            ),
            crossFadeState: _isAllNotesExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({required String title, required bool isExpanded, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF131313),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF131313)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No favorites yet', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _FavoriteCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final List<NoteModel> notes;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isExpanded;
  final String Function(String) getPlainText;

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteTap;

  // Note Selection Props
  final bool isNoteSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;

  const _FavoriteCategoryItem({
    required this.category,
    required this.notes,
    required this.isSelected,
    required this.isSelectionMode,
    required this.isExpanded,
    required this.getPlainText,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteTap,
    required this.isNoteSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderPink = Color(0xFFD732A8);
    const Color selectedGrey = Color(0xFFBABABA);
    const Color checkCircleColor = Color(0xFF777777);

    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
    final double childAspectRatio = width < 600 ? 0.85 : 1.25;

    return Column(
      children: [
        // Header Kategori
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? selectedGrey : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? selectedGrey : borderPink,
              ),
              boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                  ),
                ),

                // Visual Selection & Count Logic
                if (isSelected) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: checkCircleColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                  ),
                ] else ...[
                  // Menampilkan Jumlah Note
                  if (notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        notes.length.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Tombol Favorite
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: const Icon(Icons.favorite, color: Colors.red, size: 22),
                  ),
                ]
              ],
            ),
          ),
        ),

        // Expanded Content (Notes Grid)
        if (!isSelectionMode) // Sembunyikan isi jika sedang mode seleksi Kategori (opsional, agar fokus)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: notes.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.fromLTRB(25, 6, 25, 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final isNoteSelected = selectedNoteIds.contains(note.id);

                  return NoteCard(
                    title: note.title,
                    content: getPlainText(note.content),
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,
                    isSelected: isNoteSelectionMode && isNoteSelected,
                    onTap: () => onNoteTap(note.id),
                    onLongPress: () {
                      // Mencegah konflik gesture
                      if (!isSelectionMode) {
                        onNoteLongPress(note.id);
                      }
                    },
                    // Disable favorite toggle di dalam card kategori favorit untuk menghindari kebingungan UI
                    onFavoriteTap: () {},
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