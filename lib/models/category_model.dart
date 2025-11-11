class CategoryModel {
  final int id;
  final String name;
  final bool status;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
  });

  // El factory 'fromJson' para la categoría
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Asumimos que el JSON de la categoría tiene 'category_id' y 'name'
    // ¡Ajusta estas claves ('category_id') si en tu JSON se llaman diferente!
    return CategoryModel(
      id: json['category_id'], 
      name: json['name'],
      status: json['status'],
      description: json['description'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
      'status': status,
      'description': description,
    };
  }

}