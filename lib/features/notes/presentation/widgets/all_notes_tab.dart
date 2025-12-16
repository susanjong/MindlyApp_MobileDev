import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AllNotesTab extends StatelessWidget {
  // ... (parameter tetap sama)
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
    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    // ✅ FIX: Responsive Logic
    final mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
    final double childAspectRatio = width < 600 ? 0.85 : 1.25;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 120),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio, 
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
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
    );
  }

  Widget _buildEmptyState() {
    // ... (kode tetap sama)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(searchQuery.isEmpty ? 'No notes yet' : 'No notes found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(searchQuery.isEmpty ? 'Tap + to create your first note' : 'Try a different search', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}