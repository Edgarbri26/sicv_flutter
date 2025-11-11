class DepotModel {
  final int id;
  final String name;
  final String location;
  final bool status;

  DepotModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
  });

    factory DepotModel.fromJson(Map<String, dynamic> json) {
    return DepotModel(
      id: json['depot_id'],
      name: json['name'],
      location: json['location'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depot_id': id,
      'name': name,
      'location': location,
      'status': status,
    };
  }
}
