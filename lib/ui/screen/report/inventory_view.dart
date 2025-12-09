import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// 1. IMPORTA TU MODELO DE EFICIENCIA
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// 2. IMPORTA TU PROVIDER (Donde están InventoryState, ProductMetric, etc.)
import 'package:sicv_flutter/providers/report/inventory_provider.dart';
import 'package:sicv_flutter/ui/widgets/kpi_card.dart';
import 'package:sicv_flutter/ui/widgets/rerport/app_pie_chart.dart';
import 'package:sicv_flutter/ui/widgets/rerport/date_filter_selector.dart';

class InventoryReportView extends ConsumerWidget {
  const InventoryReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ESCUCHAMOS EL ESTADO (Datos + Loading)
    final state = ref.watch(inventoryReportProvider);
    
    // 2. LEEMOS EL NOTIFIER (Para ejecutar acciones de filtro)
    final notifier = ref.read(inventoryReportProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // AppColors.background
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER CON EL NUEVO SELECTOR ---
                  _buildHeader(context, notifier),
                  
                  const SizedBox(height: 32),

                  // Grid de KPIs
                  _buildKpiGrid(context, state),

                  const SizedBox(height: 24),

                  // --- GRÁFICO DE EFICIENCIA ---
                  ChartContainer(
                    title: "Matriz Rentabilidad vs Volumen",
                    subtitle: "Distribución de productos según su desempeño",
                    child: Column(
                      children: [
                        // Leyenda de colores
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _buildLegendItem(Colors.green, "Líderes", "Alta Venta / Alta Ganancia"),
                              _buildLegendItem(Colors.blue, "Alta Rotación", "Alta Venta / Baja Ganancia"),
                              _buildLegendItem(Colors.orange, "Alto Margen", "Baja Venta / Alta Ganancia"),
                              _buildLegendItem(Colors.red, "Bajo Desempeño", "Baja Venta / Baja Ganancia"),
                            ],
                          ),
                        ),
                        
                        // Scatter Chart
                        SizedBox(
                          height: 350,
                          child: state.efficiencyData.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No hay datos de ventas en este periodo.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : _InventoryEfficiencyChart(
                                  points: state.efficiencyData,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Layout Responsivo (Desktop/Mobile)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return _buildDesktopLayout(context, state);
                      } else {
                        return _buildMobileLayout(context, state);
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context, InventoryReportNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reporte de Inventario",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Valoración, eficiencia y niveles de stock",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        
        // --- AQUÍ USAMOS EL WIDGET REUTILIZABLE ---
        DateFilterSelector(
          selectedFilter: notifier.currentFilter,
          selectedDateRange: notifier.currentDateRange,
          onFilterChanged: (val) => notifier.setFilter(val),
          onDateRangeChanged: (range) => notifier.setDateRange(range),
        ),
      ],
    );
  }

  // --- Grid de KPIs ---
  Widget _buildKpiGrid(BuildContext context, InventoryState data) {
    final kpis = [
      KpiData(
        "Valor Inventario",
        "\$${data.totalInventoryValue}",
        Icons.monetization_on_outlined,
        Colors.teal,
      ),
      KpiData(
        "Total Items",
        "${data.totalItems}",
        Icons.inventory_2_outlined,
        Colors.blue,
      ),
      KpiData(
        "Alertas Stock",
        "${data.lowStockItems.length}",
        Icons.warning_amber_rounded,
        Colors.red,
      ),
      KpiData(
        "Rotación Mes",
        data.monthlyTurnover,
        Icons.sync_alt,
        Colors.orange,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 130,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => KpiCard(data: kpis[index]),
        );
      },
    );
  }

  // --- Layouts ---
  Widget _buildDesktopLayout(BuildContext context, InventoryState data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              ChartContainer(
                height: 396,
                title: "Distribución por Categoría",
                child: data.categoryDistribution.isEmpty
                    ? const Center(child: Text("Sin datos"))
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 290,
                              child: AppPieChart(
                                data: data.categoryDistribution,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: CategoryLegend(
                              categories: data.categoryDistribution,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              ChartContainer(
                title: "Alertas de Stock Bajo",
                child: _LowStockList(items: data.lowStockItems),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 5,
          child: ChartContainer(
            height: 640, // Altura fija para alinear con la columna izquierda
            title: "Top Productos Vendidos",
            child: _TopProductsList(products: data.topProducts),
          ),
        ),
      ],
    );
  }

  // --- Layout Mobile ---
  Widget _buildMobileLayout(BuildContext context, InventoryState data) {
    return Column(
      children: [
        ChartContainer(
          title: "Distribución por Categoría",
          child: data.categoryDistribution.isEmpty
              ? const Center(child: Text("Sin datos"))
              : Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: AppPieChart(data: data.categoryDistribution),
                    ),
                    const SizedBox(height: 20),
                    CategoryLegend(categories: data.categoryDistribution),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        ChartContainer(
          title: "Top Productos Vendidos",
          child: _TopProductsList(products: data.topProducts),
        ),
        const SizedBox(height: 24),
        ChartContainer(
          title: "Alertas de Stock Bajo",
          child: _LowStockList(items: data.lowStockItems),
        ),
      ],
    );
  }
}

// ==========================================
// 4. WIDGETS AUXILIARES
// ==========================================

