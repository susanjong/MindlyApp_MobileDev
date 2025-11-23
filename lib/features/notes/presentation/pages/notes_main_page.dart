import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../../data/models/note_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/note_service.dart';
import '../widgets/all_notes_tab.dart';
import '../widgets/categories_tab.dart';
import '../widgets/favorites_tab.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/note_tab_bar.dart';
import '../widgets/notes_expandable_fab.dart';

class NotesMainPage extends StatefulWidget {
  const NotesMainPage({super.key});

  @override
  State<NotesMainPage> createState() => _NotesMainPageState();
}

class _NotesMainPageState extends State<NotesMainPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final NoteService _noteService = NoteService();

  bool _isNavBarVisible = true;
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  // [1] STATE UNTUK SELECTION MODE
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_handleSearchChange);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.removeListener(_handleSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  // ... (Method handleScroll & handleSearch tetap sama) ...
  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isNavBarVisible) {
      setState(() => _isNavBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isNavBarVisible) {
      setState(() => _isNavBarVisible = true);
    }
  }

  void _handleSearchChange() {
    setState(() => _searchQuery = _searchController.text.trim());
  }

  void _handleTabChange(int index) {
    // Reset selection mode saat pindah tab
    if (_isSelectionMode) _exitSelectionMode();
    setState(() => _selectedTabIndex = index);
  }

  // === SELECTION LOGIC ===

  void _enterSelectionMode(String noteId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNoteIds.add(noteId);
      _isNavBarVisible = true; // Pastikan navbar (action bar) muncul
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  void _toggleNoteSelection(String noteId) {
    if (!_isSelectionMode) {
      // Jika tidak dalam mode seleksi, buka editor note
      Navigator.pushNamed(context, '/note-editor', arguments: noteId)
          .then((_) => _refreshData());
      return;
    }

    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        // Jika tidak ada yang dipilih, keluar mode seleksi
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  // [4] Fungsi Select All (Diakses dari Top Bar)
  void _selectAllNotes() {
    final notes = _getFilteredNotes(_noteService.allNotes);
    setState(() {
      if (_selectedNoteIds.length == notes.length) {
        _selectedNoteIds.clear(); // Deselect all jika sudah terpilih semua
      } else {
        _selectedNoteIds.addAll(notes.map((e) => e.id));
      }
    });
  }

  // [5] LOGIKA DELETE DENGAN IOS DIALOG
  void _deleteSelectedNotes() {
    if (_selectedNoteIds.isEmpty) return;

    showIOSDialog(
      context: context,
      title: 'Delete Notes',
      message: 'Are you sure you want to\ndelete these notes?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A), // Merah sesuai desain
      onConfirm: () {
        // Logic Hapus
        for (var id in _selectedNoteIds) {
          _noteService.deleteNote(id);
        }
        _exitSelectionMode();
        _refreshData();
        // Opsional: Tampilkan snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes deleted')),
        );
      },
    );
  }

  // [5] LOGIKA FAVORITE
  void _favoriteSelectedNotes() {
    if (_selectedNoteIds.isEmpty) return;

    for (var id in _selectedNoteIds) {
      _noteService.toggleFavorite(id);
    }
    _exitSelectionMode();
    _refreshData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes updated')),
    );
  }

  // [5] LOGIKA MOVE TO (Placeholder)
  void _moveSelectedNotes() {
    // Disini bisa tampilkan BottomSheet daftar kategori
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move to feature coming soon')),
    );
  }

  void _refreshData() => setState(() {});

  // ... (Method Dialog Category tetap sama) ...
  void _showCategoryDialog() { /* ... kode lama ... */ }
  void _handleAddNote() { /* ... kode lama ... */ }
  void _handleAddCategory() { _showCategoryDialog(); }

  // === BUILD ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // [4] App Bar Berubah saat Selection Mode
      appBar: CustomTopAppBar(
        isSelectionMode: _isSelectionMode,
        onSelectAllTap: _selectAllNotes,
        onProfileTap: () => Navigator.pushNamed(context, '/profile'),
        onNotificationTap: () {},
      ),
      body: Column(
        children: [
          // Search Bar
          NoteSearchBar(
            controller: _searchController,
            greetingText: 'Hello Susan Jong. How are you today!',
            hintText: 'Search notes...',
            onClear: () => setState(() {}),
          ),

          // Tab Bar
          NoteTabBar(
            selectedIndex: _selectedTabIndex,
            onTabSelected: _handleTabChange,
          ),

          // Tab Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      // Hide FAB saat mode seleksi
      floatingActionButton: _isSelectionMode
          ? null
          : NotesExpandableFab(
        onAddNoteTap: _handleAddNote,
        onAddCategoryTap: _handleAddCategory,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        // Tab 0: All Notes (UPDATED)
        AllNotesTab(
          notes: _getFilteredNotes(_noteService.allNotes),
          scrollController: _scrollController,
          searchQuery: _searchQuery,
          // Kirim State Seleksi
          isSelectionMode: _isSelectionMode,
          selectedNoteIds: _selectedNoteIds,
          // Kirim Callbacks
          onNoteTap: _toggleNoteSelection,
          onNoteLongPress: _enterSelectionMode,
          onToggleFavorite: (id) {
            _noteService.toggleFavorite(id);
            _refreshData();
          },
        ),

        // Tab 1: Categories (Belum ada mode seleksi khusus di sini)
        CategoriesTab(
          noteService: _noteService,
          onNoteSelected: (id) => Navigator.pushNamed(context, '/note-editor', arguments: id),
          onRefresh: _refreshData,
        ),

        // Tab 2: Favorites (Belum ada mode seleksi khusus di sini)
        FavoritesTab(
          notes: _getFilteredNotes(_noteService.favoriteNotes),
          favoriteCategories: _noteService.categories.where((c) => c.isFavorite).toList(),
          scrollController: _scrollController,
          onNoteSelected: (id) => Navigator.pushNamed(context, '/note-editor', arguments: id),
          onCategoryToggleFavorite: (id) {
            _noteService.toggleCategoryFavorite(id);
            _refreshData();
          },
          searchQuery: _searchQuery,
        ),
      ],
    );
  }

  // [1] & [5] BOTTOM BAR LOGIC
  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _isNavBarVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isNavBarVisible ? 1.0 : 0.0,
        child: SafeArea(
          child: _isSelectionMode
              ? _buildSelectionActionBar() // Tampilkan Action Bar jika seleksi
              : CustomNavBar( // Tampilkan Nav Bar biasa jika normal
            selectedIndex: 1,
            onItemTapped: (index) {
              // Navigasi biasa
            },
          ),
        ),
      ),
    );
  }

  // [5] WIDGET BOTTOM ACTION BAR (Move, Favorite, Delete)
  Widget _buildSelectionActionBar() {
    return Container(
      height: 75, // Sesuai desain
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SelectionActionItem(
            icon: Icons.folder_open_outlined,
            label: 'Move to',
            onTap: _moveSelectedNotes,
          ),
          _SelectionActionItem(
            icon: Icons.favorite_border,
            label: 'Favorite',
            onTap: _favoriteSelectedNotes,
          ),
          _SelectionActionItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: const Color(0xFFB90000), // Merah
            onTap: _deleteSelectedNotes,
          ),
        ],
      ),
    );
  }

  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;
    final query = _searchQuery.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }
}

// Widget Helper untuk Item Action Bar
class _SelectionActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SelectionActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}