class StockOptionModel {
  final int? lotId;
  final int depotId;
  final String depotName;
  final int amount;
  final String? expiration; // Null si no es perecedero o es inventario general
  final bool isLot;

  StockOptionModel({
    this.lotId,
    required this.depotId,
    required this.depotName,
    required this.amount,
    this.expiration,
    required this.isLot,
  });

  factory StockOptionModel.fromJson(Map<String, dynamic> json) {
    return StockOptionModel(
      lotId: json['lot_id'] as int?,
      depotId: json['depot_id'] as int,
      depotName: json['depot_name'] as String,
      amount: json['amount'] as int,
      expiration: json['expiration'] as String?,
      isLot: json['is_lot'] as bool,
    );
  }

  // --- MEJORA SUGERIDA ---
  // Como no tienes "código", la forma de identificar el lote para el humano
  // es ver cuándo vence y cuánto hay.
  String get displayLabel {
    if (isLot && expiration != null) {
      // Ejemplo visual: "Vence: 2025-12-01 (Disp: 50)"
      // Si quieres formatear la fecha más bonito, aquí podrías parsearla.
      return 'Vence: ${_formatDate(expiration!)} - Disp: $amount';
    } else {
      // Si no es lote (inventario general)
      return 'General - Disp: $amount';
    }
  }

  // Pequeño helper opcional si tu fecha viene como "2025-12-01T00:00:00.000Z"
  // y quieres mostrar solo "2025-12-01"
  String _formatDate(String dateStr) {
    try {
      // Simplemente corta la cadena si es ISO estándar, o usa intl si prefieres
      return dateStr.split('T')[0]; 
    } catch (e) {
      return dateStr;
    }
  }
}