class _TopProductsList extends StatelessWidget {
  final List<ProductMetric> products;
  const _TopProductsList({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Sin ventas en este periodo.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text("${prod.soldCount} Unds.", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prod.percentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    index == 0 ? const Color(0xFF6366F1) : Colors.blue.withOpacity((0.8 - (index * 0.05)).clamp(0.2, 1.0)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildLegendItem(Color color, String title, String subtitle) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    ],
  );
}

class _InventoryEfficiencyChart extends StatelessWidget {
  final List<InventoryEfficiencyPoint> points;

  const _InventoryEfficiencyChart({required this.points});

  @override
  Widget build(BuildContext context) {
    // Para el "Jitter" (Ruido visual aleatorio)
    final random = Random();

    double maxX = 0;
    double maxY = 0;
    for (var p in points) {
      if (p.quantitySold > maxX) maxX = p.quantitySold;
      if (p.totalProfit > maxY) maxY = p.totalProfit;
    }

    // Aseguramos mínimos para que el gráfico no crashee si está vacío
    maxX = (maxX <= 0 ? 10 : maxX) * 1.2;
    maxY = (maxY <= 0 ? 100 : maxY) * 1.2;

    // --- CAMBIO 1: UMBRALES MÁS SUAVES ---
    // Antes tenías * 0.4 (40%). Lo bajamos a 0.25 (25%) para que
    // sea más fácil que un producto sea considerado "Bueno" (Verde/Azul).
    final double targetSales = maxX * 0.25;
    final double targetProfit = maxY * 0.25;

    return ScatterChart(
      ScatterChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: maxX / 5,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Cantidad Vendida",
              style: TextStyle(fontSize: 10),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (val, meta) => Text(
                "${val.toInt()}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              "Ganancia (\$)",
              style: TextStyle(fontSize: 10),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (val, meta) => Text(
                val >= 1000
                    ? "${(val / 1000).toStringAsFixed(1)}k"
                    : "${val.toInt()}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        scatterSpots: points.map((point) {
          // Lógica de colores (igual que antes, pero usa los nuevos targets)
          Color color;
          bool highSales = point.quantitySold >= targetSales;
          bool highProfit = point.totalProfit >= targetProfit;

          if (highSales && highProfit) {
            color = Colors.green; // Líderes
          } else if (highSales && !highProfit) {
            color = Colors.blue; // Alta Rotación
          } else if (!highSales && highProfit) {
            color = Colors.orange; // Alto Margen
          } else {
            color = Colors.red; // Bajo Desempeño
          }

          // --- CAMBIO 2: JITTER (RUIDO VISUAL) ---
          // Generamos un pequeño número aleatorio entre -0.4 y +0.4
          // Esto hace que si tienes 10 productos con venta = 1,
          // no se pongan uno encima del otro, sino un poquito al lado.
          double jitterX = (random.nextDouble() * 0.8) - 0.4;

          // Opcional: Jitter en Y (Ganancia) muy leve
          double jitterY =
              (random.nextDouble() * (maxY * 0.02)) - (maxY * 0.01);

          return ScatterSpot(
            point.quantitySold + jitterX, // <--- Aplicamos Jitter X
            point.totalProfit + jitterY, // <--- Aplicamos Jitter Y
            dotPainter: FlDotCirclePainter(
              color: color.withOpacity(
                0.7,
              ), // Bajamos opacidad para ver superposiciones
              radius: (color == Colors.green || color == Colors.red) ? 8 : 6,
              strokeWidth: 0,
            ),
          );
        }).toList(),

        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipColor: (spot) => Colors.blueGrey,
            getTooltipItems: (ScatterSpot spot) {
              try {
                // Buscamos el punto original más cercano ignorando el jitter
                final match = points.firstWhere(
                  (p) =>
                      (p.quantitySold - spot.x).abs() <
                          0.6 && // Tolerancia aumentada por el jitter
                      (p.totalProfit - spot.y).abs() < (maxY * 0.05),
                  orElse: () => InventoryEfficiencyPoint(
                    name: "Item",
                    quantitySold: 0,
                    totalProfit: 0,
                  ),
                );
                return XAxisTooltipItem(
                  text:
                      "${match.name}\nVol: ${match.quantitySold.toInt()} | Gan: \$${match.totalProfit.toStringAsFixed(2)}",
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              } catch (e) {
                return null;
              }
            },
          ),
        ),
      ),
    );
  }
}

class XAxisTooltipItem extends ScatterTooltipItem {
  XAxisTooltipItem({required String text, required TextStyle textStyle})
    : super(text, textStyle: textStyle, bottomMargin: 10);
}

class ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool isAlert;
  final double? height;
  final double? width;
  const ChartContainer({
    super.key,
    required this.title,
    required this.child,
    this.isAlert = false,
    this.subtitle,
    this.height,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isAlert
                ? Colors.red.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isAlert
              ? Colors.red.withOpacity(0.2)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isAlert) ...[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class CategoryLegend extends StatelessWidget {
  final List<AppPieChartData> categories;
  const CategoryLegend({super.key, required this.categories});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categories
          .map(
            (cat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cat.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${cat.value}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LowStockList extends StatelessWidget {
  final List<StockAlert> items;
  const _LowStockList({required this.items});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return const Center(
        child: Text(
          "No hay alertas de stock.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (c, i) => Divider(color: Colors.grey.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory, color: Colors.red, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Stock actual: ${item.quantity}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.level.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

