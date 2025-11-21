import '../../presentation/widgets/categories_tab.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  // Dummy data
  final List<CategoryModel> _categories = [
    CategoryModel(id: 'all', name: 'All'),
    CategoryModel(id: '1', name: 'Work'),
    CategoryModel(id: '2', name: 'Personal'),
    CategoryModel(id: '3', name: 'Ideas'),
  ];

  final List<NoteModel> _notes = [
    NoteModel(
      id: 'n1',
      title: 'To-do list',
      content: '1. Reply to emails\n2. Prepare presentation slides for the marketing meeting\n3. Conduct research on competitor products\n4. Reply to emails',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      categoryId: '1',
      color: 0xFFE6C4DD,
    ),
    NoteModel(
      id: 'n2',
      title: 'Review Program',
      content: 'The program highlighted demographic and economic developments in the region, with projections of continued population growth.\n\nIt also addressed recent border tensions between',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      categoryId: '1',
      color: 0xFFCFE6AF,
    ),
    NoteModel(
      id: 'n3',
      title: 'New Product Idea',
      content: 'Create a mobile app UI Kit that provide a basic notes functionality but with some improvement.\n\nThere will be a choice to select what kind of notes that user needed, so the',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      categoryId: '3',
      color: 0xFFB4D7F8,
      isFavorite: true,
    ),
    NoteModel(
      id: 'n4',
      title: 'Bunni Executor',
      content: 'Thanks for downloading Bunni,\nOur team is constantly working to bring you a smooth, clean, and malware-free experience.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: '2',
      color: 0xFFE4BA9B,
    ),
    NoteModel(
      id: 'n5',
      title: 'Volunteer',
      content: 'Merekrut mahasiswa dan mahasiswi usu, sekitar 80 orang, dan nanti untuk mahasiswa mahasiswi ini akan diseleksi, untuk fully funded, dan dibuka dalam waktu dekat ini.\n\nFully funded hanya beberapa orang saja.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      categoryId: '2',
      color: 0xFFFFBEBE,
    ),
    NoteModel(
      id: 'n6',
      title: 'Clustering',
      content: 'This research successfully developed an optimal clustering model for analyzing household electricity consumption patterns using a combination of RobustScaler and PCA (90% retained variance).',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      categoryId: '3',
      color: 0xFFF4FFBE,
      isFavorite: true,
    ),
  ];

  // Getters
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<NoteModel> get allNotes => List.unmodifiable(_notes);

  // Get notes by category
  List<NoteModel> getNotesByCategory(String categoryId) {
    if (categoryId == 'all') {
      return allNotes;
    }
    return _notes.where((note) => note.categoryId == categoryId).toList();
  }

  // Get favorite notes
  List<NoteModel> get favoriteNotes {
    return _notes.where((note) => note.isFavorite).toList();
  }

  // Search notes
  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return allNotes;

    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Add note
  void addNote(NoteModel note) {
    _notes.insert(0, note);
  }

  // Update note
  void updateNote(NoteModel note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
    }
  }

  // Delete note
  void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
  }

  // Toggle favorite
  void toggleFavorite(String noteId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isFavorite: !_notes[index].isFavorite,
      );
    }
  }

  // Move note to category
  void moveNoteToCategory(String noteId, String categoryId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(categoryId: categoryId);
    }
  }

  // Category management
  void addCategory(CategoryModel category) {
    _categories.add(category);
  }

  void updateCategory(CategoryModel category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  void deleteCategory(String categoryId) {
    // Move notes from deleted category to "All"
    for (var note in _notes) {
      if (note.categoryId == categoryId) {
        moveNoteToCategory(note.id, 'all');
      }
    }
    _categories.removeWhere((c) => c.id == categoryId);
  }

  void toggleCategoryFavorite(String categoryId) {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        isFavorite: !_categories[index].isFavorite,
      );
    }
  }

  // Get note by ID
  NoteModel? getNoteById(String noteId) {
    try {
      return _notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  // Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}