import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/add_category_dialog.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../../../core/widgets/navigation/custom_navbar_widget.dart';
import '../../../../core/widgets/navigation/custom_top_app_bar.dart';
import '../widgets/move_to_categories.dart';
import '../widgets/selection_action_bar.dart';
import '../../data/models/note_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/note_service.dart';
import '../widgets/all_notes_tab.dart';
import '../widgets/categories_tab.dart'; // Pastikan import ini benar
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

  // Key untuk mengakses state CategoriesTab
  final GlobalKey<CategoriesTabState> _categoriesTabKey = GlobalKey<CategoriesTabState>();

  bool _isNavBarVisible = true;
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  // State untuk Notes Selection
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};
  List<NoteModel> _currentNotesList = [];

  // State untuk Category Selection (Diangkat ke Parent untuk kontrol UI)
  bool _isCategorySelectionMode = false;

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
    final routes = [AppRoutes.home, AppRoutes.notes, AppRoutes.todo, AppRoutes.calendar];
    if (index != 1) Navigator.pushReplacementNamed(context, routes[index]);
  }

  // === NOTE SELECTION LOGIC ===
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
    // Logic Select All untuk Notes
    if (_selectedTabIndex == 0 || _selectedTabIndex == 2) {
      setState(() {
        if (_selectedNoteIds.length == _currentNotesList.length) {
          _selectedNoteIds.clear();
        } else {
          _selectedNoteIds.addAll(_currentNotesList.map((e) => e.id));
        }
      });
    }
    // Logic Select All untuk Categories
    else if (_selectedTabIndex == 1 && _isCategorySelectionMode) {
      _categoriesTabKey.currentState?.selectAll();
    }
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
    showMoveToDialog(
      context: context,
      noteService: _noteService,
      selectedNoteIds: _selectedNoteIds.toList(),
      onMoveConfirmed: (categoryId) async {
        await _noteService.moveNotesBatch(_selectedNoteIds.toList(), categoryId);
        _exitSelectionMode();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes moved')));
        }
      },
      onAddCategory: (categoryName) async {
        await _noteService.addCategory(
          CategoryModel(id: '', name: categoryName),
        );
      },
    );
  }

  // === GENERAL ACTIONS ===
  void _handleAddNote() {
    Navigator.pushNamed(context, AppRoutes.noteEditor);
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddCategoryDialog(
        onAdd: (name) async {
          await _noteService.addCategory(CategoryModel(id: '', name: name));
          if (mounted) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Category "$name" added')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: _noteService.getCategoriesStream(),
      builder: (context, snapshotCategories) {
        final allCategories = snapshotCategories.data ?? [];

        return StreamBuilder<List<NoteModel>>(
          stream: _noteService.getNotesStream(),
          builder: (context, snapshotNotes) {
            final allNotes = snapshotNotes.data ?? [];
            final filteredNotes = _getFilteredNotes(allNotes);
            _currentNotesList = filteredNotes;

            final selectedModels = allNotes.where((n) => _selectedNoteIds.contains(n.id)).toList();
            final isAllFavorites = selectedModels.isNotEmpty && selectedModels.every((n) => n.isFavorite);

            // Cek status favorite category yg sedang dipilih (jika ada 1 yang dipilih)
            bool isCategoryFavorite = false;
            if (_isCategorySelectionMode && _categoriesTabKey.currentState != null) {
              isCategoryFavorite = _categoriesTabKey.currentState!.isSelectionFavorite;
            }

            return Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: false,
              appBar: CustomTopAppBar(
                // Tampilkan tombol Select All (Expand) jika salah satu mode aktif
                isSelectionMode: _isSelectionMode || _isCategorySelectionMode,
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
                      // Reset semua mode saat ganti tab
                      if (_isSelectionMode) _exitSelectionMode();
                      if (_isCategorySelectionMode) {
                        _categoriesTabKey.currentState?.exitSelectionMode();
                      }
                      setState(() => _selectedTabIndex = index);
                    },
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedTabIndex,
                      children: [
                        // Tab 0: All Notes
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
                          key: _categoriesTabKey,
                          noteService: _noteService,
                          categories: allCategories,
                          allNotes: allNotes,
                          onNoteSelected: (id) => Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: id),
                          // Callback saat mode seleksi kategori berubah
                          onSelectionModeChanged: (isSelecting) {
                            setState(() {
                              _isCategorySelectionMode = isSelecting;
                              // Pastikan navbar visible saat mode seleksi aktif
                              if (isSelecting) _isNavBarVisible = true;
                            });
                          },
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
              // FAB hilang jika sedang mode seleksi apapun
              floatingActionButton: (_isSelectionMode || _isCategorySelectionMode)
                  ? null
                  : NotesExpandableFab(
                onAddNoteTap: _handleAddNote,
                onAddCategoryTap: _showAddCategoryDialog,
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              bottomNavigationBar: _buildBottomNavBar(isAllFavorites, allNotes, isCategoryFavorite),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavBar(bool isAllNotesFavorite, List<NoteModel> allNotes, bool isCategoryFavorite) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen) return const SizedBox.shrink();
    if (!_isNavBarVisible) return const SizedBox.shrink();

    // 1. Navbar untuk Category Selection
    if (_isCategorySelectionMode) {
      // Mengambil widget action bar dari CategoriesTab (yang sudah dibuat public)
      // atau membuatnya disini memanggil fungsi via key
      return CategorySelectionActionBar(
        onEdit: () => _categoriesTabKey.currentState?.handleEdit(),
        onFavorite: () => _categoriesTabKey.currentState?.handleToggleFavorite(),
        onDelete: () => _categoriesTabKey.currentState?.handleDelete(),
        isSelectedFavorite: isCategoryFavorite,
      );
    }

    // 2. Navbar untuk Note Selection
    if (_isSelectionMode) {
      return SelectionActionBar(
        onMove: _moveSelected,
        onFavorite: () => _toggleFavoriteSelected(allNotes),
        onDelete: _deleteSelected,
        isAllSelectedFavorite: isAllNotesFavorite,
      );
    }

    // 3. Navbar Normal
    return CustomNavBar(
      selectedIndex: 1,
      onItemTapped: _handleNavigation,
    );
  }

  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;
    final query = _searchQuery.toLowerCase();
    return notes.where((note) => note.title.toLowerCase().contains(query) || note.content.toLowerCase().contains(query)).toList();
  }
}