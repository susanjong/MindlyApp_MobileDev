import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'userId': userId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? '#5683EB',
      userId: map['userId'] ?? '',
    );
  }
}

class EventCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List warna & Helper _getHexColorForId tetap sama...
  static const List<int> categoryColors = [
    0xFFFBAE38, 0xFFBEE973, 0xFF5784EB, 0xFFD732A8,
    0xFFAB5CFF, 0xFF00A89D, 0xFF009B7D, 0xFFBEE973,
  ];

  String _getHexColorForId(String id) {
    final hash = id.hashCode.abs();
    final colorInt = categoryColors[hash % categoryColors.length];
    return '#${colorInt.toRadixString(16).substring(2).toUpperCase()}';
  }

  CollectionReference _getCategoriesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('event_categories');
  }

  Future<String> addCategory({required String name, required String userId}) async {
    try {
      DocumentReference docRef = _getCategoriesCollection(userId).doc();
      String autoColor = _getHexColorForId(docRef.id);

      final categoryToSave = {
        'name': name,
        'color': autoColor,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(), // Optional: tambah timestamp
      };

      await docRef.set(categoryToSave);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add event category: $e');
    }
  }

  Stream<List<Category>> getCategories(String userId) {
    return _getCategoriesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateCategory(String userId, Category category) async {
    try {
      await _getCategoriesCollection(userId).doc(category.id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _getCategoriesCollection(userId).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}