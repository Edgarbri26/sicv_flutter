import 'package:sicv_flutter/models/role_model.dart';

class UserModel {
  final String userCi;
  final String name;
  final String password;
  final String rolId;
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
    return UserModel(
      userCi: json['user_ci'],
      name: json['name'],
      password: json['password'],
      rolId: json['rol_id'],
      status: json['status'],
      rol: RoleModel.fromJson(json['rol']),
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