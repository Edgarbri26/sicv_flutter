class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // El factory 'fromJson' para la categoría
  factory Category.fromJson(Map<String, dynamic> json) {
    // Asumimos que el JSON de la categoría tiene 'category_id' y 'name'
    // ¡Ajusta estas claves ('category_id') si en tu JSON se llaman diferente!
    return Category(
      id: json['category_id'], 
      name: json['name'],
    );
  }
}