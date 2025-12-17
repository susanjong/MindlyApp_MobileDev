class CategoryModel {
  final String id;
  final String name;
  final bool isFavorite;

  // Constructor utama
  CategoryModel({
    required this.id,
    required this.name,
    this.isFavorite = false,
  });

  // Mengubah object menjadi Map untuk disimpan ke database (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isFavorite': isFavorite,
    };
  }

  // Factory untuk membuat object dari data Map (hasil fetch database)
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // Method copyWith untuk membuat salinan object dengan pembaruan data (Immutable pattern)
  CategoryModel copyWith({
    String? id,
    String? name,
    bool? isFavorite,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}