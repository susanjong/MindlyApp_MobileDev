class NoteModel {
  final String title;
  final String content;
  final String timeAgo;

  NoteModel({
    required this.title,
    required this.content,
    required this.timeAgo,
  });

  // Factory method untuk membuat dummy data (opsional, untuk testing)
  factory NoteModel.dummy() {
    return NoteModel(
      title: 'Sample Note',
      content: 'This is a sample note content...',
      timeAgo: '1 hour ago',
    );
  }

  // Method untuk copy dengan perubahan (immutability pattern)
  NoteModel copyWith({
    String? title,
    String? content,
    String? timeAgo,
  }) {
    return NoteModel(
      title: title ?? this.title,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}