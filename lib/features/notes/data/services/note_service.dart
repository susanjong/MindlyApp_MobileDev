import '../models/category_model.dart';
import '../models/note_model.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

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
      content: '1. Reply to emails\n2. Prepare presentation slides\n3. Conduct research on competitor products',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      categoryId: '1',
      color: 0xFFE6C4DD,
    ),
    NoteModel(
      id: 'n2',
      title: 'Review Program',
      content: 'The program highlighted demographic and economic developments in the region.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      categoryId: '1',
      color: 0xFFCFE6AF,
    ),
    NoteModel(
      id: 'n3',
      title: 'New Product Idea',
      content: 'Create a mobile app UI Kit that provides basic notes functionality with improvements.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      categoryId: '3',
      color: 0xFFB4D7F8,
      isFavorite: true,
    ),
    NoteModel(
      id: 'n4',
      title: 'Bunni Executor',
      content: 'Thanks for downloading Bunni. Our team is constantly working to bring you a smooth experience.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: '2',
      color: 0xFFE4BA9B,
    ),
    NoteModel(
      id: 'n5',
      title: 'Volunteer',
      content: 'Recruiting students, around 80 people, and they will be selected for fully funded program.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      categoryId: '2',
      color: 0xFFFFBEBE,
    ),
    NoteModel(
      id: 'n6',
      title: 'Clustering Research',
      content: 'This research developed an optimal clustering model for analyzing household electricity patterns.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      categoryId: '3',
      color: 0xFFF4FFBE,
      isFavorite: true,
    ),
  ];

  // === Getters ===

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<NoteModel> get allNotes => List.unmodifiable(_notes);
  List<NoteModel> get favoriteNotes => _notes.where((n) => n.isFavorite).toList();

  // === Note Operations ===

  List<NoteModel> getNotesByCategory(String categoryId) {
    if (categoryId == 'all') return allNotes;
    return _notes.where((n) => n.categoryId == categoryId).toList();
  }

  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return allNotes;
    final q = query.toLowerCase();
    return _notes.where((n) =>
    n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q)
    ).toList();
  }

  NoteModel? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  void addNote(NoteModel note) {
    _notes.insert(0, note);
  }

  void updateNote(NoteModel note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
  }

  void toggleFavorite(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isFavorite: !_notes[index].isFavorite,
      );
    }
  }

  void moveNoteToCategory(String noteId, String categoryId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(categoryId: categoryId);
    }
  }

  // === Category Operations ===

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCategory(CategoryModel category) {
    _categories.add(category);
  }

  void updateCategory(CategoryModel category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  void deleteCategory(String id) {
    // Move all notes in this category to 'all'
    for (var i = 0; i < _notes.length; i++) {
      if (_notes[i].categoryId == id) {
        _notes[i] = _notes[i].copyWith(categoryId: 'all');
      }
    }
    _categories.removeWhere((c) => c.id == id);
  }

  void toggleCategoryFavorite(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        isFavorite: !_categories[index].isFavorite,
      );
    }
  }
}