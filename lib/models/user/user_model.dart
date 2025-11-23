import 'package:sicv_flutter/models/role_model.dart';

class UserModel {
  final String userCi;
  final String name;
  final String? password;
  final int rolId;
  final bool status;
  final RoleModel? rol;

  UserModel({
    required this.userCi,
    required this.name,
    this.password,
    required this.rolId,
    required this.status,
    this.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
  
    // 1. Extraer el valor de 'rol', asegurando que es un Map anulable (Map<String, dynamic>?)
    // El '?' al final es crucial. Si el valor es un int (como '1'), 'as Map<String, dynamic>?' lo convierte a null.
    final Map<String, dynamic>? rolJson = json['rol'] as Map<String, dynamic>?;

    return UserModel(
      userCi: json['user_ci'] as String? ?? '0',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      password: json['password'],
      rolId: json['rol_id'] is int 
          ? json['rol_id'] 
          : int.tryParse(json['rol_id'].toString()) ?? 0,
      status: json['status'] as bool? ?? false,
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
    };
  }
}