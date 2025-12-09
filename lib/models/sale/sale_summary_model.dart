/// Represents a summary of a sale, containing basic info for listing.
class SaleSummaryModel {
  /// Unique identifier of the sale (nullable if new).
  final int? saleId;

  /// Identity Card of the client.
  final String clientCi;

  /// Total amount in USD.
  final double totalUsd;

  /// Total amount in VES.
  final double totalVes;

  /// Date and time when the sale occurred.
  final DateTime soldAt;

  /// Status of the sale (active/inactive).
  final bool status;

  // Estos campos los llenaremos con lo que tengamos disponible

  /// Client name for display.
  final String clientName;

  /// Seller name for display.
  final String sellerName;

  /// Payment method name for display.
  final String paymentMethodName;

  /// Creates a new [SaleSummaryModel].
  SaleSummaryModel({
    required this.saleId,
    required this.clientCi,
    required this.totalUsd,
    required this.totalVes,
    required this.soldAt,
    required this.status,
    this.clientName = 'N/A',
    this.sellerName = 'N/A',
    this.paymentMethodName = 'N/A',
  });

  /// Factory constructor to create a [SaleSummaryModel] from a JSON map.
  ///
  /// Handles fallback logic for display names if they appear under different keys in the JSON response.
  factory SaleSummaryModel.fromJson(Map<String, dynamic> json) {
    return SaleSummaryModel(
      saleId: json['sale_id'],
      clientCi: json['client_ci'],
      totalUsd: double.tryParse(json['total_usd'].toString()) ?? 0.0,
      totalVes: double.tryParse(json['total_ves'].toString()) ?? 0.0,
      soldAt: DateTime.parse(json['sold_at']),
      status: json['status'] ?? false,
      // Intentamos leer los nombres si el backend los manda en el resumen
      // Si el backend manda "client_name" en el resumen pero "client" en el detalle,
      // aquí usamos el operador ?? para probar ambos.
      clientName:
          json['client']?.toString() ??
          json['client_name']?.toString() ??
          'N/A',
      sellerName:
          json['user']?.toString() ?? json['user_name']?.toString() ?? 'N/A',
      paymentMethodName:
          json['type_payment']?.toString() ??
          json['payment_method']?.toString() ??
          'N/A',
    );
  }
}
