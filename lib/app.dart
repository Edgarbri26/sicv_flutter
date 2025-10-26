import 'package:flutter/material.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/ui/pages/add_edit_inventory_page.dart';
import 'package:sicv_flutter/ui/pages/login_page.dart';
import 'package:sicv_flutter/ui/pages/report_inventory.dart';
import 'package:sicv_flutter/ui/pages/sale_page.dart';
import 'ui/pages/screen/config/company_screen.dart';
import 'ui/pages/screen/config/currency_screen.dart';
import 'ui/pages/screen/config/units_screen.dart';
import 'ui/pages/screen/config/categories_screen.dart';
import 'ui/pages/screen/config/stock_screen.dart';
import 'ui/pages/screen/config/roles_screen.dart';
import 'ui/pages/screen/config/users_screen.dart';
import 'ui/pages/screen/config/sku_screen.dart';
import 'ui/pages/screen/config/attributes_screen.dart';
import 'ui/pages/screen/config/backup_screen.dart';
import 'ui/pages/screen/config/theme_screen.dart';
import 'ui/pages/screen/config/notifications_screen.dart';
import 'core/theme/app_themes.dart';
import 'ui/pages/home_page.dart';

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Inventario',
      theme: Themes.defaultTheme,
      home: const LoginPage(),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (context) => const HomePage());
          case AppRoutes.sale:
            return MaterialPageRoute(builder: (context) => const SalePage());
          case AppRoutes.addEditInventory:
            return MaterialPageRoute(
              builder: (context) => const AddEditInventoryScreen(),
            );
          case AppRoutes.report:
            return MaterialPageRoute(builder: (context) => ReportPage());
          case AppRoutes.company:
            return MaterialPageRoute(
              builder: (context) => const CompanyScreen(),
            );
          case AppRoutes.currency:
            return MaterialPageRoute(
              builder: (context) => const CurrencyScreen(),
            );
          case AppRoutes.units:
            return MaterialPageRoute(builder: (context) => const UnitsScreen());
          case AppRoutes.categories:
            return MaterialPageRoute(
              builder: (context) => const CategoriesScreen(),
            );
          case AppRoutes.stock:
            return MaterialPageRoute(builder: (context) => const StockScreen());
          case AppRoutes.roles:
            return MaterialPageRoute(builder: (context) => const RolesScreen());
          case AppRoutes.users:
            return MaterialPageRoute(builder: (context) => const UsersScreen());
          case AppRoutes.sku:
            return MaterialPageRoute(builder: (context) => const SkuScreen());
          case AppRoutes.atributes:
            return MaterialPageRoute(
              builder: (context) => const AttributesScreen(),
            );
          case AppRoutes.backup:
            return MaterialPageRoute(
              builder: (context) => const BackupScreen(),
            );
          case AppRoutes.theme:
            return MaterialPageRoute(builder: (context) => const ThemeScreen());
          case AppRoutes.notifications:
            return MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            );
          default:
            return MaterialPageRoute(builder: (context) => const SalePage());
        }
      },
    );
  }
}
