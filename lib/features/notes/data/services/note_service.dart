import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🎨 7 Warna Notes (sesuai requirement)
  static const List<int> noteColors = [
    0xFFE6C4DE, // 1. Pink pastel
    0xFFCFE6AF, // 2. Green pastel
    0xFFB5D8F9, // 3. Blue pastel
    0xFFE4BA9B, // 4. Orange pastel
    0xFFFFBEBE, // 5. Red pastel
    0xFFF4FFBE, // 6. Yellow pastel
    0xFFBEFFE2, // 7. Mint pastel
  ];

  // ✅ FIX: Warna berdasarkan ID note agar konsisten
  int getColorForNote(String noteId) {
    // Gunakan hashCode dari noteId untuk mendapat warna yang konsisten
    final hash = noteId.hashCode.abs();
    return noteColors[hash % noteColors.length];
  }

  // Helper to get current User UID
  String? get _uid => _auth.currentUser?.uid;

  // === REAL-TIME STREAMS ===

  Stream<List<NoteModel>> getNotesStream() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      var cats = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();

      // ✅ Ensure 'All' and 'Bookmarks' exist virtually
      if (!cats.any((c) => c.id == 'all')) {
        cats.insert(0, CategoryModel(id: 'all', name: 'All'));
      }

      // ✅ Bookmarks category (paling atas setelah All)
      if (!cats.any((c) => c.id == 'bookmarks')) {
        cats.insert(1, CategoryModel(id: 'bookmarks', name: 'Bookmarks'));
      }

      return cats;
    });
  }

  // === NOTE OPERATIONS ===

  Future<void> addNote(NoteModel note) async {
    if (_uid == null) return;

    final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc();

    // ✅ Assign warna berdasarkan ID (konsisten)
    final noteWithIdAndColor = note.copyWith(
      id: docRef.id,
      color: getColorForNote(docRef.id),
    );

    await docRef.set(noteWithIdAndColor.toMap());
  }

  Future<void> updateNote(NoteModel note) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  Future<void> toggleFavorite(String noteId, bool currentStatus) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .update({'isFavorite': !currentStatus});
  }

  // ✅ Toggle Bookmark
  Future<void> toggleBookmark(String noteId, bool currentStatus) async {
    if (_uid == null) return;

    // Update categoryId: jika sudah bookmark → pindah ke 'all', jika belum → pindah ke 'bookmarks'
    final newCategoryId = currentStatus ? 'all' : 'bookmarks';

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .update({'categoryId': newCategoryId});
  }

  // Batch Operations for Selection Mode
  Future<void> deleteNotesBatch(List<String> noteIds) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef =
      _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
  }

  Future<void> setFavoriteBatch(List<String> noteIds, bool isFavorite) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef =
      _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.update(docRef, {'isFavorite': isFavorite});
    }
    await batch.commit();
  }

  Future<void> moveNotesBatch(List<String> noteIds, String categoryId) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef =
      _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.update(docRef, {'categoryId': categoryId});
    }
    await batch.commit();
  }

  // === CATEGORY OPERATIONS ===

  Future<void> addCategory(CategoryModel category) async {
    if (_uid == null) return;
    final docRef = _firestore.collection('users').doc(_uid).collection('categories').doc();
    await docRef.set(category.copyWith(id: docRef.id).toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_uid == null) return;

    // 1. Delete the category
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .doc(categoryId)
        .delete();

    // 2. Move associated notes to 'all'
    final notesSnapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    final batch = _firestore.batch();
    for (var doc in notesSnapshot.docs) {
      batch.update(doc.reference, {'categoryId': 'all'});
    }
    await batch.commit();
  }

  Future<void> toggleCategoryFavorite(String categoryId, bool currentStatus) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .doc(categoryId)
        .update({'isFavorite': !currentStatus});
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    if (_uid == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('notes')
          .doc(noteId)
          .get();

      if (doc.exists && doc.data() != null) {
        return NoteModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error getting note: $e");
      return null;
    }
  }
}