import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';

class AllNotesTab extends StatelessWidget {
  final List<NoteModel> notes;
  final ScrollController? scrollController;
  final bool isSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;
  final Function(String) onToggleFavorite;
  final String searchQuery;

  const AllNotesTab({
    super.key,
    required this.notes,
    this.scrollController,
    required this.isSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
    required this.onToggleFavorite,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    // ✅ HANYA TAMPILKAN NOTES DARI FIRESTORE
    // Jika tidak ada notes, tampilkan empty state
    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length, // ✅ Gunakan length dari Firestore
      itemBuilder: (context, index) {
        final note = notes[index]; // ✅ Data langsung dari Firestore
        final isSelected = selectedNoteIds.contains(note.id);

        return NoteCard(
          title: note.title,
          content: note.content,
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

  // ✅ Empty State ketika belum ada notes
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No notes yet'
                : 'No notes found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Tap + to create your first note'
                : 'Try a different search',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}