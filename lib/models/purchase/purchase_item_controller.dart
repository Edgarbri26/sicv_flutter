import 'package:flutter/widgets.dart';
import 'package:sicv_flutter/models/depot/depot_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';

/// Helper model for managing purchase details in the UI (e.g., in a form or controller).
///
/// Holds the controllers and selected values for a specific item during the purchase creation process.
class PurchaseDetail {
  /// The product being purchased.
  final ProductModel product;

  /// Controller for the quantity input field.
  final TextEditingController quantityController;

  /// Controller for the unit cost input field.
  final TextEditingController costController;

  /// Controller for the expiration date input field (optional).
  final TextEditingController? expirationDateController;

  /// The depot selected for storing this product (optional).
  DepotModel? selectedDepot;

  /// Creates a new [PurchaseDetail].
  PurchaseDetail({
    required this.product,
    required this.quantityController,
    required this.costController,
    this.expirationDateController,
    this.selectedDepot,
  });
}
