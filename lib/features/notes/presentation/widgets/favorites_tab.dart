import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';

class FavoritesTab extends StatefulWidget {
  final List<NoteModel> notes;
  final List<CategoryModel> favoriteCategories; // Data Kategori Favorit
  final ScrollController? scrollController;
  final Function(String) onNoteSelected;
  final Function(String) onCategoryToggleFavorite; // Callback saat love ditekan
  final String searchQuery;

  const FavoritesTab({
    super.key,
    required this.notes,
    required this.favoriteCategories,
    this.scrollController,
    required this.onNoteSelected,
    required this.onCategoryToggleFavorite,
    this.searchQuery = '',
  });

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  // State untuk dropdown
  bool _isCategoriesExpanded = true;
  bool _isAllNotesExpanded = true;

  @override
  Widget build(BuildContext context) {
    // Jika kosong sama sekali (tidak ada note fav DAN tidak ada kategori fav)
    if (widget.notes.isEmpty && widget.favoriteCategories.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // === SECTION 1: CATEGORIES ===
        if (widget.favoriteCategories.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Categories',
            isExpanded: _isCategoriesExpanded,
            onTap: () => setState(() => _isCategoriesExpanded = !_isCategoriesExpanded),
          ),

          // Isi Dropdown Categories
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.favoriteCategories.length,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemBuilder: (context, index) {
                final category = widget.favoriteCategories[index];
                return _FavoriteCategoryItem(
                  category: category,
                  onTap: () {
                    // Aksi jika kategori ditekan (misal: filter notes di masa depan)
                  },
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

        // === SECTION 2: ALL NOTES ===
        if (widget.notes.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'All Notes',
            isExpanded: _isAllNotesExpanded,
            onTap: () => setState(() => _isAllNotesExpanded = !_isAllNotesExpanded),
          ),

          // Isi Dropdown Notes (GridView)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
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
                  return NoteCard(
                    title: note.title,
                    content: note.content,
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,
                    onTap: () => widget.onNoteSelected(note.id),
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

  // Widget Header Dropdown (Teks + Icon Arrow)
  Widget _buildSectionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
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
                fontWeight: FontWeight.w700, // Bold sesuai desain
                color: const Color(0xFF131313),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0, // Putar arrow saat expand
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF131313), // Warna hitam
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = widget.searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.favorite_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No favorites found' : 'No favorites yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Item Kategori Khusus Favorit (Border Pink + Red Heart)
class _FavoriteCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _FavoriteCategoryItem({
    required this.category,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna sesuai desain (Button Pink)
    const Color borderPink = Color(0xFFD732A8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderPink, // Border Pink
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Nama Kategori
              Expanded(
                child: Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),

              // Icon Love Merah (Karena masuk tab Favorites, pasti merah)
              GestureDetector(
                onTap: onFavoriteTap,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red, // Merah Filled
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}