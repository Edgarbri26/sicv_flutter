 import 'package:sicv_flutter/models/depot_model.dart';
 import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/models/user_model.dart';

class MovementModel {
  final int movementId;
  final int depotId;
  final int productId;
  final String userCi;
  final String type;
  final int amount;
  final String observation;
  final DateTime movedAt;
  final bool status;
  final UserModel? user;
  final ProductModel? product;
  final DepotModel? depot;

  MovementModel({
    required this.movementId,
    required this.depotId,
    required this.productId,
    required this.userCi,
    required this.type,
    required this.amount,
    required this.observation,
    required this.movedAt,
    required this.status,
    this.product,
    this.depot,
    this.user,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      movementId: json['movement_id'],
      depotId: json['depot_id'],
      productId: json['product_id'],
      userCi: json['user_ci'],
      type: json['type'],
      amount: json['amount'],
      observation: json['observation'],
      movedAt: DateTime.parse(json['moved_at']),
      status: json['status'],
      product: ProductModel?.fromJson(json['product']),
      depot: DepotModel?.fromJson(json['depot']),
      user: UserModel?.fromJson(json['user']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'movement_id': movementId,
      'depot_id': depotId,
      'product_id': productId,
      'user_ci': userCi,
      'type': type,
      'amount': amount,
      'observation': observation,
      'moved_at': movedAt.toIso8601String(),
      'status': status,
      'product': product?.toJson(),
      'depot': depot?.toJson(),
      'user': user?.toJson(),
    };
  } 
}

