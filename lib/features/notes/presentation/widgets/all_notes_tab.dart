import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AllNotesTab extends StatelessWidget {
  final List<NoteModel> notes;
  final bool isSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;
  final Function(String) onToggleFavorite;
  final String searchQuery;

  const AllNotesTab({
    super.key,
    required this.notes,
    required this.isSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
    required this.onToggleFavorite,
    this.searchQuery = '',
  });

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
    // Responsive logic
    final mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
    final double childAspectRatio = width < 600 ? 0.85 : 1.25;

    // ✅ GUNAKAN CustomScrollView UNTUK MENGHINDARI OVERFLOW PADA EMPTY STATE
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Memberikan padding atas untuk list
        const SliverPadding(padding: EdgeInsets.only(top: 10)),

        if (notes.isEmpty)
        // ✅ FIX: SliverFillRemaining memastikan konten empty state
        // mengisi ruang tersisa tapi bisa di-scroll jika layar terlalu kecil
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Penting agar tidak memaksa tinggi
                children: [
                  Icon(Icons.note_add_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchQuery.isEmpty
                        ? 'Tap + to create your first note'
                        : 'Try a different search',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final note = notes[index];
                  final isSelected = selectedNoteIds.contains(note.id);

                  return NoteCard(
                    title: note.title,
                    content: _getPlainText(note.content),
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,
                    isSelected: isSelectionMode && isSelected,
                    onTap: () => onNoteTap(note.id),
                    onLongPress: () => onNoteLongPress(note.id),
                    onFavoriteTap: () => onToggleFavorite(note.id),
                  );
                },
                childCount: notes.length,
              ),
            ),
          ),
      ],
    );
  }
}