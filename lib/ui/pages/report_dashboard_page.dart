// lib/pages/report_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/icon_menu.dart';
import 'package:sicv_flutter/ui/screen/report/anality_review.dart';
import 'package:sicv_flutter/ui/screen/report/clients_view.dart';
import 'package:sicv_flutter/ui/screen/report/finance_view.dart';
import 'package:sicv_flutter/ui/screen/report/provider_view.dart';
import 'package:sicv_flutter/ui/screen/report/summary_view.dart';
import 'package:sicv_flutter/ui/screen/report/employee_view.dart';
import 'package:sicv_flutter/ui/screen/report/inventory_view.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/side_naviation_menu.dart';
import 'package:sicv_flutter/ui/widgets/wide_layuout.dart';
import 'package:sidebarx/sidebarx.dart';

class ReportDashboardPage extends StatefulWidget {
  final SidebarXController controller;
  const ReportDashboardPage({super.key, required this.controller});

  @override
  State<ReportDashboardPage> createState() => _ReportDashboardPageState();
}

class _ReportDashboardPageState extends State<ReportDashboardPage> {
  /// Estado para rastrear la pestaña de navegación seleccionada (0 = Resumen).
  int _selectedIndex = 0;

  final List<MenuItemData> _pageMenuItems = [
    MenuItemData(index: 0, label: 'Resumen', icon: Icons.dashboard_outlined),
    MenuItemData(index: 1, label: 'Finanzas', icon: Icons.bar_chart_outlined),
    MenuItemData(
      index: 2,
      label: 'Inventario',
      icon: Icons.inventory_2_outlined,
    ),
    MenuItemData(index: 3, label: 'Empleados', icon: Icons.people_outline),
    MenuItemData(index: 4, label: 'Clientes', icon: Icons.person_outline),
    MenuItemData(
      index: 5,
      label: 'Proveedores',
      icon: Icons.local_shipping_outlined,
    ),
    MenuItemData(index: 6, label: 'Análisis', icon: Icons.analytics_outlined),
  ];

  /// Lista de las vistas principales que se mostrarán.
  static const List<Widget> _mainViews = [
    ResumeView(),
    FinancesView(), // Esta vista contendrá tu código original
    InventoryReportView(),
    EmployeeReportView(),
    ClientReportView(),
    SupplierReportView(),
    AnalyticsReportView(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > AppSizes.breakpoint;
        return Scaffold(
          appBar: !isWide
              ? AppBarApp(
                  title: 'Dashboard de Reportes',
                  iconColor: AppColors.textPrimary,
                )
              : null,
          drawer: !isWide ? MySideBar(controller: widget.controller) : null,
          body: isWide
              ? WideLayout(
                  controller: widget.controller,
                  sideNavigationMenu: SideNavigationMenu(
                    selectedIndex: _selectedIndex,
                    menuItems: _pageMenuItems,
                  ),
                  appbartitle: 'Dashboard de Reportes',
                  child: _mainViews[_selectedIndex],
                )
              : _mainViews[_selectedIndex],

          bottomNavigationBar: !isWide ? _buildMobileBottomNavigation() : null,
        );
      },
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
          label: 'Empleados',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Proveedores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Análisis',
        ),
      ],
    );
  }
}
