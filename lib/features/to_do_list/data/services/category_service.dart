import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Koleksi kategori user
  CollectionReference get _categoriesCollection {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).collection('categories');
  }

  // Koleksi todos user
  CollectionReference get _todosCollection {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).collection('todos');
  }

  /// STREAM kategori
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// CREATE kategori
  Future<void> addCategory(String name, int gradientIndex) async {
    await _categoriesCollection.add({
      'name': name,
      'gradientIndex': gradientIndex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// NEW DELETE CATEGORY (Move todos → "Uncategorized", then delete)
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Ambil semua todo dalam kategori ini
      final tasksSnapshot = await _todosCollection
          .where('category', isEqualTo: categoryId)
          .get();

      final batch = _firestore.batch();

      // Update setiap todo → set ke kategori 'Uncategorized'
      for (var doc in tasksSnapshot.docs) {
        batch.update(doc.reference, {'category': 'Uncategorized'});
      }

      // Hapus kategori
      batch.delete(_categoriesCollection.doc(categoryId));

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }
}
