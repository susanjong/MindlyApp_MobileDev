import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String categoryId;
  final bool isFavorite;
  final int color;

  // Constructor dengan default value untuk isFavorite dan color
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    this.isFavorite = false,
    this.color = 0xFFE6C4DE, // Default warna pastel pink
  });

  // Mengubah object menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'categoryId': categoryId,
      'isFavorite': isFavorite,
      'color': color,
    };
  }

  // Factory untuk membuat object dari data Firestore
  // Menangani konversi Timestamp Firestore ke DateTime Dart
  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryId: map['categoryId'] ?? 'all',
      isFavorite: map['isFavorite'] ?? false,
      color: map['color'] ?? 0xFFE6C4DE,
    );
  }

  // Getter untuk format tanggal yang mudah dibaca (Contoh: January 1, 2024)
  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[updatedAt.month - 1]} ${updatedAt.day}, ${updatedAt.year}';
  }

  // Getter untuk menampilkan waktu relatif (Contoh: 2 hours ago)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Method copyWith untuk membuat salinan object dengan pembaruan data (Immutable pattern)
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryId,
    bool? isFavorite,
    int? color,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      color: color ?? this.color,
    );
  }
}