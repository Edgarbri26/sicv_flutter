import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

// --- PROVIDER SIMULADO ---
final supplierReportProvider = Provider<SupplierReportState>((ref) {
  return SupplierReportState();
});

class SupplierReportState {
  final String totalDebt = "5,400.00"; // Cuentas por pagar
  final int activeOrders = 3;
  final int totalSuppliers = 12;
  final String efficiency = "92%"; // Entregas a tiempo

  // Distribución de gastos por proveedor
  final List<SupplierPieData> costDistribution = [
    SupplierPieData("Samsung", 40, const Color(0xFF5C6BC0)), // Indigo
    SupplierPieData("Apple Inc", 30, const Color(0xFFAB47BC)), // Purple
    SupplierPieData("Xiaomi", 15, const Color(0xFFFF7043)),    // Deep Orange
    SupplierPieData("Logitech", 15, const Color(0xFF78909C)),  // Blue Grey
  ];

  // Lista de Deudas / Estado
  final List<SupplierRow> supplierStatus = [
    SupplierRow("Samsung Electronics", 2500, "Vencido", true),
    SupplierRow("Apple Distributor", 0, "Al día", false),
    SupplierRow("Xiaomi Global", 1200, "Por vencer", true),
    SupplierRow("Logitech Supply", 450, "Por vencer", true),
    SupplierRow("Cables & Co", 0, "Al día", false),
  ];
}

class SupplierPieData {
  final String name;
  final double value;
  final Color color;
  SupplierPieData(this.name, this.value, this.color);
}

class SupplierRow {
  final String name;
  final double debt;
  final String status;
  final bool hasDebt;
  SupplierRow(this.name, this.debt, this.status, this.hasDebt);
}

// --- VISTA PRINCIPAL ---

class SupplierReportView extends ConsumerWidget {
  const SupplierReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(supplierReportProvider);

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reporte de Proveedores",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "Gestión de compras, deudas y cadena de suministro",
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, SupplierReportState data) {
    final kpis = [
      _KpiInfo("Cuentas por Pagar", "\$${data.totalDebt}", Icons.money_off, Colors.red),
      _KpiInfo("Órdenes Activas", "${data.activeOrders}", Icons.local_shipping_outlined, Colors.blue),
      _KpiInfo("Total Proveedores", "${data.totalSuppliers}", Icons.storefront, Colors.indigo),
      _KpiInfo("Eficiencia Entrega", data.efficiency, Icons.timelapse, Colors.teal),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.0,
        ),
        itemCount: kpis.length,
        itemBuilder: (context, index) => _KpiCard(info: kpis[index]),
      );
    });
  }

  Widget _buildDesktopLayout(BuildContext context, SupplierReportState data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _ChartContainer(
            title: "Distribución de Compras",
            child: Row(
              children: [
                 Expanded(child: AspectRatio(aspectRatio: 1, child: _CostPieChart(data: data.costDistribution))),
                 const SizedBox(width: 16),
                 Expanded(child: _CostLegend(data: data.costDistribution)),
              ],
            )
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _ChartContainer(
            title: "Estado de Cuentas",
            child: _SupplierList(suppliers: data.supplierStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, SupplierReportState data) {
    return Column(
      children: [
        _ChartContainer(
          title: "Distribución de Compras",
          child: Column(
            children: [
              AspectRatio(aspectRatio: 1.3, child: _CostPieChart(data: data.costDistribution)),
              const SizedBox(height: 20),
              _CostLegend(data: data.costDistribution),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _ChartContainer(
          title: "Estado de Cuentas",
          child: _SupplierList(suppliers: data.supplierStatus),
        ),
      ],
    );
  }
}

// --- WIDGETS AUXILIARES (Replicados para independencia de archivo) ---

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartContainer({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 2, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(info.icon, color: info.color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(info.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(info.title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }
}

// --- GRÁFICOS Y LISTAS ESPECÍFICOS ---

class _CostPieChart extends StatelessWidget {
  final List<SupplierPieData> data;
  const _CostPieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 30,
        sections: data.map((item) {
          return PieChartSectionData(
            color: item.color,
            value: item.value,
            title: '${item.value.toInt()}%',
            radius: 40,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}

class _CostLegend extends StatelessWidget {
  final List<SupplierPieData> data;
  const _CostLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: item.color)),
              const SizedBox(width: 8),
              Text(item.name, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SupplierList extends StatelessWidget {
  final List<SupplierRow> suppliers;
  const _SupplierList({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: suppliers.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final item = suppliers[index];
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    item.status,
                    style: TextStyle(
                      color: item.status == "Vencido" ? Colors.red : (item.status == "Al día" ? Colors.green : Colors.orange),
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            Text(
               item.hasDebt ? "-\$${item.debt.toStringAsFixed(0)}" : "\$0",
               style: TextStyle(
                 fontWeight: FontWeight.bold, 
                 color: item.hasDebt ? Colors.red : Colors.grey
               ),
            ),
          ],
        );
      },
    );
  }
}