import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notesapp/widgets/custom_navbar_widget.dart';
import 'package:notesapp/widgets/custom_top_app_bar.dart';
import '../../../widgets/colors.dart';
import '../../../widgets/expandable_fab.dart';
import '../../../widgets/note_card.dart';
import '../../../widgets/notes_tab.dart';
import 'categories_tab.dart'; // Import Categories Tab

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _isNavBarVisible = true;
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0; // 0: All Notes, 1: Categories, 2: Favorite

  // Data dummy untuk notes
  final List<Map<String, dynamic>> notes = [
    {
      'title': 'To-do list',
      'content': '1. Reply to emails\n2. Prepare presentation slides for the marketing meeting\n3. Conduct research on competitor products\n4. Reply to emails',
      'date': 'September 30, 2025',
      'color': Color(0xFFE6C4DD),
    },
    {
      'title': 'Review Program',
      'content': 'The program highlighted demographic and economic developments in the region, with projections of continued population growth.\n\nIt also addressed recent border tensions between',
      'date': 'September 30, 2025',
      'color': Color(0xFFCFE6AF),
    },
    {
      'title': 'New Product Idea',
      'content': 'Create a mobile app UI Kit that provide a basic notes functionality but with some improvement.\n\nThere will be a choice to select what kind of notes that user needed, so the',
      'date': 'September 30, 2025',
      'color': Color(0xFFB4D7F8),
    },
    {
      'title': 'Bunni Executor',
      'content': 'Thanks for downloading Bunni,\nOur team is constantly working to bring you a smooth, clean, and malware-free experience.',
      'date': 'September 30, 2025',
      'color': Color(0xFFE4BA9B),
    },
    {
      'title': 'Volunteer',
      'content': 'Merekrut mahasiswa dan mahasiswi usu, sekitar 80 orang, dan nanti untuk mahasiswa mahasiswi ini akan diseleksi, untuk fully funded, dan dibuka dalam waktu dekat ini.\n\nFully funded hanya beberapa orang saja.',
      'date': 'September 30, 2025',
      'color': Color(0xFFFFBEBE),
    },
    {
      'title': 'Clustering',
      'content': 'This research successfully developed an optimal clustering model for analyzing household electricity consumption patterns using a combination of RobustScaler and PCA (90% retained variance).',
      'date': 'September 30, 2025',
      'color': Color(0xFFF4FFBE),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
        });
      }
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
    Navigator.pushNamed(context, '/add-folder');
  }

  // ✅ HANDLER untuk tab selection
  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTopAppBar(
        onProfileTap: () {
          // TODO: Navigate to profile
        },
        onNotificationTap: () {
          // TODO: Show notifications
        },
      ),
      body: Column(
        children: [
          // Greeting & Search Bar
          _buildGreetingAndSearch(),

          // ✅ Tab Bar - Gunakan NotesTabBar widget dengan callback
          NotesTabBar(
            selectedIndex: _selectedTabIndex,
            onTabSelected: _onTabSelected, // Pass callback
          ),

          // ✅ Content based on selected tab
          Expanded(
            child: _buildTabContent(),
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
                    decoration: const InputDecoration(
                      hintText: 'Search',
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
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ KUNCI: Method untuk render konten berdasarkan tab
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildNotesGrid(); // All Notes
      case 1:
        return const CategoriesTab(); // Categories ✅✅✅
      case 2:
        return _buildFavoriteGrid(); // Favorite
      default:
        return _buildNotesGrid();
    }
  }

  Widget _buildNotesGrid() {
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
        return NoteCard(
          title: notes[index]['title'],
          content: notes[index]['content'],
          date: notes[index]['date'],
          color: notes[index]['color'],
        );
      },
    );
  }

  Widget _buildFavoriteGrid() {
    // Filter notes yang favorite
    final favoriteNotes = notes.where((note) {
      // TODO: Add isFavorite property to your notes model
      return true; // Temporary: show all notes
    }).toList();

    if (favoriteNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No favorite notes yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
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
      itemCount: favoriteNotes.length,
      itemBuilder: (context, index) {
        return NoteCard(
          title: favoriteNotes[index]['title'],
          content: favoriteNotes[index]['content'],
          date: favoriteNotes[index]['date'],
          color: favoriteNotes[index]['color'],
        );
      },
    );
  }
}