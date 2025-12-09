import 'package:intl/intl.dart';

class DateFormatter {
  // CAMBIO: Ahora aceptamos DateTime? en lugar de String?
  static String format(DateTime? date) {
    if (date == null) return '--';
    
    // Como ya es DateTime, solo nos aseguramos de pasarlo a la hora local
    // y darle formato.
    return DateFormat('dd/MM/yyyy hh:mm a').format(date.toLocal());
  }
}