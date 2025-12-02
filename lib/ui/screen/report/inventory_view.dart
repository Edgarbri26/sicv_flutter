import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// 1. IMPORTA TU MODELO DE EFICIENCIA
import 'package:sicv_flutter/models/report/inventory_efficiency.dart';

// 2. IMPORTA TU PROVIDER (Donde están InventoryState, ProductMetric, etc.)
import 'package:sicv_flutter/providers/report/inventory_provider.dart'; 

class InventoryReportView extends ConsumerWidget {
  const InventoryReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del provider
    final inventoryStateAsync = ref.watch(inventoryReportProvider);
    final currentFilter = ref.watch(inventoryFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: inventoryStateAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el reporte:\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.refresh(inventoryReportProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              )
            ],
          ),
        ),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref, currentFilter),
              const SizedBox(height: 32),
              
              // Grid de KPIs (Valor Real, Items Reales)
              _buildKpiGrid(context, data),
              
              const SizedBox(height: 24),

              // --- GRÁFICO DE EFICIENCIA (DATOS REALES) ---
              _ChartContainer(
                title: "Matriz Rentabilidad vs Volumen",
                subtitle: "Estrellas (Verde), Vacas (Azul), Interrogantes (Naranja), Perros (Rojo)",
                child: SizedBox(
                  height: 350,
                  child: data.efficiencyData.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay datos de ventas en este periodo.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : _InventoryEfficiencyChart(points: data.efficiencyData),
                ),
              ),
              const SizedBox(height: 24),

              // Layout Responsivo
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return _buildDesktopLayout(context, data);
                  } else {
                    return _buildMobileLayout(context, data);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context, WidgetRef ref, String currentFilter) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentFilter,
              icon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: 'week', child: Text("Última Semana")),
                DropdownMenuItem(value: 'month', child: Text("Último Mes")),
                DropdownMenuItem(value: 'year', child: Text("Último Año")),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(inventoryFilterProvider.notifier).state = val;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Grid de KPIs ---
  Widget _buildKpiGrid(BuildContext context, InventoryState data) {
    final kpis = [
      _KpiInfo("Valor Inventario", "\$${data.totalInventoryValue}", Icons.monetization_on_outlined, Colors.teal),
      _KpiInfo("Total Items", "${data.totalItems}", Icons.inventory_2_outlined, Colors.blue),
      _KpiInfo("Alertas Stock", "${data.lowStockItems.length}", Icons.warning_amber_rounded, Colors.red),
      _KpiInfo("Rotación Mes", data.monthlyTurnover, Icons.sync_alt, Colors.orange),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
      double ratio = constraints.maxWidth < 600 ? 1.5 : 2.2;
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ratio,
        ),
        itemCount: kpis.length,
        itemBuilder: (context, index) => _KpiCard(info: kpis[index]),
      );
    });
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
              _ChartContainer(
                title: "Distribución por Categoría",
                child: data.categoryDistribution.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Sin datos de categorías")))
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: _CategoryPieChart(categories: data.categoryDistribution),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _CategoryLegend(categories: data.categoryDistribution),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 24),
              _ChartContainer(
                title: "Alertas de Stock Bajo",
                isAlert: true,
                child: _LowStockList(items: data.lowStockItems),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _ChartContainer(
            title: "Top Productos Vendidos",
            // AQUÍ SE USA EL WIDGET ACTUALIZADO
            child: _TopProductsList(products: data.topProducts),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, InventoryState data) {
    return Column(
      children: [
        _ChartContainer(
          title: "Distribución por Categoría",
          child: data.categoryDistribution.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Sin datos de categorías")))
            : Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: _CategoryPieChart(categories: data.categoryDistribution),
                  ),
                  const SizedBox(height: 20),
                  _CategoryLegend(categories: data.categoryDistribution),
                ],
              ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Top Productos Vendidos",
          // AQUÍ SE USA EL WIDGET ACTUALIZADO
          child: _TopProductsList(products: data.topProducts),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
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
    // Validación de lista vacía
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Aún no hay productos vendidos en este periodo.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
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
                    child: Text(
                      prod.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${prod.soldCount} Unds.",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
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
                    index == 0 
                        ? const Color(0xFF6366F1) 
                        : Colors.blue.withOpacity(
                            // FIX: Usamos clamp para asegurar que la opacidad nunca sea menor a 0.2 ni mayor a 1.0
                            (0.8 - (index * 0.05)).clamp(0.2, 1.0)
                          ),
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

class _InventoryEfficiencyChart extends StatelessWidget {
  final List<InventoryEfficiencyPoint> points;

  const _InventoryEfficiencyChart({required this.points});

  @override
  Widget build(BuildContext context) {
    double maxX = 0;
    double maxY = 0;
    for (var p in points) {
      if (p.quantitySold > maxX) maxX = p.quantitySold;
      if (p.totalProfit > maxY) maxY = p.totalProfit;
    }
    
    maxX = (maxX <= 0 ? 10 : maxX) * 1.2;
    maxY = (maxY <= 0 ? 100 : maxY) * 1.2;

    final double targetSales = maxX * 0.4;   
    final double targetProfit = maxY * 0.4; 

    return ScatterChart(
      ScatterChartData(
        minX: 0, maxX: maxX, minY: 0, maxY: maxY, 
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: maxX / 5,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Cantidad Vendida", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (val, meta) => Text("${val.toInt()}", style: const TextStyle(fontSize: 10, color: Colors.grey))),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Ganancia (\$)", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (val, meta) => Text(val >= 1000 ? "${(val/1000).toStringAsFixed(1)}k" : "${val.toInt()}", style: const TextStyle(fontSize: 10, color: Colors.grey))),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.1))),
        scatterSpots: points.map((point) {
          Color color;
          bool highSales = point.quantitySold >= targetSales;
          bool highProfit = point.totalProfit >= targetProfit;
          if (highSales && highProfit) color = Colors.green;
          else if (highSales && !highProfit) color = Colors.blue;
          else if (!highSales && highProfit) color = Colors.orange;
          else color = Colors.red;

          return ScatterSpot(
            point.quantitySold, point.totalProfit,  
            dotPainter: FlDotCirclePainter(color: color, radius: (color == Colors.green || color == Colors.red) ? 8 : 6, strokeWidth: 0),
          );
        }).toList(),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipColor: (spot) => Colors.blueGrey,
            getTooltipItems: (ScatterSpot spot) {
              try {
                 final match = points.firstWhere(
                   (p) => (p.quantitySold - spot.x).abs() < 0.1 && (p.totalProfit - spot.y).abs() < 0.1, 
                   orElse: () => InventoryEfficiencyPoint(name: "Item", quantitySold: 0, totalProfit: 0)
                 );
                 return XAxisTooltipItem(text: "${match.name}\nVol: ${spot.x.toInt()} | Gan: \$${spot.y.toStringAsFixed(2)}", textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11));
              } catch (e) { return null; }
            },
          ),
        ),
      ),
    );
  }
}

