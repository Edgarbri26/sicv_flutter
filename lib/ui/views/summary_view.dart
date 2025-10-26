// lib/views/resumen_view.dart
import 'package:flutter/material.dart';
import 'package:sicv_flutter/providers/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

/// ResumenView
///
/// Esta es la pantalla principal del dashboard (índice 0).
/// Muestra los KPIs (Key Performance Indicators) y el gráfico principal.
///
/// Es un [Consumer] de [ReportProvider] para que pueda leer y
/// reaccionar a los cambios de estado (como el filtro).
class ResumeView extends StatelessWidget {
  const ResumeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para "escuchar" los cambios en ReportProvider.
    // Cada vez que llames a notifyListeners() en el provider,
    // este "builder" se volverá a ejecutar.
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        // Usamos un SingleChildScrollView para que en pantallas pequeñas
        // o si el contenido crece, se pueda hacer scroll.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SECCIÓN DE FILTROS ---
              // Reutilizamos el filtro, pero ahora está conectado al Provider.
              _buildFilterSection(context, provider),
              const SizedBox(height: 16),

              // --- 2. SECCIÓN DE KPIs ---
              // Un Wrap es responsivo: si no caben en una línea,
              // bajan a la siguiente. Perfecto para PC y móvil.
              _buildKpiSection(provider),
              const SizedBox(height: 24),

              // --- 3. SECCIÓN DE GRÁFICOS ---
              Text(
                'Ventas vs Compras (${provider.selectedFilter})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildGraphSection(provider),
            ],
          ),
        );
      },
    );
  }

  /// Construye la UI para la sección de filtros.
  /// Ahora recibe el [provider] para leer y actualizar el estado.
  Widget _buildFilterSection(BuildContext context, ReportProvider provider) {
    // Asegúrate de que tu DropdownButton esté envuelto en un Expanded
    // si está dentro de un Row.
    
    // EJEMPLO SI LO TIENES EN UN ROW:
    return Row(
      children: [
        const Text(
          'Filtrar por:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16), // Un poco de espacio
        
        // --- LA SOLUCIÓN ---
        Expanded(
          child: DropdownButton<String>(
            value: provider.selectedFilter,
            isExpanded: true, // <-- Importante: dile que se expanda
            items: provider.filterOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis), // Evita desbordes
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                provider.setFilter(newValue);
              }
            },
          ),
        ),
        // --- FIN DE LA SOLUCIÓN ---
      ],
    );

    // --- O SI EL DROPDOWN ESTABA SOLO ---
    // Si no tenías un Row, simplemente asegúrate de que isExpanded sea true
    /*
    return DropdownButton<String>(
      value: provider.selectedFilter,
      isExpanded: true, // <-- Asegúrate de que esto sea true
      items: provider.filterOptions.map((String value) {
        // ...
      }).toList(),
      onChanged: (newValue) {
        // ...
      },
    );
    */
  }

  /// Construye la sección de tarjetas de KPIs.
  Widget _buildKpiSection(ReportProvider provider) {
    // Si está cargando, mostramos un indicador en lugar de las tarjetas.
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Wrap(
      spacing: 16.0, // Espacio horizontal
      runSpacing: 16.0, // Espacio vertical
      children: [
        // (AQUÍ conectarías los datos reales desde el provider)
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
      ],
    );
  }

  /// Construye el contenedor para los gráficos.
  /// Lee el filtro desde el [provider].
  Widget _buildGraphSection(ReportProvider provider) {
    return Card(
      elevation: 2,
      child: Container(
        height: 250,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // 4. Mostramos el gráfico o un indicador de carga
          child: provider.isLoading
              ? const CircularProgressIndicator()
              : provider.ventasData.isEmpty
                  ? const Text('No hay datos para este filtro')
                  // 5. El widget principal del gráfico
                  : LineChart(
                      _buildChartData(provider), // Llama al método de configuración
                    ),
        ),
      ),
    );
  }

  /// 6. NUEVO MÉTODO: Configuración del LineChart
  LineChartData _buildChartData(ReportProvider provider) {
    // Definimos los colores
    final Color ventasColor = Colors.green[400]!;
    final Color comprasColor = Colors.red[400]!;

    return LineChartData(
      // --- Bordes ---
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xffe7e7e7), width: 1),
      ),
      // --- Cuadrícula (Grid) ---
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey[200],
          strokeWidth: 1,
        ),
      ),

      // --- Títulos (Ejes X e Y) ---
      titlesData: FlTitlesData(
        show: true,
        // Eje Y (Izquierda)
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45, // Espacio para los números
            getTitlesWidget: (value, meta) {
              // Muestra etiquetas de $
              return Text(
                '\$${value.toInt()}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
        // Eje X (Abajo)
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              // Muestra etiquetas de días (Día 1, Día 2...)
              return Text(
                'D ${value.toInt() + 1}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              );
            },
          ),
        ),
        // Ocultamos los ejes superior y derecho
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      // --- LOS DATOS (Las Líneas) ---
      lineBarsData: [
        // --- Línea de Ventas ---
        LineChartBarData(
          spots: provider.ventasData, // <-- Datos del Provider
          isCurved: true,
          color: ventasColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false), // Oculta los puntos
          belowBarData: BarAreaData(
            show: true,
            color: ventasColor.withOpacity(0.2), // Sombra bajo la línea
          ),
        ),
        // --- Línea de Compras ---
        LineChartBarData(
          spots: provider.comprasData, // <-- Datos del Provider
          isCurved: true,
          color: comprasColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: comprasColor.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}


/// Widget privado para mostrar una tarjeta de KPI individual.
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
    // Usamos ConstrainedBox para que en PC las tarjetas no sean
    // demasiado anchas, pero en móvil puedan ser más pequeñas.
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 250),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}