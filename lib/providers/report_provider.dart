import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';

// Definimos el provider globalmente para Riverpod
final reportProvider = ChangeNotifierProvider<ReportProvider>((ref) {
  return ReportProvider();
});

class ReportProvider extends ChangeNotifier {
  // --- ESTADO ---
  bool _isLoading = false;
  String _selectedFilter = 'Esta Semana';
  
  List<FlSpot> _ventasData = [];
  List<FlSpot> _comprasData = [];

  final List<String> _filterOptions = [
    'Hoy',
    'Esta Semana',
    'Este Mes',
    'Este Año'
  ];

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  List<String> get filterOptions => _filterOptions;
  List<FlSpot> get ventasData => _ventasData;
  List<FlSpot> get comprasData => _comprasData;

  ReportProvider() {
    _loadMockData();
  }

  void setFilter(String newFilter) {
    _selectedFilter = newFilter;
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (_selectedFilter == 'Esta Semana') {
      _ventasData = [
        const FlSpot(0, 3), const FlSpot(1, 1), const FlSpot(2, 4),
        const FlSpot(3, 3), const FlSpot(4, 6), const FlSpot(5, 4), const FlSpot(6, 8),
      ];
      _comprasData = [
        const FlSpot(0, 1), const FlSpot(1, 2), const FlSpot(2, 1),
        const FlSpot(3, 4), const FlSpot(4, 2), const FlSpot(5, 3), const FlSpot(6, 2),
      ];
    } else {
      _ventasData = [
        const FlSpot(0, 5), const FlSpot(1, 7), const FlSpot(2, 6), const FlSpot(3, 9),
      ];
      _comprasData = [
        const FlSpot(0, 2), const FlSpot(1, 3), const FlSpot(2, 2), const FlSpot(3, 4),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }
}