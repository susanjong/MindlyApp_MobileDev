import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart'; // Pastikan path import model ini benar

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper untuk mendapatkan referensi koleksi kategori user yang sedang login
  CollectionReference get _categoriesCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    // Path: users/{uid}/categories
    return _firestore.collection('users').doc(user.uid).collection('categories');
  }

  // 1. READ: Mengambil Data Kategori secara Realtime (Stream)
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCollection
        .orderBy('createdAt', descending: false) // Opsional: urutkan berdasarkan waktu buat
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 2. CREATE: Tambah Kategori Baru
  Future<void> addCategory(String name, int gradientIndex) async {
    await _categoriesCollection.add({
      'name': name,
      'gradientIndex': gradientIndex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. DELETE: Hapus Kategori (Opsional, jika dibutuhkan nanti)
  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
  }
}