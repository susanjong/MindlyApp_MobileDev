import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<int> noteColors = [
    0xFFE6C4DE, 0xFFCFE6AF, 0xFFB5D8F9, 0xFFE4BA9B,
    0xFFFFBEBE, 0xFFF4FFBE, 0xFFBEFFE2,
  ];

  int getColorForNote(String noteId) {
    final hash = noteId.hashCode.abs();
    return noteColors[hash % noteColors.length];
  }

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

    // ✅ Stream untuk Bookmarks favorite status dari Firestore
    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .asyncMap((userDoc) async {
      // Ambil categories dari subcollection
      final categoriesSnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('categories')
          .get();

      var cats = categoriesSnapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();

      // ✅ Get bookmarks favorite status dari user document
      final userData = userDoc.data();
      final isBookmarksFavorite = userData?['bookmarksFavorite'] ?? false;

      // Add virtual categories
      if (!cats.any((c) => c.id == 'all')) {
        cats.insert(0, CategoryModel(id: 'all', name: 'All'));
      }

      // ✅ Bookmarks dengan favorite status dari Firestore
      if (!cats.any((c) => c.id == 'bookmarks')) {
        cats.insert(1, CategoryModel(
          id: 'bookmarks',
          name: 'Bookmarks',
          isFavorite: isBookmarksFavorite,
        ));
      } else {
        // Update existing bookmarks category
        final bookmarksIndex = cats.indexWhere((c) => c.id == 'bookmarks');
        if (bookmarksIndex != -1) {
          cats[bookmarksIndex] = cats[bookmarksIndex].copyWith(
            isFavorite: isBookmarksFavorite,
          );
        }
      }

      return cats;
    });
  }

  // === NOTE OPERATIONS ===

  Future<void> addNote(NoteModel note) async {
    if (_uid == null) return;
    final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc();
    final noteWithIdAndColor = note.copyWith(
      id: docRef.id,
      color: getColorForNote(docRef.id),
    );
    await docRef.set(noteWithIdAndColor.toMap());
  }

  // ✅ FIX: Update note tanpa mengubah warna
  Future<void> updateNote(NoteModel note) async {
    if (_uid == null) return;

    // Ambil warna lama dari Firestore
    final existingDoc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(note.id)
        .get();

    final existingColor = existingDoc.data()?['color'] ?? note.color;

    // Update dengan warna yang sama
    final noteMap = note.toMap();
    noteMap['color'] = existingColor; // ✅ Pertahankan warna lama

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(note.id)
        .update(noteMap);
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

  Future<void> toggleBookmark(String noteId, bool currentStatus) async {
    if (_uid == null) return;
    final newCategoryId = currentStatus ? 'all' : 'bookmarks';
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .update({'categoryId': newCategoryId});
  }

  Future<void> deleteNotesBatch(List<String> noteIds) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
  }

  Future<void> setFavoriteBatch(List<String> noteIds, bool isFavorite) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.update(docRef, {'isFavorite': isFavorite});
    }
    await batch.commit();
  }

  Future<void> moveNotesBatch(List<String> noteIds, String categoryId) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
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

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .doc(categoryId)
        .delete();

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

  // ✅ FIXED: Toggle category favorite - handle Bookmarks
  Future<void> toggleCategoryFavorite(String categoryId, bool currentStatus) async {
    if (_uid == null) return;

    if (categoryId == 'bookmarks') {
      // ✅ Store Bookmarks favorite status di user document
      await _firestore
          .collection('users')
          .doc(_uid)
          .set({
        'bookmarksFavorite': !currentStatus,
      }, SetOptions(merge: true));
    } else {
      // Regular categories
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('categories')
          .doc(categoryId)
          .update({'isFavorite': !currentStatus});
    }
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
      if (kDebugMode) {
        print("Error getting note: $e");
      }
      return null;
    }
  }
}