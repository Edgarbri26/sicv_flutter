// lib/pages/report_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/screen/report/clients_view.dart';
import 'package:sicv_flutter/ui/screen/report/finance_view.dart';
import 'package:sicv_flutter/ui/screen/report/inventory_view.dart';
import 'package:sicv_flutter/ui/screen/report/summary_view.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';

/// ReportDashboardPage
///
/// Este es el widget "contenedor" principal.
/// Es responsable de la navegación principal y la estructura responsiva.
///
/// Usa [LayoutBuilder] para detectar el ancho de la pantalla y decide
/// si mostrar un [NavigationRail] (para PC) o un [BottomNavigationBar] (para móvil).
class ReportDashboardPage extends StatefulWidget {
  const ReportDashboardPage({super.key});

  @override
  State<ReportDashboardPage> createState() => _ReportDashboardPageState();
}

class _ReportDashboardPageState extends State<ReportDashboardPage> {
  /// Estado para rastrear la pestaña de navegación seleccionada (0 = Resumen).
  int _selectedIndex = 0;

  /// Lista de las vistas principales que se mostrarán.
  static const List<Widget> _mainViews = [
    ResumeView(),
    FinancesView(),     // Esta vista contendrá tu código original
    InventoryView(),
    ClientsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Reportes'),
        elevation: 1,
      ),
      drawer: const MenuMovil(),
      // LayoutBuilder es la clave de la responsividad.
      // Nos da "constraints" (restricciones) del widget padre.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Punto de quiebre (breakpoint): 800 píxeles
          bool isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            // --- LAYOUT DE PC ---
            // Usamos un Row: [NavigationRail] | [Contenido]
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDesktopNavigationRail(),
                const VerticalDivider(thickness: 1, width: 1),
                // Expanded asegura que la vista de contenido
                // ocupe todo el espacio restante.
                Expanded(
                  child: _mainViews[_selectedIndex],
                ),
              ],
            );
          } else {
            // --- LAYOUT DE MÓVIL ---
            // Simplemente mostramos la vista de contenido.
            // La navegación se maneja en el bottomNavigationBar.
            return _mainViews[_selectedIndex];
          }
        },
      ),
      // Solo mostramos la barra inferior si NO es desktop.
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          if (isDesktop) {
            // No mostrar nada en PC
            return const SizedBox.shrink();
          } else {
            // Mostrar BottomNavigationBar en móvil
            return _buildMobileBottomNavigation();
          }
        },
      ),
    );
  }

  /// Construye la barra de navegación lateral para PC.
  Widget _buildDesktopNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      // Usar "all" o "selected" para mostrar/ocultar etiquetas
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Resumen'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Finanzas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Inventario'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Clientes'),
        ),
      ],
    );
  }

  /// Construye la barra de navegación inferior para Móvil.
  Widget _buildMobileBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      // Fixed es mejor cuando hay 4+ items
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Resumen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Finanzas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Clientes',
        ),
      ],
    );
  }
}