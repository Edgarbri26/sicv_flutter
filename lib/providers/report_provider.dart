// lib/providers/report_provider.dart
import 'dart:math'; // Necesitamos esto para datos aleatorios
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// ReportProvider
///
/// Maneja el estado y la lógica de negocio para la sección de reportes.
///
/// Usamos [ChangeNotifier] para notificar a los widgets que "escuchan"
/// (los [Consumer]) que deben redibujarse cuando un dato cambia.
class ReportProvider with ChangeNotifier {
  // --- ESTADO PRIVADO ---

  // --- NUEVO: Estado para los datos del gráfico ---
  
  final List<FlSpot> _ventasData = [];
  final List<FlSpot> _comprasData = [];

  // --- GETTERS PÚBLICOS (NUEVOS) ---
  List<FlSpot> get ventasData => _ventasData;
  List<FlSpot> get comprasData => _comprasData;

  String _selectedFilter = 'Últimos 7 días';
  final List<String> _filterOptions = [
    'Hoy', 'Ayer', 'Últimos 7 días', 'Este mes', 'Este año', 'Rango Personalizado'
  ];
  bool _isLoading = false;

  String get selectedFilter => _selectedFilter;
  List<String> get filterOptions => _filterOptions;
  bool get isLoading => _isLoading;

  // --- (NUEVO) ESTADO DE INVENTARIO ---

  // KPIs
  double _totalInventoryValue = 0.0;
  int _itemsOutOfStock = 0;
  int _itemsLowStock = 0;

  // Datos del Gráfico de Pastel
  List<PieChartSectionData> _categorySections = [];

  // Datos del Gráfico de Barras
  List<BarChartGroupData> _lowStockBarData = [];
  List<String> _lowStockProductNames = [];

  // --- (NUEVO) GETTERS DE INVENTARIO ---
  double get totalInventoryValue => _totalInventoryValue;
  int get itemsOutOfStock => _itemsOutOfStock;
  int get itemsLowStock => _itemsLowStock;
  List<PieChartSectionData> get categorySections => _categorySections;
  List<BarChartGroupData> get lowStockBarData => _lowStockBarData;
  List<String> get lowStockProductNames => _lowStockProductNames;

  // --- (NUEVO) ESTADO DE CLIENTES ---
  double _cuentasPorCobrar = 0.0;
  int _clientesNuevosEsteMes = 0;
  List<PieChartSectionData> _customerPieData = [];
  List<BarChartGroupData> _topCustomerBarData = [];
  List<String> _topCustomerNames = [];

  // --- (NUEVO) GETTERS DE CLIENTES ---
  double get cuentasPorCobrar => _cuentasPorCobrar;
  int get clientesNuevosEsteMes => _clientesNuevosEsteMes;
  List<PieChartSectionData> get customerPieData => _customerPieData;
  List<BarChartGroupData> get topCustomerBarData => _topCustomerBarData;
  List<String> get topCustomerNames => _topCustomerNames;

  // Constructor: Carga los datos iniciales
  ReportProvider() {
    fetchDataForFilter();
  }

  // --- MÉTODOS PÚBLICOS (Acciones) ---

  /// Actualiza el filtro seleccionado y notifica a los oyentes.
  void setFilter(String newFilter) {
    if (newFilter == _selectedFilter) return;

    _selectedFilter = newFilter;

    // Notificamos a todos los widgets que escuchan (Consumers) que
    // el filtro ha cambiado, para que puedan redibujarse.
    notifyListeners();

    // Inmediatamente después de cambiar el filtro, llamamos a la lógica
    // para cargar los nuevos datos.
    fetchDataForFilter();
  }

  /// Simula la carga de datos del backend.
  /// 2. Actualiza la carga de datos para SIMULAR datos
  /// MÉTODO ACTUALIZADO PARA INCLUIR DATOS DE INVENTARIO
  Future<void> fetchDataForFilter() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 750));
    final random = Random();

    // ... (Simulación de Resumen e Inventario se queda igual) ...
    _ventasData.clear();
    _comprasData.clear();
    int dataPoints = (_selectedFilter == 'Este mes') ? 30 : 7;
    for (int i = 0; i < dataPoints; i++) {
      _ventasData.add(FlSpot(i.toDouble(), random.nextDouble() * 1000 + 500));
      _comprasData.add(FlSpot(i.toDouble(), random.nextDouble() * 400 + 100));
    }
    _totalInventoryValue = random.nextDouble() * 150000 + 50000;
    _itemsOutOfStock = random.nextInt(5);
    _itemsLowStock = random.nextInt(15) + 5;
    _categorySections = [
      PieChartSectionData(value: 40, title: '40%', color: Colors.blue[400], titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      PieChartSectionData(value: 30, title: '30%', color: Colors.green[400], titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      PieChartSectionData(value: 20, title: '20%', color: Colors.orange[400], titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      PieChartSectionData(value: 10, title: '10%', color: Colors.red[400], titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ];
    _lowStockBarData = [];
    _lowStockProductNames = ['Tornillos 1/4', 'Clavos 2"', 'Pintura Blanca', 'Lija Fina', 'Destornillador'];
    for (int i = 0; i < _lowStockProductNames.length; i++) {
      _lowStockBarData.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: random.nextInt(10) + 2.toDouble(), color: Colors.amber[700], width: 16, borderRadius: BorderRadius.circular(4))]));
    }

    // --- (NUEVO) 5. Simulación de Datos de Clientes ---

    // KPIs
    _cuentasPorCobrar = random.nextDouble() * 5000 + 1000; // Ej. $1,000 - $6,000
    _clientesNuevosEsteMes = random.nextInt(20) + 5; // Ej. 5 - 25

    // Gráfico de Pastel (Nuevos vs. Recurrentes)
    double nuevosPct = random.nextDouble() * 30 + 10; // 10-40%
    double recurrentesPct = 100 - nuevosPct;
    _customerPieData = [
      PieChartSectionData(
        value: recurrentesPct,
        title: '${recurrentesPct.toStringAsFixed(0)}%',
        color: Colors.indigo[400],
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: nuevosPct,
        title: '${nuevosPct.toStringAsFixed(0)}%',
        color: Colors.teal[300],
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    // Gráfico de Barras (Top 5 Clientes)
    _topCustomerNames = ['Empresa A', 'Cliente Fiel', 'Constructora B', 'Sr. Pérez', 'Tienda XYZ'];
    _topCustomerBarData = [];
    for (int i = 0; i < _topCustomerNames.length; i++) {
      _topCustomerBarData.add(
        BarChartGroupData(
          x: i, // La posición vertical (0, 1, 2, 3, 4)
          barRods: [
            BarChartRodData(
              toY: random.nextDouble() * 2000 + 500, // El valor (longitud)
              color: Colors.indigo[300],
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    // --- Fin de la simulación ---

    _isLoading = false;
    notifyListeners();
  }
}




