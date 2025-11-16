import 'package:sicv_flutter/models/role_model.dart';

class UserModel {
  final String userCi;
  final String name;
  final String password;
  final int rolId;
  final bool status;
  final RoleModel rol;

  UserModel({
    required this.userCi,
    required this.name,
    required this.password,
    required this.rolId,
    required this.status,
    required this.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  
    // 1. Extraer el valor de 'rol', asegurando que es un Map anulable (Map<String, dynamic>?)
    // El '?' al final es crucial. Si el valor es un int (como '1'), 'as Map<String, dynamic>?' lo convierte a null.
    final Map<String, dynamic>? rolJson = json['rol'] as Map<String, dynamic>?;

    return UserModel(
      userCi: json['user_ci'] as String? ?? '0',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      password: json['password'] as String? ?? '',
      rolId: json['rol_id'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
      
      // 2. Mapeo Condicional: Si rolJson existe, úsalo. Si no, usa un RoleModel por defecto.
      rol: rolJson != null 
          ? RoleModel.fromJson(rolJson)
          : RoleModel(name: 'Rol Desconocido'), // Asegúrate de que RoleModel tiene un constructor compatible con esto.
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_ci': userCi,
      'name': name,
      'password': password,
      'rol_id': rolId,
      'status': status,
      'rol': rol.toJson(),
    };
  }
}