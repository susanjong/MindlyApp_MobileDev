import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';
import 'note_card.dart';

class CategoriesTab extends StatefulWidget {
  final NoteService noteService;
  final List<CategoryModel> categories;
  final List<NoteModel> allNotes;
  final Function(String) onNoteSelected;

  const CategoriesTab({
    super.key,
    required this.noteService,
    required this.categories,
    required this.allNotes,
    required this.onNoteSelected,
  });

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  final Set<String> _expandedCategories = {};

  void _toggleExpand(String categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  void _toggleCategoryFavorite(CategoryModel category) async {
    // ✅ FIX: Langsung toggle tanpa refresh callback
    await widget.noteService.toggleCategoryFavorite(category.id, category.isFavorite);
    // Stream akan auto-update UI tanpa perlu setState
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX 1: Filter & Sort Categories
    final allCategories = widget.categories;

    // Pisahkan categories
    final bookmarksCategory = allCategories.firstWhere(
          (c) => c.id == 'bookmarks',
      orElse: () => CategoryModel(id: 'bookmarks', name: 'Bookmarks'),
    );

    // Custom categories (bukan 'all' dan 'bookmarks'), diurutkan A-Z
    final customCategories = allCategories
        .where((c) => c.id != 'all' && c.id != 'bookmarks')
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    // Urutan final: Bookmarks → Custom Categories (A-Z)
    final sortedCategories = [bookmarksCategory, ...customCategories];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];

        // Filter notes by category
        final notes = category.id == 'bookmarks'
            ? widget.allNotes.where((n) => n.categoryId == 'bookmarks').toList()
            : widget.allNotes.where((n) => n.categoryId == category.id).toList();

        return _CategoryItem(
          category: category,
          noteCount: notes.length,
          isExpanded: _expandedCategories.contains(category.id),
          notes: notes,
          onTap: () => _toggleExpand(category.id),
          onFavoriteTap: () => _toggleCategoryFavorite(category),
          onNoteSelected: widget.onNoteSelected,
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final int noteCount;
  final bool isExpanded;
  final List<NoteModel> notes;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final Function(String) onNoteSelected;

  const _CategoryItem({
    required this.category,
    required this.noteCount,
    required this.isExpanded,
    required this.notes,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderPink = Color(0xFFD732A8);
    const Color outlineGrey = Color(0xFF777777);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderPink, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // ✅ FIX 2: Category name clickable untuk expand/collapse
                Expanded(
                  child: GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
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
                        if (noteCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              noteCount.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // ✅ FIX 3: Heart icon clickable terpisah
                GestureDetector(
                  onTap: onFavoriteTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      category.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: category.isFavorite ? Colors.red : outlineGrey,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: notes.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 16),
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
              : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "No notes in this category",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}