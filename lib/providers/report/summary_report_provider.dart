import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/services/report_service.dart';

// Ajusta el import de tu modelo de ReportSpots si es necesario

final summaryReportProvider = ChangeNotifierProvider<SummaryReportProvider>((
  ref,
) {
  return SummaryReportProvider();
});

class SummaryReportProvider extends ChangeNotifier {
  // --- ESTADO ---
  bool _isLoading = false;
  String _selectedFilter = 'week'; 
  
  // 1. NUEVO: Variable para guardar el rango de fechas personalizado
  DateTimeRange? _selectedDateRange;

  List<FlSpot> _salesData = [];
  List<FlSpot> _purchasesData = []; 
  List<String> _labels = [];
  double _totalSales = 0;
  double _totalPurchases = 0;
  double _totalProfit = 0;

  final List<String> _filterOptions = ['today', 'week', 'month', 'year'];

  final Map<String, String> _filterLabels = {
    'today': 'Hoy',
    'week': 'Esta Semana',
    'month': 'Este Mes',
    'year': 'Este Año',
    'custom': 'Personalizado', // Etiqueta para cuando sea custom
  };

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  
  // Getter para el Rango de Fechas
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  String get selectedFilterLabel =>
      _filterLabels[_selectedFilter] ?? _selectedFilter;
      
  List<String> get filterOptions => _filterOptions;
  List<FlSpot> get salesData => _salesData;
  List<FlSpot> get purchasesData => _purchasesData;
  List<String> get labels => _labels;
  double get totalSales => _totalSales;
  double get totalPurchases => _totalPurchases;
  double get totalProfit => _totalProfit;

  final ReportService _reportService = ReportService();

  SummaryReportProvider() {
    loadData();
  }

  // 2. MODIFICADO: setFilter para limpiar el rango si se elige una opción rápida
  void setFilter(String newFilter) {
    _selectedFilter = newFilter;
    _selectedDateRange = null; // Limpiamos el rango custom
    loadData();
  }

  // 3. NUEVO: Método para establecer el rango personalizado
  void setDateRange(DateTimeRange range) {
    _selectedFilter = 'custom'; // Cambiamos el modo a custom
    _selectedDateRange = range;
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 4. ACTUALIZADO: Pasamos los parámetros opcionales al servicio
      final reportSpots = await _reportService.getSalesDatesStats(
        _selectedFilter,
        start: _selectedDateRange?.start,
        end: _selectedDateRange?.end,
      );

      // (Nota: Si tu backend soporta filtrado por fechas en estos endpoints también, 
      // deberías actualizarlos, por ahora asumo que traen totales generales)
      final totalSales = await _reportService.getTotalSales();
      final totalPurchases = await _reportService.getTotalPurchases();

      _labels = reportSpots.labels;
      _salesData = reportSpots.spots
          .map((spot) => FlSpot(spot.x, spot.y)) // Asegúrate que spot.x sea double
          .toList();

      _totalSales = totalSales;
      _totalPurchases = totalPurchases;
      _totalProfit = totalSales - totalPurchases;

      _purchasesData = [];
    } catch (e) {
      debugPrint("Error loading report data: $e");
      _salesData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}