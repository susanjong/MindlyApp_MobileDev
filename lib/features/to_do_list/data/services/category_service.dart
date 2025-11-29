import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _categoriesCollection {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).collection('categories');
  }

  // Stream semua kategori
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Tambah Kategori
  Future<void> addCategory(String name, int gradientIndex) async {
    await _categoriesCollection.add({
      'name': name,
      'gradientIndex': gradientIndex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}