class CategoryModel {
  final String id;
  final String name;
  final bool isFavorite;

  CategoryModel({
    required this.id,
    required this.name,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isFavorite': isFavorite,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

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