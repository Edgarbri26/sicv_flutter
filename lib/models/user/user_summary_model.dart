/// Represents a lightweight summary of a user.
class UserSummaryModel {
  /// Identity identification of the user.
  final String userCi;

  /// Name of the user.
  final String name;

  /// ID of the user's role.
  final int rolId;

  /// Creates a new [UserSummaryModel].
  UserSummaryModel({
    required this.userCi,
    required this.name,
    required this.rolId,
  });

  /// Factory constructor to create a [UserSummaryModel] from a JSON map.
  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      userCi: json['user_ci'] as String? ?? '0',
      name: json['name'] as String? ?? 'Usuario Desconocido',
      rolId: json['role_id'] is int
          ? json['role_id']
          : int.tryParse(json['role_id'].toString()) ?? 0,
    );
  }

  /// Converts this [UserSummaryModel] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'user_ci': userCi, 'name': name, 'role_id': rolId};
  }
}
