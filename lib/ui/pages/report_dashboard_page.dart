// lib/pages/report_dashboard_page.dart
import 'package:flutter/material.dart';
// import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/icon_menu.dart';
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

class _ReportDashboardPageState extends State<ReportDashboardPage>
    with SingleTickerProviderStateMixin {
  /// Estado para rastrear la pestaña de navegación seleccionada (0 = Resumen).
  int _selectedIndex = 0;
  late TabController _tabController;

  final List<MenuItemData> _pageMenuItems = [
    MenuItemData(
      index: 0,
      label: 'Resumen',
      icon: Icons.dashboard_outlined,
      iconActive: Icons.dashboard,
    ),
    MenuItemData(
      index: 1,
      label: 'Finanzas',
      icon: Icons.bar_chart_outlined,
      iconActive: Icons.bar_chart,
    ),
    MenuItemData(
      index: 2,
      label: 'Inventario',
      icon: Icons.inventory_2_outlined,
      iconActive: Icons.inventory_2,
    ),
    MenuItemData(
      index: 3,
      label: 'Empleados',
      icon: Icons.people_outline,
      iconActive: Icons.people,
    ),
    MenuItemData(
      index: 4,
      label: 'Clientes',
      icon: Icons.person_outline,
      iconActive: Icons.person,
    ),
    MenuItemData(
      index: 5,
      label: 'Proveedores',
      icon: Icons.local_shipping_outlined,
      iconActive: Icons.local_shipping,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _pageMenuItems.length,
      vsync: this,
      initialIndex: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Lista de las vistas principales que se mostrarán.
  static final List<Widget> _mainViews = [
    const ResumeView(),
    const FinancesView(), // Esta vista contendrá tu código original
    const InventoryReportView(),
    const EmployeeReportView(),
    const ClientReportView(),
    const SupplierReportView(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > AppSizes.breakpoint;

        // Adaptive Layout: Scaffold handles both modes
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: !isWide
              ? AppBarApp(
                  title: 'Dashboard de Reportes',
                  // iconColor: AppColors.textPrimary,
                )
              : null,
          drawer: !isWide ? MySideBar(controller: widget.controller) : null,
          body: isWide
              ? WideLayout(
                  controller: widget.controller,
                  sideNavigationMenu: SideNavigationMenu(
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      _tabController.animateTo(index);
                    },
                    tabController: _tabController,
                    selectedIndex: _selectedIndex,
                    menuItems: _pageMenuItems,
                  ),
                  appbartitle: 'Dashboard de Reportes',
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _mainViews,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _mainViews,
                ),

          // _mainViews[_selectedIndex],
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
        _tabController.animateTo(index);
      },
      // Fixed es mejor cuando hay 4+ items
      type: BottomNavigationBarType.fixed,
      items: [
        ..._pageMenuItems.map(
          (item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.iconActive),
            label: item.label,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }
}
