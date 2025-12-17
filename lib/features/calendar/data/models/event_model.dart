import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String categoryId;
  final String userId;
  final DateTime createdAt;
  final String location;
  final String reminder;
  final String repeat;
  final String? parentEventId; // ID induk jika event ini adalah hasil perulangan

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.categoryId,
    required this.userId,
    required this.createdAt,
    this.location = '',
    this.reminder = '15 minutes before',
    this.repeat = 'Does not repeat',
    this.parentEventId,
  });

  // Mengubah object menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime), // Konversi DateTime ke Timestamp Firestore
      'endTime': Timestamp.fromDate(endTime),
      'categoryId': categoryId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
      'reminder': reminder,
      'repeat': repeat,
      // Hanya simpan field ini jika nilainya tidak null
      if (parentEventId != null) 'parentEventId': parentEventId,
    };
  }

  // Factory untuk membuat object dari dokumen Firestore (Map)
  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Konversi Timestamp Firestore kembali ke DateTime Dart
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      categoryId: map['categoryId'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      reminder: map['reminder'] ?? '15 minutes before',
      repeat: map['repeat'] ?? 'Does not repeat',
      parentEventId: map['parentEventId'],
    );
  }

  // Method copyWith untuk membuat salinan object dengan pembaruan data (Immutable pattern)
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? categoryId,
    String? userId,
    DateTime? createdAt,
    String? location,
    String? reminder,
    String? repeat,
    String? parentEventId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      reminder: reminder ?? this.reminder,
      repeat: repeat ?? this.repeat,
      parentEventId: parentEventId ?? this.parentEventId,
    );
  }
}