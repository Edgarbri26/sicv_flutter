// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';

/*
 * =============================================================================
 * CÓMO USAR ESTE ARCHIVO:
 * =============================================================================
 * * 1. Dependencias:
 * - Para los gráficos reales, necesitarás una biblioteca como 'fl_chart'.
 * Añade `fl_chart: ^0.68.0` (o la versión más reciente) a tu `pubspec.yaml`.
 * - Por ahora, se usa un placeholder (un contenedor) en lugar de un gráfico real.
 * * 2. Integración:
 * - Puedes llamar a `ReportPage()` desde cualquier parte de tu app, por ejemplo,
 * como el 'body' de un Scaffold en tu `main.dart` o en tu sistema de rutas.
 * * 3. Para ejecutar este archivo directamente (para pruebas):
 * - Crea un archivo `main.dart` y pega este código:
 * * import 'package:flutter/material.dart';
 * import 'report_page.dart'; // Asegúrate que el nombre del archivo coincida
 * * void main() {
 * runApp(MyApp());
 * }
 * * class MyApp extends StatelessWidget {
 * @override
 * Widget build(BuildContext context) {
 * return MaterialApp(
 * title: 'Reportes App',
 * theme: ThemeData(
 * primarySwatch: Colors.blue,
 * useMaterial3: true,
 * ),
 * home: Scaffold(
 * appBar: AppBar(
 * title: Text('Mis Reportes'),
 * ),
 * body: ReportPage(),
 * ),
 * debugShowCheckedModeBanner: false,
 * );
 * }
 * }
 */

/// ReportPage
///
/// Página principal que muestra reportes con gráficos filtrables en la parte
/// superior y una vista de pestañas (Ventas/Compras) en la parte inferior.
///
/// Se utiliza `StatefulWidget` para manejar el estado de:
/// 1. `_tabController`: Para controlar las pestañas de "Ventas" y "Compras".
/// 2. `_selectedFilter`: Para guardar el valor actual del filtro seleccionado.
///
/// Se usa `SingleTickerProviderStateMixin` para proveer el 'vsync' necesario
/// para la animación del `TabController`.
class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  /// Controlador para las pestañas de la parte inferior (Ventas/Compras).
  late TabController _tabController;

  /// Estado para el filtro seleccionado.
  String _selectedFilter = 'Últimos 7 días';

  /// Opciones disponibles para el filtro.
  final List<String> _filterOptions = [
    'Hoy',
    'Ayer',
    'Últimos 7 días',
    'Este mes',
    'Este año'
  ];

  @override
  void initState() {
    super.initState();
    // Inicializamos el TabController con 2 pestañas.
    // 'vsync: this' requiere el 'SingleTickerProviderStateMixin'.
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Es importante liberar los recursos del controller cuando el widget
    // es eliminado del árbol de widgets.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Column para dividir la pantalla verticalmente:
    // 1. Sección de Filtros
    // 2. Sección de Gráficos
    // 3. Sección de Navegación Inferior (que se expande)
    return Column(
      children: [
        // --- 1. SECCIÓN DE FILTROS ---
        _buildFilterSection(),

        // --- 2. SECCIÓN DE GRÁFICOS ---
        _buildGraphSection(),

        // --- 3. SECCIÓN DE NAVEGACIÓN INFERIOR (VENTAS/COMPRAS) ---
        // Usamos Expanded para que esta sección ocupe todo el espacio
        // restante en la columna.
        Expanded(
          child: _buildBottomNavigationView(),
        ),
      ],
    );
  }

  /// Construye la UI para la sección de filtros (parte superior).
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filtrar por:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          DropdownButton<String>(
            value: _selectedFilter,
            items: _filterOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              // Actualizamos el estado cuando el usuario cambia el filtro.
              // Esto redibujará el widget.
              setState(() {
                _selectedFilter = newValue!;
                // AQUÍ: Deberías llamar a la lógica para recargar los datos
                // de tus gráficos basándote en 'newValue'.
              });
            },
          ),
        ],
      ),
    );
  }

  /// Construye el contenedor para los gráficos (parte superior).
  /// [PLACEHOLDER]
  Widget _buildGraphSection() {
    // Este es un placeholder (marcador de posición).
    // Aquí es donde integrarías tu widget de gráficos (ej. LineChart de fl_chart).
    // El gráfico debería usar la variable `_selectedFilter` para mostrar
    // los datos correctos.
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          'Aquí va el gráfico\n(Datos para: $_selectedFilter)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ),
    );
  }

  /// Construye la vista de navegación inferior "tipo WhatsApp".
  /// Utiliza un TabBar (para los botones) y un TabBarView (para el contenido).
  Widget _buildBottomNavigationView() {
    return Column(
      children: [
        // --- BOTONES DE NAVEGACIÓN (TABS) ---
        Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: TabBar(
            controller: _tabController,
            // Estilo para el indicador (la pestaña seleccionada)
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Theme.of(context).primaryColor, // Color de pestaña activa
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white, // Color de texto de pestaña activa
            unselectedLabelColor:
                Colors.black54, // Color de texto de pestañas inactivas
            tabs: const [
              Tab(text: 'Ventas'),
              Tab(text: 'Compras'),
            ],
          ),
        ),

        // --- CONTENIDO DE LAS PESTAÑAS ---
        // Usamos Expanded para que el contenido de la pestaña
        // llene el espacio restante.
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Contenido de la Pestaña 1: Ventas
              _buildSalesList(),
              // Contenido de la Pestaña 2: Compras
              _buildPurchasesList(),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye la lista de ejemplo para la pestaña "Ventas".
  Widget _buildSalesList() {
    // Usamos ListView.builder para un rendimiento óptimo con listas largas.
    return ListView.builder(
      itemCount: 20, // Cantidad de elementos de ejemplo
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(Icons.arrow_upward, color: Colors.green[800]),
          ),
          title: Text('Venta #${20 - index}'),
          subtitle: Text('Cliente: Cliente Ejemplo ${index + 1}'),
          trailing: Text(
            '+\$${(index + 1) * 50}.00',
            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600),
          ),
          onTap: () {
            // Acción al tocar una venta
          },
        );
      },
    );
  }

  /// Construye la lista de ejemplo para la pestaña "Compras".
  Widget _buildPurchasesList() {
    return ListView.builder(
      itemCount: 15, // Cantidad de elementos de ejemplo
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red[100],
            child: Icon(Icons.arrow_downward, color: Colors.red[800]),
          ),
          title: Text('Compra #${15 - index}'),
          subtitle: Text('Proveedor: Proveedor Ejemplo ${index + 1}'),
          trailing: Text(
            '-\$${(index + 1) * 35}.00',
            style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.w600),
          ),
          onTap: () {
            // Acción al tocar una compra
          },
        );
      },
    );
  }
}