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
  // Kita hapus logic selection mode yang lama karena sekarang interaksi langsung di item
  // Namun jika ingin fitur edit/delete kategori tetap ada, bisa diakses lewat long press atau button lain.
  // Untuk saat ini saya fokus ke tampilan list sesuai request.

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

  // Fungsi langsung untuk toggle favorite dari icon love
  void _toggleCategoryFavorite(CategoryModel category) {
    widget.noteService.toggleCategoryFavorite(category.id);
    setState(() {}); // Refresh UI lokal
    widget.onRefresh?.call(); // Refresh UI parent jika perlu
  }

  // === Build ===

  @override
  Widget build(BuildContext context) {
    final categories = widget.noteService.categories;
    final allNotes = widget.noteService.allNotes;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
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
    // Warna sesuai request
    const Color borderPink = Color(0xFFD732A8);
    const Color outlineGrey = Color(0xFF777777);

    return Column(
      children: [
        // Category Container (Tap to expand)
        GestureDetector(
          onTap: onTap, // [3] Tap container untuk expand
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            height: 50, // Sesuaikan tinggi seperti desain
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              // [1] Border pink D732A8
              border: Border.all(
                color: borderPink,
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

                  // Note Count Badge (Saya pertahankan style sebelumnya agar rapi)
                  // Bisa diubah transparan jika ingin hanya angka
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

                  const SizedBox(width: 12),

                  // [4] & [5] Icon Love (Favorite)
                  // Menggunakan GestureDetector agar tap love tidak mentrigger expand
                  GestureDetector(
                    onTap: () {
                      // Feedback visual kecil saat ditekan (opsional)
                      onFavoriteTap();
                    },
                    child: Icon(
                      category.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: category.isFavorite ? Colors.red : outlineGrey,
                      size: 22,
                    ),
                  ),

                  // [2] Tidak ada icon arrow down di sini
                ],
              ),
            ),
          ),
        ),

        // Expanded Notes Grid (Isi Kategori)
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
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey
              ),
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}