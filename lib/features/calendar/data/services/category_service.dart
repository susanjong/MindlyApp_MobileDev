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

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getCategoriesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  // Add category
  Future<String> addCategory(Category category) async {
    try {
      DocumentReference docRef = await _getCategoriesCollection(category.userId).add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // Get all categories
  Stream<List<Category>> getCategories(String userId) {
    return _getCategoriesCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update category
  Future<void> updateCategory(String userId, Category category) async {
    try {
      await _getCategoriesCollection(userId).doc(category.id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _getCategoriesCollection(userId).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}