// models/permission_model.dart

import 'dart:convert';

class PermissionModel {
  final int permissionId;
  final String code;
  final String name;
  final String description;
  bool status;

  PermissionModel({
    required this.permissionId,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
  });

  /// Factory constructor para crear una instancia de Permission desde un Map (JSON).
  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      // Mapeamos 'permission_id' del JSON a 'permissionId' en Dart.
      permissionId: json['permission_id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as bool,
      // Ignoramos 'role_permissions' ya que parece ser data de la tabla pivote
      // y no es una propiedad intrínseca del permiso en sí.
    );
  }

  /// Método de conveniencia para convertir un Map a String (útil para debugging).
  String toJson() => json.encode(toMap());

  /// Método de conveniencia para convertir la instancia a un Map.
  Map<String, dynamic> toMap() {
    return {
      'permission_id': permissionId,
      'code': code,
      'name': name,
      'description': description,
      'status': status,
    };
  }
}
