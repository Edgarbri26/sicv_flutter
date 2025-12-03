// models/role_model.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show listEquals;

// Importamos el modelo de permiso que acabamos de crear.
import 'permission_model.dart';

class RoleModel {
  final int rolId;
  final String name;
  final List<PermissionModel> permissions;

  RoleModel({
    this.rolId = 0,
    required this.name,
    this.permissions = const [],
  });

  /// Factory constructor para crear una instancia de Role desde un Map (JSON).
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    
    // Parseamos la lista de permisos: robusto contra null.
    var permissionsList = (json['permissions'] as List<dynamic>?)
        ?.map((permJson) =>
            PermissionModel.fromJson(permJson as Map<String, dynamic>))
        .toList() ??
        [];

    return RoleModel(
      // 💡 MEJORA DE SEGURIDAD 1: Usa 'as int?' y proporciona un valor por defecto.
      // Esto evita crashes si 'rolId' es nulo o falta.
      rolId: json['role_id'], 
      
      // 💡 MEJORA DE SEGURIDAD 2: Usa 'as String?' y proporciona un valor por defecto.
      // Esto evita crashes si 'name' es nulo o falta.
      name: json['name'] as String? ?? 'Sin Nombre',
      
      permissions: permissionsList,
    );
  }

  /// Método de conveniencia para convertir un Map a String.
  String toJson() => json.encode(toMap());

  /// Método de conveniencia para convertir la instancia a un Map.
  Map<String, dynamic> toMap() {
    return {
      'role_id': rolId,
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
        other.rolId == rolId &&
        other.name == name &&
        listEquals(other.permissions, permissions);
  }

  @override
  int get hashCode => rolId.hashCode ^ name.hashCode ^ permissions.hashCode;
}