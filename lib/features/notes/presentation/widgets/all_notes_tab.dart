import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';

class AllNotesTab extends StatelessWidget {
  final List<NoteModel> notes;
  final ScrollController? scrollController;
  final String searchQuery;

  // Properti Selection Mode
  final bool isSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap; // Navigasi atau Toggle Selection
  final Function(String) onNoteLongPress; // Mulai Selection
  final Function(String) onToggleFavorite; // Toggle Favorite

  const AllNotesTab({
    super.key,
    required this.notes,
    this.scrollController,
    this.searchQuery = '',
    required this.isSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 120), // Padding bawah untuk navbar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedNoteIds.contains(note.id);

        return NoteCard(
          title: note.title,
          content: note.content,
          date: note.formattedDate,
          color: Color(note.color),
          isFavorite: note.isFavorite,
          // State selection
          isSelected: isSelectionMode && isSelected,

          // Interaction
          onTap: () => onNoteTap(note.id),
          onLongPress: () => onNoteLongPress(note.id),
          onFavoriteTap: () => onToggleFavorite(note.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    // ... (Kode Empty State tetap sama)
    final isSearching = searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.note_add_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No notes found' : 'No notes yet',
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