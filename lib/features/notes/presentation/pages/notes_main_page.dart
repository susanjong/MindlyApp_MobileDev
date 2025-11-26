import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../widgets/selection_action_bar.dart';
import '../../data/models/note_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/note_service.dart';
import '../widgets/all_notes_tab.dart';
import '../widgets/categories_tab.dart';
import '../widgets/favorites_tab.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/note_tab_bar.dart';
import '../widgets/notes_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};
  List<NoteModel> _currentNotesList = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
    }
  }

  void _handleNavigation(int index) {
    final routes = [
      AppRoutes.home,
      AppRoutes.notes,
      AppRoutes.todo,
      AppRoutes.calendar,
    ];
    if (index != 1) Navigator.pushReplacementNamed(context, routes[index]);
  }

  void _enterSelectionMode(String noteId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNoteIds.add(noteId);
      _isNavBarVisible = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  void _toggleSelection(String noteId) {
    if (!_isSelectionMode) {
      Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: noteId);
      return;
    }
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedNoteIds.length == _currentNotesList.length) {
        _selectedNoteIds.clear();
      } else {
        _selectedNoteIds.addAll(_currentNotesList.map((e) => e.id));
      }
    });
  }

  void _deleteSelected() {
    showIOSDialog(
      context: context,
      title: 'Delete Notes',
      message: 'Are you sure you want to\ndelete these ${_selectedNoteIds.length} notes?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        await _noteService.deleteNotesBatch(_selectedNoteIds.toList());
        _exitSelectionMode();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes deleted')));
      },
    );
  }

  void _toggleFavoriteSelected(List<NoteModel> allNotes) async {
    final selectedNotes = allNotes.where((n) => _selectedNoteIds.contains(n.id)).toList();
    final allAreFavorites = selectedNotes.every((n) => n.isFavorite);
    await _noteService.setFavoriteBatch(_selectedNoteIds.toList(), !allAreFavorites);
    _exitSelectionMode();
  }

  void _moveSelected() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StreamBuilder<List<CategoryModel>>(
          stream: _noteService.getCategoriesStream(),
          builder: (context, snapshot) {
            final categories = snapshot.data ?? [];
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text('Move to...', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  if(categories.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text("No categories")),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(categories[index].name, style: GoogleFonts.poppins()),
                        onTap: () async {
                          await _noteService.moveNotesBatch(_selectedNoteIds.toList(), categories[index].id);
                          Navigator.pop(ctx);
                          _exitSelectionMode();
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes moved')));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // ✅ FIXED: Add Note Function - Navigasi ke NoteEditorPage tanpa noteId
  void _handleAddNote() {
    // Navigasi ke editor tanpa noteId = mode create new note
    Navigator.pushNamed(context, AppRoutes.noteEditor);
  }

  // ✅ Dialog untuk Add Category
  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Category', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _noteService.addCategory(
                  CategoryModel(
                    id: '',
                    name: controller.text.trim(),
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NoteModel>>(
      stream: _noteService.getNotesStream(),
      builder: (context, snapshotNotes) {
        final allNotes = snapshotNotes.data ?? [];
        final filteredNotes = _getFilteredNotes(allNotes);
        _currentNotesList = filteredNotes;

        final selectedModels = allNotes.where((n) => _selectedNoteIds.contains(n.id)).toList();
        final isAllFavorites = selectedModels.isNotEmpty && selectedModels.every((n) => n.isFavorite);

        return StreamBuilder<List<CategoryModel>>(
          stream: _noteService.getCategoriesStream(),
          builder: (context, snapshotCategories) {
            final allCategories = snapshotCategories.data ?? [];

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomTopAppBar(
                isSelectionMode: _isSelectionMode,
                onSelectAllTap: _selectAll,
                onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                onNotificationTap: () {},
              ),
              body: Column(
                children: [
                  NoteSearchBar(
                    controller: _searchController,
                    onClear: () => setState(() => _searchController.clear()),
                  ),
                  NoteTabBar(
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) {
                      if (_isSelectionMode) _exitSelectionMode();
                      setState(() => _selectedTabIndex = index);
                    },
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedTabIndex,
                      children: [
                        // ✅ Tab 0: All Notes - Sudah Fixed, hanya dari Firestore
                        AllNotesTab(
                          notes: filteredNotes,
                          scrollController: _scrollController,
                          isSelectionMode: _isSelectionMode,
                          selectedNoteIds: _selectedNoteIds,
                          onNoteTap: _toggleSelection,
                          onNoteLongPress: _enterSelectionMode,
                          onToggleFavorite: (id) {
                            final note = allNotes.firstWhere((n) => n.id == id);
                            _noteService.toggleFavorite(id, note.isFavorite);
                          },
                          searchQuery: _searchQuery,
                        ),

                        // Tab 1: Categories
                        CategoriesTab(
                          noteService: _noteService,
                          categories: allCategories,
                          allNotes: allNotes,
                          onNoteSelected: (id) => Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: id),
                        ),

                        // Tab 2: Favorites
                        FavoritesTab(
                          notes: filteredNotes.where((n) => n.isFavorite).toList(),
                          favoriteCategories: allCategories.where((c) => c.isFavorite).toList(),
                          scrollController: _scrollController,
                          onNoteSelected: (id) => Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: id),
                          onCategoryToggleFavorite: (id) async {
                            final cat = allCategories.firstWhere((c) => c.id == id);
                            await _noteService.toggleCategoryFavorite(id, cat.isFavorite);
                          },
                          isSelectionMode: _isSelectionMode,
                          selectedNoteIds: _selectedNoteIds,
                          onNoteTap: _toggleSelection,
                          onNoteLongPress: _enterSelectionMode,
                          onToggleFavorite: (id) {
                            final note = allNotes.firstWhere((n) => n.id == id);
                            _noteService.toggleFavorite(id, note.isFavorite);
                          },
                          searchQuery: _searchQuery,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ✅ FIXED: FAB sekarang terhubung dengan fungsi add note
              floatingActionButton: _isSelectionMode
                  ? null
                  : NotesExpandableFab(
                onAddNoteTap: _handleAddNote, // ✅ Fungsi add note
                onAddCategoryTap: _showAddCategoryDialog, // ✅ Fungsi add category
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              bottomNavigationBar: _buildBottomNavBar(isAllFavorites, allNotes),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavBar(bool isAllFavorites, List<NoteModel> allNotes) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _isNavBarVisible ? (_isSelectionMode ? 75 : 64) + MediaQuery.of(context).padding.bottom : 0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSelectionMode
            ? SelectionActionBar(
          key: const ValueKey('SelectionBar'),
          onMove: _moveSelected,
          onFavorite: () => _toggleFavoriteSelected(allNotes),
          onDelete: _deleteSelected,
          isAllSelectedFavorite: isAllFavorites,
        )
            : CustomNavBar(
          key: const ValueKey('NavBar'),
          selectedIndex: 1,
          onItemTapped: _handleNavigation,
        ),
      ),
    );
  }

  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;
    final query = _searchQuery.toLowerCase();
    return notes.where((note) =>
    note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query)).toList();
  }
}