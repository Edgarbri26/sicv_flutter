import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// --- 1. MOCK PROVIDER ---
final inventoryReportProvider = Provider<InventoryState>((ref) {
  return InventoryState();
});

class InventoryState {
  final String totalInventoryValue = "45,230.00";
  final int totalItems = 1450;
  final int lowStockAlerts = 5;
  final String monthlyTurnover = "18%";

  final List<CategoryData> categoryDistribution = [
    CategoryData("Electrónica", 40, const Color(0xFF6366F1)),
    CategoryData("Ropa", 30, const Color(0xFF3B82F6)),
    CategoryData("Hogar", 15, const Color(0xFF10B981)),
    CategoryData("Otros", 15, const Color(0xFF9CA3AF)),
  ];

  final List<ProductMetric> topProducts = [
    ProductMetric("Laptop Dell G15", 120, 0.9),
    ProductMetric("iPhone 13 Pro", 95, 0.75),
    ProductMetric("Monitor LG 24'", 80, 0.6),
    ProductMetric("Mouse Logitech", 60, 0.45),
    ProductMetric("Teclado Mecánico", 45, 0.3),
  ];

  final List<StockAlert> lowStockItems = [
    StockAlert("Adaptador HDMI", 2, "Crítico"),
    StockAlert("Funda iPhone 13", 4, "Bajo"),
    StockAlert("Cargador USB-C", 5, "Bajo"),
  ];

  // <--- NUEVO: DATOS PARA MATRIZ DE EFICIENCIA
  // (Nombre, Stock Actual, Ventas Mensuales)
  final List<InventoryEfficiencyPoint> efficiencyData = [
    InventoryEfficiencyPoint("TV 50'", 150, 5),    // SOBRE-STOCK (Tengo muchos, vendo pocos)
    InventoryEfficiencyPoint("Cable USB", 10, 120), // RIESGO QUIEBRE (Tengo pocos, vendo muchos)
    InventoryEfficiencyPoint("Laptop HP", 40, 45),  // SALUDABLE (Equilibrado)
    InventoryEfficiencyPoint("Funda Vieja", 200, 2),// SOBRE-STOCK CRÍTICO (Hueso)
    InventoryEfficiencyPoint("Airpods", 15, 90),    // RIESGO
    InventoryEfficiencyPoint("Mouse Pad", 100, 80), // SALUDABLE (Alta rotación)
  ];
}

// <--- NUEVO: CLASE DE DATOS
class InventoryEfficiencyPoint {
  final String name;
  final double currentStock;
  final double monthlySales;
  InventoryEfficiencyPoint(this.name, this.currentStock, this.monthlySales);
}

class CategoryData {
  final String name;
  final double value;
  final Color color;
  CategoryData(this.name, this.value, this.color);
}

class ProductMetric {
  final String name;
  final int soldCount;
  final double percentage;
  ProductMetric(this.name, this.soldCount, this.percentage);
}

class StockAlert {
  final String name;
  final int quantity;
  final String level;
  StockAlert(this.name, this.quantity, this.level);
}

// --- 2. VISTA PRINCIPAL ---

