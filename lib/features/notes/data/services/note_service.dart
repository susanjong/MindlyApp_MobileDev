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

    // HANYA ambil kategori yang dibuat user dari Firestore
    // Tidak ada lagi injeksi 'All' atau 'Bookmarks'
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('categories')
        .orderBy('name', descending: false) // Urutkan sesuai nama
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // === NOTE OPERATIONS ===

  Future<void> addNote(NoteModel note) async {
    if (_uid == null) return;
    final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc();

    // Pastikan categoryId tidak null/kosong, default ke string kosong jika tidak ada kategori
    final safeCategoryId = (note.categoryId == 'all' || note.categoryId == 'bookmarks')
        ? ''
        : note.categoryId;

    final noteWithIdAndColor = note.copyWith(
      id: docRef.id,
      color: getColorForNote(docRef.id),
      categoryId: safeCategoryId,
    );
    await docRef.set(noteWithIdAndColor.toMap());
  }

  Future<void> updateNote(NoteModel note) async {
    if (_uid == null) return;

    // Ambil warna lama agar tidak berubah
    final existingDoc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(note.id)
        .get();

    final existingColor = existingDoc.data()?['color'] ?? note.color;

    // Bersihkan categoryId jika masih ada sisa 'bookmarks' atau 'all' dari data lama
    String cleanCategoryId = note.categoryId;
    if (cleanCategoryId == 'all' || cleanCategoryId == 'bookmarks') {
      cleanCategoryId = '';
    }

    final noteMap = note.toMap();
    noteMap['color'] = existingColor;
    noteMap['categoryId'] = cleanCategoryId;

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

  // Logic Favorite Sederhana - Langsung update boolean
  Future<void> toggleFavorite(String noteId, bool currentStatus) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .update({'isFavorite': !currentStatus});
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

    // Pastikan tidak memindahkan ke 'all' atau 'bookmarks' secara tidak sengaja
    final safeCategory = (categoryId == 'all' || categoryId == 'bookmarks') ? '' : categoryId;

    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.update(docRef, {'categoryId': safeCategory});
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

    // Reset notes yang ada di kategori ini menjadi uncategorized ('')
    final notesSnapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    final batch = _firestore.batch();
    for (var doc in notesSnapshot.docs) {
      batch.update(doc.reference, {'categoryId': ''});
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
      if (kDebugMode) {
        print("Error getting note: $e");
      }
      return null;
    }
  }
}