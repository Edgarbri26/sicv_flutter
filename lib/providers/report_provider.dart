import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/services/report_service.dart';


final reportProvider = ChangeNotifierProvider<ReportProvider>((ref) {
  return ReportProvider();
});

class ReportProvider extends ChangeNotifier {
  // --- ESTADO ---
  bool _isLoading = false;
  String _selectedFilter =
      'week'; // Default to 'week' as per API likely expectation

  List<FlSpot> _salesData = [];
  List<FlSpot> _purchasesData = []; // Still mock or need another endpoint?
  List<String> _labels = [];
  double _totalSales = 0;
  double _totalPurchases = 0;

  final List<String> _filterOptions = ['today', 'week', 'month', 'year'];

  // Map for display labels if needed
  final Map<String, String> _filterLabels = {
    'today': 'Hoy',
    'week': 'Esta Semana',
    'month': 'Este Mes',
    'year': 'Este Año',
  };

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  String get selectedFilterLabel =>
      _filterLabels[_selectedFilter] ?? _selectedFilter;
  List<String> get filterOptions => _filterOptions;
  List<FlSpot> get salesData => _salesData;
  List<FlSpot> get purchasesData => _purchasesData;
  List<String> get labels => _labels;
  double get totalSales => _totalSales;
  double get totalPurchases => _totalPurchases;

  final ReportService _reportService = ReportService();

  ReportProvider() {
    loadData();
  }

  void setFilter(String newFilter) {
    _selectedFilter = newFilter;
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final reportSpots = await _reportService.getSalesDatesStats(
        _selectedFilter,
      );

      _labels = reportSpots.labels;
      _salesData = reportSpots.spots
          .map((spot) => FlSpot(spot.x, spot.y))
          .toList();

      // For now, keep comprasData empty or mock until we have an endpoint
      _purchasesData = [];
    } catch (e) {
      print("Error loading report data: $e");
      // Handle error state if necessary
      _salesData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
