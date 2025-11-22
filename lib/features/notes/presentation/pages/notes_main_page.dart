import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Service
  final NoteService _noteService = NoteService();

  // State
  bool _isNavBarVisible = true;
  int _selectedTabIndex = 0;
  String _searchQuery = '';

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

  // === Event Handlers ===

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
    setState(() => _selectedTabIndex = index);
  }

  void _handleNavigation(int index) {
    final routes = ['/home', '/notes', '/todo', '/calendar'];
    if (index != 1) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  void _handleAddNote() {
    Navigator.pushNamed(context, '/note-editor').then((_) {
      if (mounted) setState(() {});
    });
  }

  void _handleAddCategory() {
    _showCategoryDialog();
  }

  void _handleNoteSelected(String noteId) {
    Navigator.pushNamed(context, '/note-editor', arguments: noteId).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _refreshData() {
    setState(() {});
  }

  // === Dialogs ===

  void _showCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _noteService.addCategory(CategoryModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                ));
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // === Build Methods ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopAppBar(
        onProfileTap: () => Navigator.pushNamed(context, '/profile'),
        onNotificationTap: () {},
      ),
      body: Column(
        children: [
          // Search Bar with Greeting
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
      floatingActionButton: NotesExpandableFab(
        onAddNoteTap: _handleAddNote,
        onAddCategoryTap: _handleAddCategory,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTabContent() {
    // Menggunakan IndexedStack agar state setiap tab tetap terjaga
    // dan perpindahan tab menjadi instant tanpa rebuild
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        // Tab 0: All Notes
        AllNotesTab(
          notes: _getFilteredNotes(_noteService.allNotes),
          scrollController: _scrollController,
          onNoteSelected: _handleNoteSelected,
          searchQuery: _searchQuery,
        ),

        // Tab 1: Categories
        CategoriesTab(
          noteService: _noteService,
          onNoteSelected: _handleNoteSelected,
          onRefresh: _refreshData,
        ),

        // Tab 2: Favorites
        FavoritesTab(
          notes: _getFilteredNotes(_noteService.favoriteNotes),
          scrollController: _scrollController,
          onNoteSelected: _handleNoteSelected,
          searchQuery: _searchQuery,
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _isNavBarVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isNavBarVisible ? 1.0 : 0.0,
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: 1, // Notes tab
            onItemTapped: _handleNavigation,
          ),
        ),
      ),
    );
  }

  // === Helper Methods ===

  List<NoteModel> _getFilteredNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;

    final query = _searchQuery.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }
}