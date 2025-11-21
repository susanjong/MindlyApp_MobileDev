class CategoryModel {
  final String id;
  final String name;
  final bool isFavorite;

  CategoryModel({
    required this.id,
    required this.name,
    this.isFavorite = false,
  });

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