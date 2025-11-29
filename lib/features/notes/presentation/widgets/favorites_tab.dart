// lib/features/notes/presentation/widgets/favorites_tab.dart

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
  final ScrollController? scrollController;
  final Function(String) onNoteSelected;
  final Function(String) onCategoryToggleFavorite;
  final String searchQuery;

  // Note Selection Props
  final bool isSelectionMode; // Note selection mode
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;
  final Function(String) onToggleFavorite;

  // Category Selection Props (BARU)
  final bool isCategorySelectionMode;
  final Set<String> selectedCategoryIds;
  final Function(String) onCategoryTap;
  final Function(String) onCategoryLongPress;

  const FavoritesTab({
    super.key,
    required this.notes,
    required this.favoriteCategories,
    this.scrollController,
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

  String _getPlainText(String jsonContent) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(jsonContent));
      return doc.toPlainText().trim();
    } catch (e) {
      return jsonContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty && widget.favoriteCategories.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      controller: widget.scrollController,
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
                // Cek apakah kategori ini sedang dipilih
                final isCatSelected = widget.selectedCategoryIds.contains(category.id);

                return _FavoriteCategoryItem(
                  category: category,
                  isSelected: widget.isCategorySelectionMode && isCatSelected,
                  isSelectionMode: widget.isCategorySelectionMode,
                  onTap: () {
                    // Jika sedang mode seleksi kategori -> toggle select
                    if (widget.isCategorySelectionMode) {
                      widget.onCategoryTap(category.id);
                    }
                    // Jika sedang mode seleksi Note -> disable tap kategori (opsional)
                    // Jika mode normal -> bisa navigasi (disini kita belum implementasi navigasi ke kategori spesifik)
                  },
                  onLongPress: () {
                    // Jika TIDAK sedang seleksi Note, masuk mode seleksi Kategori
                    if (!widget.isSelectionMode) {
                      widget.onCategoryLongPress(category.id);
                    }
                  },
                  onFavoriteTap: () {
                    // Disable favorite button saat mode seleksi apapun aktif
                    if (!widget.isCategorySelectionMode && !widget.isSelectionMode) {
                      widget.onCategoryToggleFavorite(category.id);
                    }
                  },
                );
              },
            ),
            crossFadeState: _isCategoriesExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],

        // === Notes Section ===
        if (widget.notes.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Notes',
            isExpanded: _isAllNotesExpanded,
            onTap: () => setState(() => _isAllNotesExpanded = !_isAllNotesExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.notes.length,
                itemBuilder: (context, index) {
                  final note = widget.notes[index];
                  // Cek apakah note ini dipilih
                  final isNoteSelected = widget.selectedNoteIds.contains(note.id);

                  return NoteCard(
                    title: note.title,
                    content: _getPlainText(note.content),
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,

                    // Logic Seleksi Note
                    isSelected: widget.isSelectionMode && isNoteSelected,
                    onTap: () => widget.onNoteTap(note.id),
                    onLongPress: () {
                      // Jika TIDAK sedang seleksi Kategori, masuk mode seleksi Note
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
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteTap;

  const _FavoriteCategoryItem({
    required this.category,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderPink = Color(0xFFD732A8);
    const Color selectedGrey = Color(0xFFBABABA);
    const Color checkCircleColor = Color(0xFF777777);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
        height: 50,
        decoration: BoxDecoration(
          // Ganti background jadi abu-abu jika terpilih
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

            // Visual Selection Logic
            if (isSelected) ...[
              // Tampilkan Centang Abu-abu
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
              // Tampilkan Icon Heart
              GestureDetector(
                onTap: onFavoriteTap,
                child: const Icon(Icons.favorite, color: Colors.red, size: 22),
              ),
            ]
          ],
        ),
      ),
    );
  }
}