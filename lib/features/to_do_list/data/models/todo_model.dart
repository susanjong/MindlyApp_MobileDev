import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;
  final String title;
  final String category;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.category,
    required this.deadline,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Mengubah data dari Firestore (Map) ke Object Dart
  factory TodoModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TodoModel(
      id: documentId,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Uncategorized',
      // Mengubah Timestamp Firebase ke DateTime Dart
      deadline: (data['deadline'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Mengubah Object Dart ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'deadline': Timestamp.fromDate(deadline),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}