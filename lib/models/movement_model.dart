 import 'package:sicv_flutter/models/depot_model.dart';
 import 'package:sicv_flutter/models/product_model.dart';

class MovimentModel {
  int movementId;
  int depotId;
  int productId;
  String type;
  int amount;
  String observation;
  DateTime movedAt;
  bool status;
  ProductModel product;
  DepotModel depot;

  MovimentModel({
    required this.movementId,
    required this.depotId,
    required this.productId,
    required this.type,
    required this.amount,
    required this.observation,
    required this.movedAt,
    required this.status,
    required this.product,
    required this.depot,
  });

  factory MovimentModel.fromJson(Map<String, dynamic> json) {
    return MovimentModel(
      movementId: json['movement_id'],
      depotId: json['depot_id'],
      productId: json['product_id'],
      type: json['type'],
      amount: json['amount'],
      observation: json['observation'],
      movedAt: DateTime.parse(json['moved_at']),
      status: json['status'],
      product: ProductModel.fromJson(json['product']),
      depot: DepotModel.fromJson(json['depot']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'movement_id': movementId,
      'depot_id': depotId,
      'product_id': productId,
      'type': type,
      'amount': amount,
      'observation': observation,
      'moved_at': movedAt.toIso8601String(),
      'status': status,
      'product': product.toJson(),
      'depot': depot.toJson(),
    };
  } 
}

