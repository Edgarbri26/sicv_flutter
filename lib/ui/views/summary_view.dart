// lib/views/resumen_view.dart
import 'package:flutter/material.dart';
import 'package:sicv_flutter/providers/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

/// ResumenView
///
/// Esta es la pantalla principal del dashboard (índice 0).
/// Muestra los KPIs y gráficos principales.
///
/// Es un [Consumer] de [ReportProvider] para reaccionar a los cambios de estado.
class ResumeView extends StatelessWidget {
  const ResumeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para "escuchar" los cambios en ReportProvider.
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        // SingleChildScrollView permite hacer scroll si el contenido
        // no cabe en la pantalla (importante en móvil).
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // Columna principal que organiza la vista verticalmente.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SECCIÓN DE FILTROS ---
              _buildFilterSection(context, provider),
              const SizedBox(height: 16),

              // --- 2. SECCIÓN DE KPIs (AHORA RESPONSIVA) ---
              // Esta sección ahora usa GridView para adaptarse.
              _buildKpiSection(provider),
              const SizedBox(height: 24),

              // --- 3. SECCIÓN DE CONTENIDO PRINCIPAL (AHORA RESPONSIVA) ---
              // Usamos LayoutBuilder para decidir si mostrar
              // el layout de móvil (1 columna) o el de PC (2 columnas).
              LayoutBuilder(
                builder: (context, constraints) {
                  // Definimos un "breakpoint" (punto de quiebre).
                  // Si el ancho es mayor a 900px, es PC.
                  final bool isDesktop = constraints.maxWidth > 900;

                  if (isDesktop) {
                    // Si es PC, usamos el layout de 2 columnas.
                    return _buildDesktopContent(context, provider);
                  } else {
                    // Si es móvil, apilamos todo en 1 columna.
                    return _buildMobileContent(context, provider);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la UI para la sección de filtros.
  Widget _buildFilterSection(BuildContext context, ReportProvider provider) {
    // Un Row para alinear el texto "Filtrar por:" y el Dropdown.
    return Row(
      children: [
        const Text(
          'Filtrar por:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        
        // Expanded es VITAL aquí. Le dice al DropdownButton
        // que ocupe todo el espacio restante en el Row.
        Expanded(
          child: DropdownButton<String>(
            value: provider.selectedFilter,
            isExpanded: true, // Le dice al Dropdown que llene el Expanded.
            items: provider.filterOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                provider.setFilter(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  /// Construye la sección de tarjetas de KPIs.
  /// REESTRUCTURADO: Ahora usa GridView en lugar de Wrap.
  Widget _buildKpiSection(ReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Creamos la lista de tarjetas de KPI primero.
    // Conectarías los valores reales del provider aquí.
    final kpiCards = [
      _KpiCard(
        title: 'Ventas Totales',
        value: '\$1,250.00',
        icon: Icons.attach_money,
        color: Colors.green,
      ),
      _KpiCard(
        title: 'Compras Totales',
        value: '\$450.00',
        icon: Icons.shopping_cart,
        color: Colors.red,
      ),
      _KpiCard(
        title: 'Bajo Stock',
        value: '8 Productos',
        icon: Icons.warning_amber,
        color: Colors.orange,
      ),
      _KpiCard(
        title: 'Nuevos Clientes',
        value: '12',
        icon: Icons.person_add,
        color: Colors.blue,
      ),
    ];

    // LayoutBuilder nos da el ancho real (constraints) disponible.
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount; // Número de columnas
        double childAspectRatio; // Relación ancho/alto de las tarjetas

        // Decidimos cuántas columnas mostrar según el ancho.
        if (constraints.maxWidth < 600) {
          // Vista Móvil: 2 columnas
          crossAxisCount = 2;
          childAspectRatio = 1.8; // Tarjetas más altas que anchas
        } else {
          // Vista PC/Tablet: 4 columnas
          crossAxisCount = 4;
          childAspectRatio = 2.0; // Tarjetas más anchas que altas
        }

        // GridView es el widget correcto para una "cuadrícula".
        // A diferencia de Wrap, GridView *forzará* a los hijos
        // a tener el mismo ancho, llenando el espacio.
        return GridView.builder(
          // shrinkWrap y physics son necesarios porque GridView
          // está dentro de un SingleChildScrollView.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // Columnas
            crossAxisSpacing: 16.0,       // Espacio horizontal
            mainAxisSpacing: 16.0,        // Espacio vertical
            childAspectRatio: childAspectRatio, // Relación de aspecto
          ),
          itemCount: kpiCards.length,
          itemBuilder: (context, index) {
            return kpiCards[index];
          },
        );
      },
    );
  }

  /// NUEVO WIDGET: Contenido para la vista Móvil.
  /// Simplemente apila todo en una columna.
  Widget _buildMobileContent(BuildContext context, ReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Gráfico Principal ---
        Text(
          'Ventas vs Compras (${provider.selectedFilter})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildGraphSection(provider), // El gráfico de líneas
        const SizedBox(height: 24),

        // --- MÓDULO NUEVO 1 (para llenar espacio) ---
        Text(
          'Productos Más Vendidos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildTopProductsChart(context, provider), // Gráfico de torta
        const SizedBox(height: 24),

        // --- MÓDULO NUEVO 2 (para llenar espacio) ---
        Text(
          'Alertas de Stock',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildLowStockList(context, provider), // Lista de stock bajo
      ],
    );
  }

  /// NUEVO WIDGET: Contenido para la vista Desktop.
  /// Divide el contenido en 2 columnas (Row).
  Widget _buildDesktopContent(BuildContext context, ReportProvider provider) {
    // Usamos un Row para crear las columnas.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea al inicio (arriba)
      children: [
        // --- COLUMNA IZQUIERDA (Gráfico principal) ---
        // Expanded le dice a esta columna que ocupe una porción del Row.
        Expanded(
          flex: 3, // Ocupa 3 "partes" (ej. 60%) del espacio.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ventas vs Compras (${provider.selectedFilter})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildGraphSection(provider), // El gráfico de líneas
            ],
          ),
        ),
        const SizedBox(width: 16), // Espacio entre columnas

        // --- COLUMNA DERECHA (Nuevos módulos) ---
        // Esta columna ocupa el espacio restante.
        Expanded(
          flex: 2, // Ocupa 2 "partes" (ej. 40%) del espacio.
          child: Column(
            children: [
              // --- MÓDULO NUEVO 1 ---
              Text(
                'Productos Más Vendidos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildNetProfitChart(context, provider),// Gráfico de torta
              const SizedBox(height: 24),

              // --- MÓDULO NUEVO 2 ---
              Text(
                'Alertas de Stock',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildLowStockList(context, provider), // Lista de stock bajo
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el contenedor para el gráfico de líneas.
  /// (Este método no cambió, solo se movió)
  Widget _buildGraphSection(ReportProvider provider) {
    return Card(
      elevation: 2,
      child: Container(
        height: 300, // Aumenté la altura un poco para PC
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: provider.isLoading
              ? const CircularProgressIndicator()
              : provider.ventasData.isEmpty
                  ? const Text('No hay datos para este filtro')
                  : LineChart(
                      _buildChartData(provider),
                    ),
        ),
      ),
    );
  }

  /// Configuración del LineChart.
  /// (Este método no cambió)
  LineChartData _buildChartData(ReportProvider provider) {
    final Color ventasColor = Colors.green[400]!;
    final Color comprasColor = Colors.red[400]!;

    return LineChartData(
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xffe7e7e7), width: 1),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey[200],
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toInt()}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              // Ajusté el texto para que sea más genérico
              final label = provider.ventasData[value.toInt()].x;
              return Text(
                'D ${label.toInt() + 1}', // Asume que X es un índice
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        // --- Línea de Ventas ---
        LineChartBarData(
          spots: provider.ventasData,
          isCurved: true,
          color: ventasColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            // ignore: deprecated_member_use
            color: ventasColor.withOpacity(0.2),
          ),
        ),
        // --- Línea de Compras ---
        LineChartBarData(
          spots: provider.comprasData,
          isCurved: true,
          color: comprasColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            // ignore: deprecated_member_use
            color: comprasColor.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  // --- NUEVOS WIDGETS DE EJEMPLO (PLACEHOLDERS) ---

  /// EJEMPLO: Gráfico de Torta (PieChart)
  Widget _buildTopProductsChart(BuildContext context, ReportProvider provider) {
    return Card(
      elevation: 2,
      child: Container(
        // Altura fija para que los gráficos se vean ordenados
        height: 300, 
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Aquí puedes poner un PieChart\n(Top 5 Productos)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        // TODO: Implementa tu PieChart aquí usando fl_chart
        // child: PieChart(...),
      ),
    );
  }

  /// EJEMPLO: Lista de Stock Bajo (DataTable o ListView)
  Widget _buildLowStockList(BuildContext context, ReportProvider provider) {
    return Card(
      elevation: 2,
      child: Container(
        height: 300, // Altura fija
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Aquí puedes poner una DataTable\n(Los 8 productos con bajo stock)',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        // TODO: Implementa tu DataTable o ListView aquí
        // child: DataTable(...),
      ),
    );
  }
}

/// EJEMPLO: Gráfico de Barras de Ganancia Neta
Widget _buildNetProfitChart(BuildContext context, ReportProvider provider) {
  return Card(
    elevation: 2,
    child: Container(
      height: 300, 
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Aquí puedes poner un BarChart\n(Ganancia Neta por día)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // TODO: Implementa tu BarChart aquí
      // child: BarChart(...),
    ),
  );
}

/// EJEMPLO: Gráfico de Ventas por Usuario
Widget _buildSalesByUserChart(BuildContext context, ReportProvider provider) {
  return Card(
    elevation: 2,
    child: Container(
      height: 300, 
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Aquí puedes poner un PieChart\n(Ventas por Vendedor)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // TODO: Implementa tu PieChart aquí
      // child: PieChart(...),
    ),
  );
}

/// Widget privado para mostrar una tarjeta de KPI individual.
/// REESTRUCTURADO: Se eliminó ConstrainedBox.
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // ¡HEMOS QUITADO EL ConstrainedBox!
    // GridView ahora controla el tamaño y ancho de la tarjeta.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            // Expanded para que la columna de texto ocupe el resto
            // del espacio del Row dentro de la tarjeta.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Centra el texto
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis, // Evita desbordes
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis, // Evita desbordes
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}