class InventoryReportView extends ConsumerWidget {
  const InventoryReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(inventoryReportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildKpiGrid(context, data),
            const SizedBox(height: 24),

            // <--- NUEVO: SECCIÓN DE ANÁLISIS DE EFICIENCIA
            _ChartContainer(
              title: "Matriz de Eficiencia de Stock",
              subtitle: "Identifica Sobre-stock (Derecha/Abajo) y Riesgos de Quiebre (Izquierda/Arriba)",
              child: SizedBox(
                height: 350,
                child: _InventoryEfficiencyChart(points: data.efficiencyData),
              ),
            ),
            const SizedBox(height: 24),

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
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              "Valoración, stock y movimiento de productos",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.filter_list, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text("Todas las Categorías", style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, InventoryState data) {
    final kpis = [
      _KpiInfo("Valor Inventario", "\$${data.totalInventoryValue}", Icons.monetization_on_outlined, Colors.teal),
      _KpiInfo("Total Items", "${data.totalItems}", Icons.inventory_2_outlined, Colors.blue),
      _KpiInfo("Alertas Stock", "${data.lowStockAlerts}", Icons.warning_amber_rounded, Colors.red),
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
                child: Row(
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
          child: Column(
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

// --- 3. WIDGETS ESTILIZADOS ---

class _ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle; // <--- Agregado para explicar la gráfica
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
        boxShadow: [
          BoxShadow(
            color: isAlert ? Colors.red.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isAlert ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if(isAlert) ...[
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(info.icon, color: info.color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(info.title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }
}

// --- 4. GRÁFICOS Y LISTAS ---

// <--- NUEVO: GRÁFICO DE EFICIENCIA DE INVENTARIO
class _InventoryEfficiencyChart extends StatelessWidget {
  final List<InventoryEfficiencyPoint> points;

  const _InventoryEfficiencyChart({required this.points});

  @override
 Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        minX: 0,
        maxX: 250, 
        minY: 0,
        maxY: 150, 
        
        // BORRADO: rangeAnnotations (No soportado en ScatterChart)
        
        // CORRECCIÓN: Usamos el Grid para dibujar los límites de los cuadrantes
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          // Intervalos normales de la cuadrícula
          horizontalInterval: 50,
          verticalInterval: 50,
          
          // Personalizamos líneas específicas para marcar los UMBRALES DE RIESGO
          checkToShowHorizontalLine: (value) => true, // Mostrar todas
          getDrawingHorizontalLine: (value) {
            // Si la línea es el valor 10 (Umbral de venta baja), la pintamos ROJA y gruesa
            if (value == 10) {
              return FlLine(color: Colors.red.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5]);
            }
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
          
          checkToShowVerticalLine: (value) => true,
          getDrawingVerticalLine: (value) {
            // Si la línea es el valor 20 (Umbral de stock bajo), la pintamos ROJA y gruesa
            if (value == 20) {
              return FlLine(color: Colors.red.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5]);
            }
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Stock Actual (Unidades)", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true, 
              getTitlesWidget: (val, meta) => Text("${val.toInt()}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Ventas Mensuales", style: TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true, 
              reservedSize: 30,
              getTitlesWidget: (val, meta) => Text("${val.toInt()}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.1))),

        scatterSpots: points.map((point) {
          // Lógica de Colores Visual:
          Color color = Colors.blue.withOpacity(0.6);
          // Riesgo Quiebre: Poco stock (<20) y Alta Venta (>50)
          if (point.currentStock < 20 && point.monthlySales > 50) color = Colors.red;
          // Sobre-stock: Mucho stock (>100) y Baja Venta (<10)
          if (point.currentStock > 100 && point.monthlySales < 10) color = Colors.orange;

          return ScatterSpot(
            point.currentStock,
            point.monthlySales,
            dotPainter: FlDotCirclePainter(
              color: color,
              radius: (color == Colors.red || color == Colors.orange) ? 8 : 5,
              strokeWidth: 0,
            ),
          );
        }).toList(),

        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            // En 1.1.1 se usa getTooltipColor en lugar de tooltipBgColor
            getTooltipColor: (spot) => Colors.blueGrey,
            getTooltipItems: (ScatterSpot spot) {
               final match = points.firstWhere((p) => p.currentStock == spot.x && p.monthlySales == spot.y, orElse: () => InventoryEfficiencyPoint("?", 0,0));
               return XAxisTooltipItem(
                 text: "${match.name}\nStock: ${spot.x.toInt()} | Ventas: ${spot.y.toInt()}",
                 textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
               );
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

class _CategoryPieChart extends StatelessWidget {
  final List<CategoryData> categories;
  const _CategoryPieChart({required this.categories});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categories.map((cat) {
          return PieChartSectionData(
            color: cat.color,
            value: cat.value,
            title: '${cat.value.toInt()}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final List<CategoryData> categories;
  const _CategoryLegend({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: cat.color)),
              const SizedBox(width: 8),
              Text(cat.name, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              const Spacer(),
              Text("${cat.value}%", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TopProductsList extends StatelessWidget {
  final List<ProductMetric> products;
  const _TopProductsList({required this.products});

  @override
  Widget build(BuildContext context) {
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
                  Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                    index == 0 ? const Color(0xFF6366F1) : Colors.blue.withOpacity(0.7 - (index * 0.1)),
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

class _LowStockList extends StatelessWidget {
  final List<StockAlert> items;
  const _LowStockList({required this.items});

  @override
  Widget build(BuildContext context) {
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
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("Stock actual: ${item.quantity}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
                  style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}