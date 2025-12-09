// models/role_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show listEquals;

// Importamos el modelo de permiso que acabamos de crear.
import 'permission_model.dart';

/// Represents a user role, which contains a collection of permissions.
class RoleModel {
  /// Unique identifier for the role.
  final int roleId;

  /// The name of the role (e.g., 'Administrator', 'Seller').
  final String name;

  /// The list of permissions associated with the role.
  final List<PermissionModel> permissions;

  /// Creates a new [RoleModel].
  RoleModel({this.roleId = 0, required this.name, this.permissions = const []});

  /// Factory constructor to create a [RoleModel] from a JSON map.
  ///
  /// Handles potential null values for fields and creates a list of [PermissionModel]
  /// from the nested JSON list.
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    // Parseamos la lista de permisos: robusto contra null.
    var permissionsList =
        (json['permissions'] as List<dynamic>?)
            ?.map(
              (permJson) =>
                  PermissionModel.fromJson(permJson as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return RoleModel(
      // 💡 MEJORA DE SEGURIDAD 1: Usa 'as int?' y proporciona un valor por defecto.
      // Esto evita crashes si 'rolId' es nulo o falta.
      roleId: json['role_id'],

      // 💡 MEJORA DE SEGURIDAD 2: Usa 'as String?' y proporciona un valor por defecto.
      // Esto evita crashes si 'name' es nulo o falta.
      name: json['name'] as String? ?? 'Sin Nombre',

      permissions: permissionsList,
    );
  }

  /// Converts this [RoleModel] instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Converts this [RoleModel] instance to a Map.
  Map<String, dynamic> toMap() {
    return {
      'role_id': roleId,
      'name': name,
      'permissions': permissions.map((p) => p.toMap()).toList(),
    };
  }

  // // Sobrescribimos '==' y 'hashCode' para comparar instancias.
  // // Es una buena práctica para modelos de datos.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoleModel &&
        other.roleId == roleId &&
        other.name == name &&
        listEquals(other.permissions, permissions);
  }

  @override
  int get hashCode => roleId.hashCode ^ name.hashCode ^ permissions.hashCode;
}
