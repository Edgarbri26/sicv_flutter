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
      rolId: json['role_id'] is int 
          ? json['role_id'] 
          : int.tryParse(json['role_id'].toString()) ?? 0,
    );  
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_ci': userCi,
      'name': name,
      'role_id': rolId,
    };
  }
}