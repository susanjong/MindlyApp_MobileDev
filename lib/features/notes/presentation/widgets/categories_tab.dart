import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';
import 'note_card.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

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

  // Helper untuk convert JSON ke plain text
  String _getPlainText(String jsonContent) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(jsonContent));
      return doc.toPlainText().trim();
    } catch (e) {
      return jsonContent;
    }
  }

  void _toggleExpand(String categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan kategori langsung dari stream (sudah diurutkan di service)
    // Filter manual untuk jaga-jaga jika ada data lama 'all' atau 'bookmarks'
    final displayCategories = widget.categories
        .where((c) => c.id != 'all' && c.id != 'bookmarks')
        .toList();

    if (displayCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No categories yet',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        final category = displayCategories[index];

        final notes = widget.allNotes.where((n) => n.categoryId == category.id).toList();

        return _CategoryItem(
          key: ValueKey('${category.id}_${category.isFavorite}'),
          category: category,
          noteCount: notes.length,
          isExpanded: _expandedCategories.contains(category.id),
          notes: notes,
          onTap: () => _toggleExpand(category.id),
          noteService: widget.noteService,
          onNoteSelected: widget.onNoteSelected,
          getPlainText: _getPlainText,
        );
      },
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final CategoryModel category;
  final int noteCount;
  final bool isExpanded;
  final List<NoteModel> notes;
  final VoidCallback onTap;
  final NoteService noteService;
  final Function(String) onNoteSelected;
  final String Function(String) getPlainText;

  const _CategoryItem({
    super.key,
    required this.category,
    required this.noteCount,
    required this.isExpanded,
    required this.notes,
    required this.onTap,
    required this.noteService,
    required this.onNoteSelected,
    required this.getPlainText,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.category.isFavorite;
  }

  @override
  void didUpdateWidget(_CategoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.isFavorite != widget.category.isFavorite) {
      setState(() {
        _isFavorite = widget.category.isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    // Optimistic Update: Update UI dulu
    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      await widget.noteService.toggleCategoryFavorite(
        widget.category.id,
        widget.category.isFavorite, // kirim status lama untuk ditoggle di service
      );
    } catch (e) {
      // Revert jika gagal
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

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
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.category.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (widget.noteCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              widget.noteCount.toString(),
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
                GestureDetector(
                  onTap: _toggleFavorite,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : outlineGrey,
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
          secondChild: widget.notes.isNotEmpty
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
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final note = widget.notes[index];
                return NoteCard(
                  title: note.title,
                  content: widget.getPlainText(note.content),
                  date: note.formattedDate,
                  color: Color(note.color),
                  isFavorite: note.isFavorite,
                  onTap: () => widget.onNoteSelected(note.id),
                  // Disable favorite tap inside category view to prevent confusion, or enable if needed
                  onFavoriteTap: () {},
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
          crossFadeState: widget.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}