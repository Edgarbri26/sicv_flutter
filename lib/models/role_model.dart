// models/role_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show listEquals;

// Importamos el modelo de permiso que acabamos de crear.
import 'permission_model.dart';

class RoleModel {
  final int rolId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Permission> permissions;

  RoleModel({
    required this.rolId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.permissions,
  });

  /// Factory constructor para crear una instancia de Role desde un Map (JSON).
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    // Parseamos la lista de permisos llamando a Permission.fromJson por cada ítem.
    // Usamos '?? []' para asegurar que la lista nunca sea nula, incluso si la API
    // omite el campo 'permissions' cuando está vacío.
    var permissionsList = (json['permissions'] as List<dynamic>?)
            ?.map((permJson) =>
                Permission.fromJson(permJson as Map<String, dynamic>))
            .toList() ??
        [];

    return RoleModel(
      rolId: json['rol_id'] as int,
      name: json['name'] as String,
      // Es vital parsear los strings de fecha a objetos DateTime
      // para poder manipularlos en Dart.
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      permissions: permissionsList,
    );
  }

  /// Método de conveniencia para convertir un Map a String.
  String toJson() => json.encode(toMap());

  /// Método de conveniencia para convertir la instancia a un Map.
  Map<String, dynamic> toMap() {
    return {
      'rol_id': rolId,
      'name': name,
      // Convertimos DateTime a formato ISO 8601 string, estándar en JSON.
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'permissions': permissions.map((p) => p.toMap()).toList(),
    };
  }

  // // Sobrescribimos '==' y 'hashCode' para comparar instancias.
  // // Es una buena práctica para modelos de datos.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoleModel &&
        other.rolId == rolId &&
        other.name == name &&
        listEquals(other.permissions, permissions);
  }

  @override
  int get hashCode => rolId.hashCode ^ name.hashCode ^ permissions.hashCode;
}