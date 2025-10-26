// lib/views/finances_view.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

/// FinanzasView
///
/// Esta vista contiene la lógica original de tu `ReportPage`.
/// Se enfoca en mostrar las pestañas de Ventas y Compras.
///
/// Sigue siendo un [StatefulWidget] porque necesita manejar
/// su propio [TabController].
class FinancesView extends StatefulWidget {
  const FinancesView({super.key});

  @override
  _FinancesViewState createState() => _FinancesViewState();
}

class _FinancesViewState extends State<FinancesView>
    with SingleTickerProviderStateMixin {
  /// Controlador para las pestañas (Ventas/Compras).
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El Scaffold y el AppBar ya no son necesarios aquí,
    // porque esta vista se muestra DENTRO de ReportDashboardPage.
    // Simplemente devolvemos el Column con el contenido.
    return Column(
      children: [
        // --- SECCIÓN DE NAVEGACIÓN (VENTAS/COMPRAS) ---
        // Usamos Expanded para que esta sección ocupe todo el espacio
        // restante en la columna.
        Expanded(
          child: _buildTabbedNavigationView(),
        ),
      ],
    );
  }

  /// Construye la vista de navegación "tipo WhatsApp".
  /// (Este es tu método original, renombrado para claridad).
  Widget _buildTabbedNavigationView() {
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
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Theme.of(context).primaryColor,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: 'Ventas'),
              Tab(text: 'Compras'),
            ],
          ),
        ),

        // --- CONTENIDO DE LAS PESTAÑAS ---
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSalesList(),
              _buildPurchasesList(),
            ],
          ),
        ),
      ],
    );
  }

  /// (Tu método original)
  Widget _buildSalesList() {
    return ListView.builder(
      itemCount: 20,
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
            style:
                TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  /// (Tu método original)
  Widget _buildPurchasesList() {
    return ListView.builder(
      itemCount: 15,
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
            style:
                TextStyle(color: Colors.red[800], fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}