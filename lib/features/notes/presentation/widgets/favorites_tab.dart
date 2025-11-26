import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';

class FavoritesTab extends StatefulWidget {
  final List<NoteModel> notes;
  final List<CategoryModel> favoriteCategories;
  final ScrollController? scrollController;
  final Function(String) onNoteSelected;
  final Function(String) onCategoryToggleFavorite;
  final String searchQuery;

  // Selection Mode Props
  final bool isSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;
  final Function(String) onToggleFavorite;

  const FavoritesTab({
    super.key,
    required this.notes,
    required this.favoriteCategories,
    this.scrollController,
    required this.onNoteSelected,
    required this.onCategoryToggleFavorite,
    this.searchQuery = '',
    required this.isSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  bool _isCategoriesExpanded = true;
  bool _isAllNotesExpanded = true;

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
                return _FavoriteCategoryItem(
                  category: category,
                  onFavoriteTap: () => widget.onCategoryToggleFavorite(category.id),
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
                  final isSelected = widget.selectedNoteIds.contains(note.id);

                  return NoteCard(
                    title: note.title,
                    content: note.content,
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,
                    isSelected: widget.isSelectionMode && isSelected,
                    onTap: () => widget.onNoteTap(note.id),
                    onLongPress: () => widget.onNoteLongPress(note.id),
                    onFavoriteTap: () => widget.onToggleFavorite(note.id),
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
  final VoidCallback onFavoriteTap;

  const _FavoriteCategoryItem({required this.category, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD732A8)),
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
          GestureDetector(
            onTap: onFavoriteTap,
            child: const Icon(Icons.favorite, color: Colors.red, size: 22),
          ),
        ],
      ),
    );
  }
}
