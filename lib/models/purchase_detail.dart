
import 'package:flutter/widgets.dart';
import 'package:sicv_flutter/models/product.dart';

class PurchaseDetail {
  final Product product;
  final TextEditingController quantityController;
  final TextEditingController costController;

  PurchaseDetail({
    required this.product,
    required this.quantityController,
    required this.costController,
  });
}