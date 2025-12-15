import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'achievement', 'deadline', 'overdue', 'reminder'
  final String priority; // 'high', 'medium', 'low'
  final String? relatedTaskId;
  final String? relatedEventId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.priority = 'low',
    this.relatedTaskId,
    this.relatedEventId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'achievement',
      priority: map['priority'] ?? 'low',
      relatedTaskId: map['relatedTaskId'],
      relatedEventId: map['relatedEventId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'priority': priority,
      'relatedTaskId': relatedTaskId,
      'relatedEventId': relatedEventId,
    };
  }
  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? priority,
    String? relatedTaskId,
    String? relatedEventId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      relatedEventId: relatedEventId ?? this.relatedEventId,
    );
  }
}