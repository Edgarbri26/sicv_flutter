import 'package:flutter/widgets.dart';
import 'package:sicv_flutter/models/depot/depot_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';

class PurchaseDetail {
  final ProductModel product;
  final TextEditingController quantityController;
  final TextEditingController costController;
  final TextEditingController? expirationDateController;
  DepotModel? selectedDepot;

  PurchaseDetail({
    required this.product,
    required this.quantityController,
    required this.costController,
    this.expirationDateController,
    this.selectedDepot,
  });
}
