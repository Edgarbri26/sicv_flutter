import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
// import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'dart:math';

// 1. IMPORTA TU MODELO DE EFICIENCIA
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// 2. IMPORTA TU PROVIDER (Donde están InventoryState, ProductMetric, etc.)
import 'package:sicv_flutter/providers/report/inventory_provider.dart';
import 'package:sicv_flutter/ui/widgets/report/chart_container.dart';
import 'package:sicv_flutter/ui/widgets/report/kpi_card.dart';
import 'package:sicv_flutter/ui/widgets/report/app_pie_chart.dart';
import 'package:sicv_flutter/ui/widgets/report/date_filter_selector.dart';
// import 'package:sicv_flutter/ui/widgets/report/kpi_grid.dart';

class InventoryReportView extends ConsumerWidget {
  const InventoryReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ESCUCHAMOS EL ESTADO (Datos + Loading)
    final state = ref.watch(inventoryReportProvider);

    // 2. LEEMOS EL NOTIFIER (Para ejecutar acciones de filtro)
    final notifier = ref.read(inventoryReportProvider.notifier);

    // final kpis = [
    //   KpiData(
    //     "Valor Inventario",
    //     "\$${state.totalInventoryValue}",
    //     Icons.monetization_on_outlined,
    //     Colors.teal,
    //   ),
    //   KpiData(
    //     "Total Items",
    //     "${state.totalItems}",
    //     Icons.inventory_2_outlined,
    //     Colors.blue,
    //   ),
    //   KpiData(
    //     "Alertas Stock",
    //     "${state.lowStockItems.length}",
    //     Icons.warning_amber_rounded,
    //     Colors.red,
    //   ),
    //   KpiData(
    //     "Mejor Producto",
    //     state.topProducts.first.name,
    //     Icons.star_border_outlined,
    //     Colors.orange,
    //   ),
    // ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
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
                    height: 520,
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
                              _buildLegendItem(
                                context,
                                Colors.green,
                                "Líderes",
                                "Alta Venta / Alta Ganancia",
                              ),
                              _buildLegendItem(
                                context,
                                Colors.blue,
                                "Alta Rotación",
                                "Alta Venta / Baja Ganancia",
                              ),
                              _buildLegendItem(
                                context,
                                Colors.orange,
                                "Alto Margen",
                                "Baja Venta / Alta Ganancia",
                              ),
                              _buildLegendItem(
                                context,
                                Colors.red,
                                "Bajo Desempeño",
                                "Baja Venta / Baja Ganancia",
                              ),
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
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Valoración, eficiencia y niveles de stock",
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 14,
              ),
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
        Theme.of(context).colorScheme.error,
      ),
      KpiData(
        "Mejor Producto",
        data.topProducts.isNotEmpty ? data.topProducts.first.name : "N/A",
        Icons.star_border,
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
      spacing: AppSizes.spacingL,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              ChartContainer(
                height:
                    670, // Altura fija para alinear con la columna izquierda
                title: "Top Productos Vendidos",
                child: _TopProductsList(
                  products: data.topProducts,
                  isScrollable: true,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            spacing: AppSizes.spacingL,
            children: [
              ChartContainer(
                height: 300,
                title: "Alertas de Stock Bajo",
                child: _LowStockList(
                  items: data.lowStockItems,
                  isScrollable: true,
                ),
              ),
              ChartContainer(
                height: 350,
                title: "Distribución por Categoría",
                child: data.categoryDistribution.isEmpty
                    ? const Center(child: Text("Sin datos"))
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 300,
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
            ],
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
  final bool isScrollable;
  const _TopProductsList({required this.products, this.isScrollable = false});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Sin ventas en este periodo.",
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      );
    }
    Widget list = ListView.builder(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
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
                    child: Text(
                      prod.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    "${prod.soldCount} Unds.",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prod.percentage,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    index == 0
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(
                            (0.8 - (index * 0.05)).clamp(0.2, 1.0),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return list;
  }
}

Widget _buildLegendItem(
  BuildContext context,
  Color color,
  String title,
  String subtitle,
) {
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
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10),
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
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            strokeWidth: 1,
          ),
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
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).hintColor,
                ),
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
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).hintColor,
                ),
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
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
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
  final bool isScrollable;
  const _LowStockList({required this.items, this.isScrollable = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No hay alertas de stock.",
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }
    Widget list = ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (c, i) =>
          Divider(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  color: Theme.of(context).colorScheme.error,
                  size: 16,
                ),
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
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.level.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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

    return list;
  }
}
