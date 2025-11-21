import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notesapp/core/widgets/navigation/custom_navbar_widget.dart';
import 'package:notesapp/core/widgets/navigation/custom_top_app_bar.dart';
import '../../data/models/note_model.dart';
import '../../data/services/notes_service.dart';
import '../widgets/expandable_fab.dart';
import '../widgets/note_card.dart';
import '../widgets/notes_tab.dart';
import '../widgets/categories_tab.dart'; // Import Categories Tab

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  bool _isNavBarVisible = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final NoteService _noteService = NoteService();

  int _selectedTabIndex = 0;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) {
        setState(() => _isNavBarVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() => _isNavBarVisible = true);
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
      // Already on Notes page
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/todo');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/calendar');
        break;
    }
  }

  void _handleAddNote() {
    Navigator.pushNamed(context, '/add-note');
  }

  void _handleAddFolder() {
    // TODO: Implement add folder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add folder feature coming soon')),
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _tabController.animateTo(index);
    });
  }

  List<NoteModel> _getFilteredNotes() {
    List<NoteModel> notes;

    switch (_selectedTabIndex) {
      case 0: // All Notes
        notes = _noteService.allNotes;
        break;
      case 2: // Favorite
        notes = _noteService.favoriteNotes;
        break;
      default:
        notes = _noteService.allNotes;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      return _noteService.searchNotes(_searchQuery);
    }

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopAppBar(
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        onNotificationTap: () {
          // TODO: Navigate to notifications
        },
      ),
      body: Column(
        children: [
          _buildGreetingAndSearch(),
          NotesTabBar(
            selectedIndex: _selectedTabIndex,
            onTabSelected: _onTabSelected,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildNotesGrid(), // All Notes
                CategoriesTab(noteService: _noteService), // Categories
                _buildNotesGrid(), // Favorite
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        onAddNoteTap: _handleAddNote,
        onAddFolderTap: _handleAddFolder,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isNavBarVisible ? null : 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isNavBarVisible ? 1.0 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomNavBar(
                selectedIndex: 1,
                onItemTapped: _navigateToPage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingAndSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21.5, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hello Susan Jong. How are you today!',
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.28,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF6A6E76), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(
                        color: Color(0xFF6A6E76),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: const Icon(
                      Icons.clear,
                      color: Color(0xFF6A6E76),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    final notes = _getFilteredNotes();

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.note_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No notes found for "$_searchQuery"'
                  : _selectedTabIndex == 2
                  ? 'No favorite notes yet'
                  : 'No notes yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 170 / 201.90,
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
          onTap: () {
            Navigator.pushNamed(
              context,
              '/edit-note',
              arguments: note.id,
            );
          },
        );
      },
    );
  }
}