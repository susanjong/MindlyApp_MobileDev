import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/core/widgets/dialog/input_category_dialog.dart';
import '../../../../core/widgets/buttons/global_expandable_fab.dart';
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
import '../widgets/categories_tab.dart';
import '../widgets/favorites_tab.dart';
import '../widgets/note_search_bar.dart';
import '../widgets/note_tab_bar.dart';

class NotesMainPage extends StatefulWidget {
  const NotesMainPage({super.key});

  @override
  State<NotesMainPage> createState() => _NotesMainPageState();
}

class _NotesMainPageState extends State<NotesMainPage> {
  // Controller dan Service
  final TextEditingController _searchController = TextEditingController();
  final NoteService _noteService = NoteService();

  // State UI Dasar
  bool _isNavBarVisible = true;
  int _selectedTabIndex = 0; // 0: All, 1: Categories, 2: Favorites
  String _searchQuery = '';

  // State Mode Seleksi Notes (Multi-select)
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};
  List<NoteModel> _currentNotesList = [];

  // State Mode Seleksi Kategori
  bool _isCategorySelectionMode = false;
  final Set<String> _selectedCategoryIds = {};
  List<CategoryModel> _currentCategoriesList = [];

  @override
  void initState() {
    super.initState();
    // Listener untuk pencarian real-time
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigasi Bottom Bar utama
  void _handleNavigation(int index) {
    final routes = [AppRoutes.home, AppRoutes.notes, AppRoutes.todo, AppRoutes.calendar];
    if (index != 1) Navigator.pushReplacementNamed(context, routes[index]);
  }

  // --- Logika Seleksi Notes ---

  // Mengaktifkan mode seleksi saat long press note
  void _enterSelectionMode(String noteId) {
    if (_isCategorySelectionMode) return;
    setState(() {
      _isSelectionMode = true;
      _selectedNoteIds.add(noteId);
      _isNavBarVisible = true;
    });
  }

  // Menambah/menghapus item dari daftar seleksi atau membuka detail jika mode normal
  void _toggleSelection(String noteId) {
    if (_isCategorySelectionMode) return;
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

  // Mereset tab index dan membatalkan seleksi saat pindah tab
  void _onTabChanged(int index) {
    if (_isSelectionMode) _exitNoteSelectionMode();
    if (_isCategorySelectionMode) _exitCategorySelectionMode();
    setState(() => _selectedTabIndex = index);
  }

  void _exitNoteSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  // --- Logika Seleksi Kategori ---

  void _enterCategorySelectionMode(String categoryId) {
    if (_isSelectionMode) return;
    setState(() {
      _isCategorySelectionMode = true;
      _selectedCategoryIds.clear();
      _selectedCategoryIds.add(categoryId);
      _isNavBarVisible = true;
    });
  }

  void _toggleCategorySelection(String categoryId) {
    if (!_isCategorySelectionMode) return;
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
        if (_selectedCategoryIds.isEmpty) _isCategorySelectionMode = false;
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _exitCategorySelectionMode() {
    setState(() {
      _isCategorySelectionMode = false;
      _selectedCategoryIds.clear();
    });
  }

  // --- Aksi Action Bar (Select All, Delete, Move, Rename) ---

  // Logika toggle select all untuk kategori atau notes
  void _selectAll() {
    if (_isCategorySelectionMode) {
      final validCats = _currentCategoriesList
          .where((c) => c.id != 'all' && c.id != 'bookmarks')
          .map((c) => c.id);
      setState(() {
        if (_selectedCategoryIds.length == validCats.length) {
          _selectedCategoryIds.clear();
        } else {
          _selectedCategoryIds.addAll(validCats);
        }
      });
    } else {
      setState(() {
        if (_selectedNoteIds.length == _currentNotesList.length) {
          _selectedNoteIds.clear();
        } else {
          _selectedNoteIds.addAll(_currentNotesList.map((e) => e.id));
        }
      });
    }
  }

  // Hapus notes yang dipilih dengan konfirmasi
  void _deleteSelectedNotes() {
    showIOSDialog(
      context: context,
      title: 'Delete Notes',
      message: 'Delete ${_selectedNoteIds.length} notes?',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        await _noteService.deleteNotesBatch(_selectedNoteIds.toList());
        _exitNoteSelectionMode();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes deleted')));
      },
    );
  }

  // Toggle status favorit untuk batch notes
  void _toggleFavoriteSelectedNotes(List<NoteModel> allNotes) async {
    final selectedNotes = allNotes.where((n) => _selectedNoteIds.contains(n.id)).toList();
    final allAreFavorites = selectedNotes.every((n) => n.isFavorite);
    await _noteService.setFavoriteBatch(_selectedNoteIds.toList(), !allAreFavorites);
    _exitNoteSelectionMode();
  }

  // Pindahkan notes ke folder lain
  void _moveSelectedNotes() {
    showMoveToDialog(
      context: context,
      noteService: _noteService,
      selectedNoteIds: _selectedNoteIds.toList(),
      onMoveConfirmed: (categoryId) async {
        await _noteService.moveNotesBatch(_selectedNoteIds.toList(), categoryId);
        _exitNoteSelectionMode();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes moved')));
      },
      onAddCategory: (name) async {
        await _noteService.addCategory(CategoryModel(id: '', name: name));
      },
    );
  }

  // Rename kategori (hanya bisa 1 item)
  void _renameSelectedCategory() {
    if (_selectedCategoryIds.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select exactly one category to edit')));
      return;
    }
    final catId = _selectedCategoryIds.first;
    final category = _currentCategoriesList.firstWhere((c) => c.id == catId, orElse: () => CategoryModel(id: '', name: ''));

    showDialog(
      context: context,
      builder: (ctx) => _RenameCategoryDialog(
        initialName: category.name,
        onSave: (newName) async {
          await _noteService.updateCategory(category.copyWith(name: newName));
          _exitCategorySelectionMode();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Renamed to "$newName"')));
        },
      ),
    );
  }

  // Hapus kategori terpilih
  void _deleteSelectedCategories() {
    if (_selectedCategoryIds.isEmpty) return;
    final count = _selectedCategoryIds.length;
    showIOSDialog(
      context: context,
      title: 'Delete Categories',
      message: 'Delete $count categories?\nNotes will be moved to "Uncategorized".',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        for (var id in _selectedCategoryIds) {
          await _noteService.deleteCategory(id);
        }
        _exitCategorySelectionMode();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Categories deleted')));
      },
    );
  }

  void _toggleFavoriteSelectedCategories() async {
    final selectedCats = _currentCategoriesList.where((c) => _selectedCategoryIds.contains(c.id));
    final allFav = selectedCats.every((c) => c.isFavorite);
    for (var cat in selectedCats) {
      if (cat.isFavorite == allFav) {
        await _noteService.toggleCategoryFavorite(cat.id, cat.isFavorite);
      }
    }
    _exitCategorySelectionMode();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => InputCategoryDialog(
        title: "New Note Folder",
        onSave: (name) async {
          await _noteService.addCategory(
            CategoryModel(id: '', name: name),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Folder "$name" added')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // PopScope menangani tombol back Android: Batalkan seleksi dulu sebelum keluar aplikasi
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        if (_isSelectionMode) {
          _exitNoteSelectionMode();
          return;
        }
        if (_isCategorySelectionMode) {
          _exitCategorySelectionMode();
          return;
        }
        if (_selectedTabIndex != 0) {
          setState(() => _selectedTabIndex = 0);
          return;
        }
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      // StreamBuilder bersarang untuk data realtime: Kategori -> Notes
      child: StreamBuilder<List<CategoryModel>>(
        stream: _noteService.getCategoriesStream(),
        builder: (context, snapshotCategories) {
          final allCategories = snapshotCategories.data ?? [];
          _currentCategoriesList = allCategories;

          return StreamBuilder<List<NoteModel>>(
            stream: _noteService.getNotesStream(),
            builder: (context, snapshotNotes) {
              final allNotes = snapshotNotes.data ?? [];
              final filteredNotes = _getFilteredNotes(allNotes);

              // Update List lokal untuk logika 'Select All' berdasarkan Tab aktif
              if (_selectedTabIndex == 0) {
                _currentNotesList = filteredNotes;
              } else if (_selectedTabIndex == 2) {
                _currentNotesList = filteredNotes.where((n) => n.isFavorite).toList();
              } else {
                _currentNotesList = [];
              }

              // Validasi status favorit untuk UI Action Bar
              final isCategoryFavorite = _currentCategoriesList
                  .where((c) => _selectedCategoryIds.contains(c.id))
                  .every((c) => c.isFavorite);

              final selectedNoteModels = allNotes.where((n) => _selectedNoteIds.contains(n.id)).toList();
              final isAllNotesFavorite = selectedNoteModels.isNotEmpty && selectedNoteModels.every((n) => n.isFavorite);

              // Daftar Tampilan Tab (All, Categories, Favorites)
              final List<Widget> tabViews = [
                AllNotesTab(
                  notes: filteredNotes,
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
                CategoriesTab(
                  noteService: _noteService,
                  categories: allCategories,
                  allNotes: allNotes,
                  onNoteSelected: (id) => Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: id),
                  isNoteSelectionMode: _isSelectionMode,
                  selectedNoteIds: _selectedNoteIds,
                  onNoteTap: _toggleSelection,
                  onNoteLongPress: _enterSelectionMode,
                  isCategorySelectionMode: _isCategorySelectionMode,
                  selectedCategoryIds: _selectedCategoryIds,
                  onCategoryTap: _toggleCategorySelection,
                  onCategoryLongPress: _enterCategorySelectionMode,
                ),
                FavoritesTab(
                  notes: filteredNotes.where((n) => n.isFavorite).toList(),
                  favoriteCategories: allCategories.where((c) => c.isFavorite).toList(),
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
                  isCategorySelectionMode: _isCategorySelectionMode,
                  selectedCategoryIds: _selectedCategoryIds,
                  onCategoryTap: _toggleCategorySelection,
                  onCategoryLongPress: _enterCategorySelectionMode,
                  searchQuery: _searchQuery,
                ),
              ];

              return Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: false,
                appBar: CustomTopAppBar(
                  isSelectionMode: _isSelectionMode || _isCategorySelectionMode,
                  onSelectAllTap: _selectAll,
                  onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notification),
                ),
                body: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SafeArea(
                    bottom: false,
                    child: isPortrait
                    // Layout Portrait: Header statis, konten Expanded
                        ? Column(
                      children: [
                        NoteSearchBar(
                          controller: _searchController,
                          onClear: () => setState(() => _searchController.clear()),
                        ),
                        NoteTabBar(
                          selectedIndex: _selectedTabIndex,
                          onTabSelected: _onTabChanged,
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedTabIndex,
                            children: tabViews,
                          ),
                        ),
                      ],
                    )
                    // Layout Landscape: Header ikut scroll (NestedScrollView)
                        : NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NoteSearchBar(
                                  controller: _searchController,
                                  onClear: () => setState(() => _searchController.clear()),
                                ),
                                NoteTabBar(
                                  selectedIndex: _selectedTabIndex,
                                  onTabSelected: _onTabChanged,
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                      body: IndexedStack(
                        index: _selectedTabIndex,
                        children: tabViews,
                      ),
                    ),
                  ),
                ),
                // FAB disembunyikan saat mode seleksi aktif
                floatingActionButton: (_isSelectionMode || _isCategorySelectionMode)
                    ? null
                    : GlobalExpandableFab(
                  actions: [
                    FabActionModel(icon: Icons.edit_outlined, tooltip: 'Add Note', onTap: () => Navigator.pushNamed(context, AppRoutes.noteEditor)),
                    FabActionModel(icon: Icons.folder, tooltip: 'Add Category', onTap: _showAddCategoryDialog),
                  ],
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                bottomNavigationBar: _buildBottomNavBar(isAllNotesFavorite, allNotes, isCategoryFavorite),
              );
            },
          );
        },
      ),
    );
  }

  // Builder Bottom Nav: Menentukan apakah menampilkan navigasi utama atau menu aksi (move, delete, dll)
  Widget _buildBottomNavBar(bool isAllNotesFavorite, List<NoteModel> allNotes, bool isCategoryFavorite) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen) return const SizedBox.shrink();
    if (!_isNavBarVisible) return const SizedBox.shrink();

    if (_isCategorySelectionMode) {
      return SafeArea(
        child: CategorySelectionActionBar(
          onEdit: _renameSelectedCategory,
          onFavorite: _toggleFavoriteSelectedCategories,
          onDelete: _deleteSelectedCategories,
          isSelectedFavorite: isCategoryFavorite,
        ),
      );
    }

    if (_isSelectionMode) {
      return SafeArea(
        child: SelectionActionBar(
          onMove: _moveSelectedNotes,
          onFavorite: () => _toggleFavoriteSelectedNotes(allNotes),
          onDelete: _deleteSelectedNotes,
          isAllSelectedFavorite: isAllNotesFavorite,
        ),
      );
    }

    return CustomNavBar(
      selectedIndex: 1,
      onItemTapped: _handleNavigation,
    );
  }

  // Filter notes berdasarkan search query (judul atau isi)
  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;
    final query = _searchQuery.toLowerCase();
    return notes.where((note) => note.title.toLowerCase().contains(query) || note.content.toLowerCase().contains(query)).toList();
  }
}

// Widget Dialog untuk Rename Kategori (Internal)
class _RenameCategoryDialog extends StatefulWidget {
  final String initialName;
  final Function(String) onSave;
  const _RenameCategoryDialog({required this.initialName, required this.onSave});
  @override
  State<_RenameCategoryDialog> createState() => _RenameCategoryDialogState();
}

class _RenameCategoryDialogState extends State<_RenameCategoryDialog> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    // Auto-focus field saat dialog muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _controller.text.trim();
    if (name.isEmpty || name == widget.initialName) { Navigator.pop(context); return; }
    setState(() => _isLoading = true);
    await widget.onSave(name);
  }

  @override
  Widget build(BuildContext context) {
    return IOSDialog(
      title: 'Rename Category',
      confirmText: 'Save',
      cancelText: 'Cancel',
      confirmTextColor: const Color(0xFF007AFF),
      isLoading: _isLoading,
      autoDismiss: false,
      onConfirm: _handleSave,
      onCancel: () => _focusNode.unfocus(),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF007AFF)),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Category Name',
            hintStyle: GoogleFonts.poppins(color: const Color(0xFFC7C7CC), fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onSubmitted: (_) => _handleSave(),
        ),
      ),
    );
  }
}