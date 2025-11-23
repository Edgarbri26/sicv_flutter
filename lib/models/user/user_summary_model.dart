class UserSummaryModel {
  final String userCi;
  final String name;
  final int rolId;

  UserSummaryModel({
    required this.userCi,
    required this.name,
    required this.rolId
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      userCi: json['user_ci'] as String? ?? '0',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      rolId: json['rol_id'] is int 
          ? json['rol_id'] 
          : int.tryParse(json['rol_id'].toString()) ?? 0,
    );  
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_ci': userCi,
      'name': name,
      'rol_id': rolId,
    };
  }
}