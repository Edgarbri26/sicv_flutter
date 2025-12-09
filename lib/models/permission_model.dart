// models/permission_model.dart

import 'dart:convert';

/// Represents a user permission within the system.
class PermissionModel {
  /// Unique identifier for the permission.
  final int permissionId;

  /// The unique code string representing the permission (e.g., 'READ_USER').
  final String code;

  /// The human-readable name of the permission.
  final String name;

  /// A description of what the permission allows.
  final String description;

  /// The active status of the permission.
  bool status;

  /// Creates a new [PermissionModel].
  PermissionModel({
    required this.permissionId,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
  });

  /// Factory constructor to create a [PermissionModel] from a JSON map.
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

  /// Converts this [PermissionModel] instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Converts this [PermissionModel] instance to a Map.
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
