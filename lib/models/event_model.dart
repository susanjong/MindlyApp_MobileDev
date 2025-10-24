import 'package:flutter/material.dart';

class EventModel {
  final String title;
  final String time;
  final String location;
  final Color color;

  EventModel({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
  });

  // Factory method untuk membuat dummy data (opsional, untuk testing)
  factory EventModel.dummy() {
    return EventModel(
      title: 'Sample Event',
      time: 'Today, 10:00 AM',
      location: 'Office',
      color: const Color(0xFF0D5F5F),
    );
  }

  // Method untuk copy dengan perubahan (immutability pattern)
  EventModel copyWith({
    String? title,
    String? time,
    String? location,
    Color? color,
  }) {
    return EventModel(
      title: title ?? this.title,
      time: time ?? this.time,
      location: location ?? this.location,
      color: color ?? this.color,
    );
  }
}