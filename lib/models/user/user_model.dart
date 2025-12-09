import 'package:sicv_flutter/models/role_model.dart';

/// Represents a system user (admin, employee, seller).
///
/// Contains authentication details, role association, and status.
class UserModel {
  /// Unique identifier (Identity Card) of the user.
  final String userCi;

  /// Full name of the user.
  final String name;

  /// Password for authentication (hashed or plain depending on context, usually null on read).
  final String? password;

  /// The ID of the role assigned to this user.
  final int roleId;

  /// The active status of the user account.
  final bool status;

  /// The full role object associated with this user.
  final RoleModel? role;

  /// Creates a new [UserModel].
  UserModel({
    required this.userCi,
    required this.name,
    this.password,
    required this.roleId,
    required this.status,
    this.role,
  });

  /// Factory constructor to create a [UserModel] from a JSON map.
  ///
  /// Implements robust parsing logic to handle potential field name discrepancies
  /// (e.g., `rol_id` vs `role_id`) and ensures type safety.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. ESTRATEGIA DE BÚSQUEDA DOBLE (A prueba de errores)
    // Intentamos leer 'rol_id' (lo que definiste en Sequelize)
    // Si es nulo, intentamos leer 'role_id' (lo que a veces llega en el JSON)
    final rawRoleId = json['role_id'];

    // Parseo del objeto Role anidado
    final Map<String, dynamic>? roleJson =
        json['role'] as Map<String, dynamic>?;

    return UserModel(
      userCi: json['user_ci'] as String? ?? '0',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      password: json['password'],

      // 2. Parseo seguro del ID
      roleId: rawRoleId is int
          ? rawRoleId
          : int.tryParse(rawRoleId.toString()) ??
                0, // Si falla todo, devuelve 0

      status: json['status'] as bool? ?? false,

      // 3. Parseo del objeto Rol
      role: roleJson != null ? RoleModel.fromJson(roleJson) : null,
    );
  }

  // Para enviar datos al backend (aquí sí debemos ser estrictos con lo que espera el backend)

  /// Converts this [UserModel] instance to a JSON map.
  ///
  /// Strict serialization for backend compatibility.
  Map<String, dynamic> toJson() {
    return {
      'user_ci': userCi,
      'name': name,
      'password': password,
      'role_id':
          roleId, // Enviaremos 'role_id' que es lo que definiste en tu UserFactory
      'status': status,
      'role': role?.toMap(),
    };
  }
}
