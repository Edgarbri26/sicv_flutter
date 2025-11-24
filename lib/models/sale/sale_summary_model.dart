class SaleSummaryModel {
  final int? saleId;
  final String clientCi;
  final double totalUsd;
  final double totalVes;
  final DateTime soldAt;
  final bool status;
  
  // Estos campos los llenaremos con lo que tengamos disponible
  final String clientName;
  final String sellerName;
  final String paymentMethodName;

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
      clientName: json['client']?.toString() ?? json['client_name']?.toString() ?? 'N/A',
      sellerName: json['user']?.toString() ?? json['user_name']?.toString() ?? 'N/A',
      paymentMethodName: json['type_payment']?.toString() ?? json['payment_method']?.toString() ?? 'N/A',
    );
  }
}