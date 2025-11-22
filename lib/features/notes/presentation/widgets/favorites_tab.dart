import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'note_card.dart';

class FavoritesTab extends StatelessWidget {
  final List<NoteModel> notes;
  final ScrollController? scrollController;
  final Function(String) onNoteSelected;
  final String searchQuery;

  const FavoritesTab({
    super.key,
    required this.notes,
    this.scrollController,
    required this.onNoteSelected,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 100),
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
    );
  }

  Widget _buildEmptyState() {
    final isSearching = searchQuery.isNotEmpty;

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
              isSearching
                  ? 'No favorites found'
                  : 'No favorite notes yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different search term'
                  : 'Tap the heart icon on a note to add it to favorites',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}