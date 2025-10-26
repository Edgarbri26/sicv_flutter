import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/ui/pages/add_edit_inventory_page.dart';
import 'package:sicv_flutter/ui/pages/report_dashboard_page.dart';
import 'package:sicv_flutter/ui/pages/sale_page.dart';
import 'core/theme/app_themes.dart';
import 'ui/pages/home_page.dart';

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Inventario',
      theme: Themes.defaultTheme,
      home: const HomePage(),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (context) => const HomePage());
          case AppRoutes.sale:
            return MaterialPageRoute(builder: (context) => const SalePage());
          case AppRoutes.addEditInventory:
            return MaterialPageRoute(builder: (context) => const AddEditInventoryScreen());
          case AppRoutes.report:
            return MaterialPageRoute(builder: (context) => ReportDashboardPage());
          default:
            return MaterialPageRoute(builder: (context) => const SalePage());
        }
      },
    );
  }
}
