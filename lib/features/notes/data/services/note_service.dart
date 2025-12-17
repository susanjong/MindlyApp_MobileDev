import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Daftar warna statis untuk background note
  static const List<int> noteColors = [
    0xFFE6C4DE, 0xFFCFE6AF, 0xFFB5D8F9, 0xFFE4BA9B,
    0xFFFFBEBE, 0xFFF4FFBE, 0xFFBEFFE2,
  ];

  // Menentukan warna note berdasarkan hash ID agar konsisten
  int getColorForNote(String noteId) {
    final hash = noteId.hashCode.abs();
    return noteColors[hash % noteColors.length];
  }

  // Getter untuk mengambil UID user yang sedang login
  String? get _uid => _auth.currentUser?.uid;

  // === REAL-TIME STREAMS ===

  // Stream daftar note, diurutkan berdasarkan update terakhir
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

  // Stream daftar kategori note
  Stream<List<CategoryModel>> getCategoriesStream() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('note_categories')
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // === NOTE OPERATIONS ===

  // Menambah note baru dengan warna otomatis dan sanitasi kategori
  Future<void> addNote(NoteModel note) async {
    if (_uid == null) return;
    final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc();

    // Normalisasi: ubah filter sistem ('all'/'bookmarks') menjadi kategori kosong
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

  // Memperbarui note yang ada
  Future<void> updateNote(NoteModel note) async {
    if (_uid == null) return;

    // Ambil data lama untuk mempertahankan warna background
    final existingDoc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(note.id)
        .get();

    final existingColor = existingDoc.data()?['color'] ?? note.color;

    // Normalisasi kategori agar tidak menyimpan ID filter sistem
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

  // Menghapus satu note berdasarkan ID
  Future<void> deleteNote(String noteId) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // Mengubah status favorit (toggle true/false)
  Future<void> toggleFavorite(String noteId, bool currentStatus) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .doc(noteId)
        .update({'isFavorite': !currentStatus});
  }

  // Menghapus banyak note sekaligus (Batch Operation)
  Future<void> deleteNotesBatch(List<String> noteIds) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
  }

  // Mengubah status favorit banyak note sekaligus
  Future<void> setFavoriteBatch(List<String> noteIds, bool isFavorite) async {
    if (_uid == null) return;
    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.update(docRef, {'isFavorite': isFavorite});
    }
    await batch.commit();
  }

  // Memindahkan banyak note ke kategori tertentu
  Future<void> moveNotesBatch(List<String> noteIds, String categoryId) async {
    if (_uid == null) return;

    final safeCategory = (categoryId == 'all' || categoryId == 'bookmarks') ? '' : categoryId;

    final batch = _firestore.batch();
    for (var id in noteIds) {
      final docRef = _firestore.collection('users').doc(_uid).collection('notes').doc(id);
      batch.update(docRef, {'categoryId': safeCategory});
    }
    await batch.commit();
  }

  // === CATEGORY OPERATIONS ===

  // Menambah kategori baru
  Future<void> addCategory(CategoryModel category) async {
    if (_uid == null) return;
    final docRef = _firestore.collection('users').doc(_uid).collection('note_categories').doc();
    await docRef.set(category.copyWith(id: docRef.id).toMap());
  }

  // Memperbarui nama atau data kategori
  Future<void> updateCategory(CategoryModel category) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('note_categories')
        .doc(category.id)
        .update(category.toMap());
  }

  // Menghapus kategori dan mereset notes di dalamnya menjadi tanpa kategori
  Future<void> deleteCategory(String categoryId) async {
    if (_uid == null) return;

    // 1. Hapus dokumen kategori
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('note_categories')
        .doc(categoryId)
        .delete();

    // 2. Cari semua note yang ada di kategori ini
    final notesSnapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notes')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    // 3. Update note tersebut agar tidak memiliki kategori (uncategorized)
    final batch = _firestore.batch();
    for (var doc in notesSnapshot.docs) {
      batch.update(doc.reference, {'categoryId': ''});
    }
    await batch.commit();
  }

  // Toggle status favorit kategori
  Future<void> toggleCategoryFavorite(String categoryId, bool currentStatus) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('note_categories')
        .doc(categoryId)
        .update({'isFavorite': !currentStatus});
  }

  // Mengambil satu note spesifik (untuk keperluan edit)
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