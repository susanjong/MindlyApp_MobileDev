import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final int gradientIndex; // Menyimpan warna yang dipilih

  CategoryModel({
    required this.id,
    required this.name,
    required this.gradientIndex,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CategoryModel(
      id: documentId,
      name: data['name'] ?? '',
      gradientIndex: data['gradientIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gradientIndex': gradientIndex,
    };
  }
}