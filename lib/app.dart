import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/ui/pages/inventario_page.dart';
import 'package:sicv_flutter/ui/pages/login_page.dart';
import 'package:sicv_flutter/ui/pages/movements_page.dart';
import 'package:sicv_flutter/ui/pages/purchase_page.dart';
import 'package:sicv_flutter/ui/pages/report_dashboard_page.dart';
import 'package:sicv_flutter/ui/pages/sale_page.dart';
import 'package:sicv_flutter/ui/screen/config/role_screem.dart';
import 'package:sicv_flutter/ui/pages/settings_page.dart';
import 'package:sicv_flutter/ui/screen/config/client_screen.dart';
import 'package:sicv_flutter/ui/screen/config/depot_screen.dart';
import 'package:sicv_flutter/ui/screen/config/provider_screem.dart';
import 'package:sicv_flutter/ui/screen/config/type_payment_screen.dart';
import 'package:sicv_flutter/ui/screen/config/user_management.dart';
import 'package:sidebarx/sidebarx.dart';
import 'ui/screen/config/company_screen.dart';
import 'ui/screen/config/currency_screen.dart';
import 'ui/screen/config/units_screen.dart';
import 'ui/screen/config/categories_screen.dart';
import 'ui/screen/config/stock_screen.dart';
import 'ui/screen/config/sku_screen.dart';
import 'ui/screen/config/attributes_screen.dart';
import 'ui/screen/config/backup_screen.dart';
import 'ui/screen/config/theme_screen.dart';
import 'ui/screen/config/notifications_screen.dart';
// import 'ui/pages/settings_page.dart';
import 'package:sicv_flutter/ui/pages/splash/api_check_page.dart';
import 'core/theme/themes.dart';

class InventoryApp extends ConsumerWidget {
  InventoryApp({super.key});
  final _controller = SidebarXController(selectedIndex: 0, extended: true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Inventario',
      theme: Themes.defaultTheme,

      // darkTheme: Themes.darkTheme,
      themeMode: ThemeMode.system,
      home: const ApiCheckPage(),

      //HomePage(controller: _controller),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // case AppRoutes.home:
          //   _controller.selectIndex(0);
          //   return MaterialPageRoute(
          //     builder: (context) => HomePage(controller: _controller),
          //   );
          case AppRoutes.settings:
            // _controller.selectIndex(_controller.previousIndex);
            return MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            );

          case AppRoutes.inventory:
            // _controller.selectIndex(_controller.previousIndex);
            return MaterialPageRoute(
              builder: (context) => InventarioPage(controller: _controller),
            );

          case AppRoutes.sales:
            return MaterialPageRoute(
              builder: (context) => SalePage(controller: _controller),
            );

          case AppRoutes.purchase:
            return MaterialPageRoute(
              builder: (context) => PurchasePage(controller: _controller),
            );

          case AppRoutes.movements:
            return MaterialPageRoute(
              builder: (context) => MovementsPage(controller: _controller),
            );
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
            return MaterialPageRoute(
              builder: (context) => const RoleListView(),
            );
          case AppRoutes.users:
            return MaterialPageRoute(
              builder: (context) => AdminUserManagementPage(),
            );
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
          case AppRoutes.reportDashboard:
            return MaterialPageRoute(
              builder: (context) =>
                  ReportDashboardPage(controller: _controller),
            );
          case AppRoutes.client:
            return MaterialPageRoute(
              builder: (context) => ClientManagementPage(),
            );
          case AppRoutes.depot:
            return MaterialPageRoute(builder: (context) => DepotScreem());
          case AppRoutes.provider:
            return MaterialPageRoute(builder: (context) => ProviderScreem());

          case AppRoutes.typePayment:
            return MaterialPageRoute(
              builder: (context) => const TypePaymentScreen(),
            );
          case AppRoutes.login:
            return MaterialPageRoute(builder: (context) => const LoginPage());

          default:
            return MaterialPageRoute(
              builder: (context) => SalePage(controller: _controller),
            );
        }
      },
    );
  }
}
