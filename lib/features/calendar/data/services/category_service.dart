import 'package:cloud_firestore/cloud_firestore.dart';

// Model data untuk Kategori Event
class Category {
  final String? id;
  final String name;
  final String color;
  final String userId;

  Category({
    this.id,
    required this.name,
    required this.color,
    required this.userId,
  });

  // Mengubah object menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'userId': userId,
    };
  }

  // Membuat object Category dari data Firestore (Map)
  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? '#5683EB', // Default warna jika null
      userId: map['userId'] ?? '',
    );
  }
}

class EventCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Palet warna statis untuk kategori
  static const List<int> _categoryColors = [
    0xFFFBAE38, 0xFFBEE973, 0xFF5784EB, 0xFFD732A8,
    0xFFAB5CFF, 0xFF00A89D, 0xFF009B7D, 0xFFBEE973,
  ];

  // Helper: Mendapatkan referensi koleksi kategori milik user tertentu
  CollectionReference _getCategoriesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('event_categories');
  }

  // Helper: Menghasilkan kode warna Hex yang konsisten berdasarkan ID dokumen
  String _getHexColorForId(String id) {
    final hash = id.hashCode.abs();
    final colorInt = _categoryColors[hash % _categoryColors.length];
    // Mengambil substring(2) untuk membuang alpha channel (FF) agar formatnya #RRGGBB
    return '#${colorInt.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Menambah kategori baru ke Firestore
  Future<String> addCategory({required String name, required String userId}) async {
    try {
      // Buat referensi dokumen baru untuk mendapatkan ID otomatis
      DocumentReference docRef = _getCategoriesCollection(userId).doc();

      // Generate warna otomatis berdasarkan ID yang baru dibuat
      String autoColor = _getHexColorForId(docRef.id);

      final categoryToSave = {
        'name': name,
        'color': autoColor,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(categoryToSave);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add event category: $e');
    }
  }

  // Mengambil daftar kategori secara realtime (Stream)
  Stream<List<Category>> getCategories(String userId) {
    return _getCategoriesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Memperbarui data kategori yang sudah ada
  Future<void> updateCategory(String userId, Category category) async {
    try {
      await _getCategoriesCollection(userId).doc(category.id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Menghapus kategori berdasarkan ID
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _getCategoriesCollection(userId).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}