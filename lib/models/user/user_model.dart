import 'package:sicv_flutter/models/role_model.dart';

class UserModel {
  final String userCi;
  final String name;
  final String? password;
  final int roleId;
  final bool status;
  final RoleModel? role;

  UserModel({
    required this.userCi,
    required this.name,
    this.password,
    required this.roleId,
    required this.status,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    
    // 1. ESTRATEGIA DE BÚSQUEDA DOBLE (A prueba de errores)
    // Intentamos leer 'rol_id' (lo que definiste en Sequelize)
    // Si es nulo, intentamos leer 'role_id' (lo que a veces llega en el JSON)
    final rawRoleId = json['rol_id'] ?? json['role_id']; 

    // Parseo del objeto Role anidado
    final Map<String, dynamic>? roleJson = json['role'] as Map<String, dynamic>?;

    return UserModel(
      userCi: json['user_ci'] as String? ?? '0',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      password: json['password'],
      
      // 2. Parseo seguro del ID
      roleId: rawRoleId is int 
          ? rawRoleId 
          : int.tryParse(rawRoleId.toString()) ?? 0, // Si falla todo, devuelve 0
          
      status: json['status'] as bool? ?? false,
      
      // 3. Parseo del objeto Rol
      role: roleJson != null 
          ? RoleModel.fromJson(roleJson)
          : null,
    );
  }
  
  // Para enviar datos al backend (aquí sí debemos ser estrictos con lo que espera el backend)
  Map<String, dynamic> toJson() {
    return {
      'user_ci': userCi,
      'name': name,
      'password': password,
      'role_id': roleId, // Enviaremos 'role_id' que es lo que definiste en tu UserFactory
      'status': status,
    };
  }
}