class XAxisTooltipItem extends ScatterTooltipItem {
  XAxisTooltipItem({required String text, required TextStyle textStyle}) : super(text, textStyle: textStyle, bottomMargin: 10);
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool isAlert;
  const _ChartContainer({required this.title, required this.child, this.isAlert = false, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isAlert ? Colors.red.withOpacity(0.05) : Colors.grey.withOpacity(0.05), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isAlert ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if(isAlert) ...[const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20), const SizedBox(width: 8)],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
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

class _KpiInfo {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _KpiInfo(this.title, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiInfo info;
  const _KpiCard({required this.info});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(info.icon, color: info.color, size: 20)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(info.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)), Text(info.title, style: TextStyle(fontSize: 12, color: Colors.grey[600]))])
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<CategoryData> categories;
  const _CategoryPieChart({required this.categories});
  @override
  Widget build(BuildContext context) {
    return PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: categories.map((cat) => PieChartSectionData(color: cat.color, value: cat.value, title: '${cat.value.toInt()}%', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))).toList()));
  }
}

class _CategoryLegend extends StatelessWidget {
  final List<CategoryData> categories;
  const _CategoryLegend({required this.categories});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: categories.map((cat) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: cat.color)), const SizedBox(width: 8), Expanded(child: Text(cat.name, style: const TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis)), Text("${cat.value}%", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]))]))).toList());
  }
}

class _LowStockList extends StatelessWidget {
  final List<StockAlert> items;
  const _LowStockList({required this.items});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text("No hay alertas de stock.", style: TextStyle(color: Colors.grey)));
    return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, separatorBuilder: (c, i) => Divider(color: Colors.grey.withOpacity(0.1)), itemBuilder: (context, index) {
        final item = items[index];
        return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory, color: Colors.red, size: 16)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text("Stock actual: ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 12))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.red.withOpacity(0.5)), borderRadius: BorderRadius.circular(4)), child: Text(item.level.toUpperCase(), style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)))]));
      });
  }
}