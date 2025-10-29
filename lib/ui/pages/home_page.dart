import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/ui/screen/home/inventory_screen.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart';

// Importaciones requeridas por tu widget 'Menu'
import 'package:sicv_flutter/ui/pages/login_page.dart';
import 'package:sicv_flutter/ui/pages/movements_page.dart';
import 'package:sicv_flutter/ui/pages/report_dashboard_page.dart';
import 'package:sicv_flutter/ui/screen/config/settings_screen.dart';
import 'package:sicv_flutter/ui/screen/config/user_management.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';
// import 'package:sicv_flutter/ui/widgets/MyDrawer.dart'; // Ya no se usa
// import 'package:sicv_flutter/ui/widgets/my_side_nav_rail.dart'; // Ya no se usa

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// 1. Añadimos SingleTickerProviderStateMixin para el TabController
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController; // 2. Controlador para Tabs (escritorio)
  final double breakpoint = 650.0;
  int _currentIndex = 0;

  final List<IconMenu> bottomNavItems = [
    IconMenu(icon: Icons.point_of_sale, label: 'Venta'),
    IconMenu(icon: Icons.shopping_cart, label: 'Compra'),
    IconMenu(icon: Icons.inventory, label: 'Inventario'),
  ];

  // ... (Tus listas de itemsSelled, _itemsParaLaVenta, etc. se mantienen igual)
  List<InventoryItem> itemsSelled = [
    InventoryItem(
      id: '1',
      name: 'Harina PAN',
      description: 'Harina de maíz precocida',
      quantity: 50,
      price: 1.40,
      category: 'Alimentos',
      lastUpdated: DateTime.now(),
    ),
  ];
  final List<Product> _itemsParaLaVenta = [];
  final List<String> _screenTitles = [
    'Registro de Ventas',
    'Registro de Compras',
    'Gestión del Inventario',
  ];

  final GlobalKey<PurchaseScreenState> _purchaseScreenKey =
      GlobalKey<PurchaseScreenState>();
  final GlobalKey<InventoryDatatableScreenState> _inventoryScreenKey =
      GlobalKey<InventoryDatatableScreenState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // 3. Inicializamos ambos controladores
    _tabController = TabController(
      length: _screens.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose(); // 4. Hacemos dispose de ambos
    super.dispose();
  }

  // 5. Esta función se llama CUANDO SE HACE SWIPE (solo móvil)
  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    // Sincronizamos el TabController por si acaso
    _tabController.animateTo(index);
  }

  // 6. Esta es la nueva función "maestra" para NAVEGAR CON CLIC
  // (BottomNav, Menu lateral, TabBar superior)
  void _navigateToPage(int index) {
    if (_currentIndex == index) return; 

    setState(() {
      _currentIndex = index;
    });

    // Anima el TabBarView (seguro para PC y móvil)
    _tabController.animateTo(index);

    // ¡LA CORRECCIÓN ESTÁ AQUÍ!
    // Solo anima el PageView si existe (si hasClients es true)
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onProductAddedToSale(Product product) {
    // ... (tu lógica de añadir producto se mantiene igual)
    setState(() {
      final index = _itemsParaLaVenta.indexWhere((p) => p.id == product.id);

      if (index != -1) {
        _itemsParaLaVenta.add(product);
      } else {
        _itemsParaLaVenta.add(product);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido a la venta.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<Widget> get _screens => [
        SaleScreen(onProductAdded: _onProductAddedToSale),
        PurchaseScreen(key: _purchaseScreenKey),
        InventoryDatatableScreen(key: _inventoryScreenKey),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= breakpoint;

        // 7. Quitamos el DefaultTabController
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            // 8. Pasamos el TabController y la función de Tap
            /*bottom: isWide
                ? null
                : TabBar(
                    controller: _tabController,
                    onTap: _navigateToPage, // Usamos la nueva función
                    tabs: bottomNavItems
                        .map(
                          (item) =>
                              Tab(icon: Icon(item.icon), text: item.label),
                        )
                        .toList(),
                  ),*/
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _screenTitles[_currentIndex],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            toolbarHeight: 64.0,
            actions: [const SizedBox(width: 16)],
            iconTheme: IconThemeData(
              color: AppColors.secondary,
            ),
          ),

          // 9. Lógica del Drawer: Si es angosto, usa el Menu widget
          // 9. Lógica del Drawer: Si es angosto, usa el MyDrawer original
          drawer: isWide ? null : const MenuMovil(),

          // 10. Pasamos el TabController al layout de escritorio
          body: isWide
              ? _buildWideLayout(_tabController)
              : _buildNarrowLayout(),

          // 11. El BottomNavBar (móvil) usa la nueva función de navegación
          bottomNavigationBar: isWide ? null : _buildBottomNavBar(),

          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  /// El layout para pantallas angostas (móviles).
  Widget _buildNarrowLayout() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged, // Se activa con swipe
      children: _screens,
    );
  }

  /// El layout para pantallas anchas (desktop/tablet).
  // 12. Acepta el TabController
  Widget _buildWideLayout(TabController tabController) {
    return Row(
      children: [
        // 13. Reemplazamos MySideNavRail con tu Menu, dándole un ancho
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: _buildMenuWidget(context),
        ),
        const VerticalDivider(thickness: 1, width: 1),

        // El contenido principal
        Expanded(
          child: TabBarView(
            controller: tabController, // Usa el controller
            physics:
                const NeverScrollableScrollPhysics(), // Deshabilita swipe en PC
            children: _screens,
          ),
        ),
      ],
    );
  }

  /// Construye el BottomNavigationBar (solo para modo angosto).
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _navigateToPage, // 14. Usa la nueva función de navegación
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: bottomNavItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }

  /// 15. Nuevo Helper para construir tu widget Menu
  Widget _buildMenuWidget(BuildContext context) {
    return AppSidebar(
      currentIndex: _currentIndex,
      onItemSelected: _navigateToPage, // Pasa la función de navegación
      // Asumimos que HomePage es la ruta principal.
      // Ajusta esto si 'HomePage' vive en una ruta nombrada específica.
      currentPageRoute: '/',
    );
  }

  Widget? _buildFloatingActionButton() {
    // ... (Tu lógica de FAB se mantiene igual)
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _mostrarDetallesDeMezcla(context),
          backgroundColor: AppColors.primary,
          child: Icon(Symbols.edit_arrow_up, color: AppColors.secondary),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () =>
              _purchaseScreenKey.currentState?.showProductSearchModal(),
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: AppColors.secondary),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => _inventoryScreenKey.currentState?.addNewProduct(),
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: AppColors.secondary),
        );
      default:
        return null;
    }
  }

  void _mostrarDetallesDeMezcla(BuildContext context) {
    // ... (Tu lógica de showModalBottomSheet se mantiene igual)
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          builder: (context, scrollController) {
            return Container(
              child: Column(
                children: [
                  Text(
                    "Total: ${_itemsParaLaVenta.length} items",
                    style: AppTextStyles.bodyMedium,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _itemsParaLaVenta.length,
                      itemBuilder: (context, index) {
                        final product = _itemsParaLaVenta[index];
                        return ListTile(title: Text(product.name));
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class IconMenu {
  final IconData icon;
  final String label;

  IconMenu({required this.icon, required this.label});
}

// =========================================================================
// 16. TU WIDGET 'Menu' PEGADO AQUÍ PARA QUE EL ARCHIVO COMPILE
// =========================================================================

class AppSidebar extends StatelessWidget {
  // Propiedades requeridas para la navegación de HomePage
  final int currentIndex;
  final Function(int) onItemSelected;

  // Propiedad para resaltar rutas que no sean del PageView (Reportes, Config)
  final String currentPageRoute;

  const AppSidebar({
    super.key,
    this.currentPageRoute = '',
    required this.currentIndex,
    required this.onItemSelected,
  });

  // Ítems de navegación principales (coinciden con el PageView de HomePage)
  final List<Map<String, dynamic>> _pageMenuItems = const [
    {'title': 'Venta', 'icon': Icons.point_of_sale, 'index': 0},
    {'title': 'Compra', 'icon': Icons.shopping_cart, 'index': 1},
    {'title': 'Inventario', 'icon': Icons.inventory, 'index': 2},
  ];

  @override
  Widget build(BuildContext context) {
    // Definición de datos de usuario simulados
    const String userName = "Usuario Real";
    const String userEmail = "usuario@ejemplo.com";
    final String userInitials =
        userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?';

    // 1. EL CAMBIO CLAVE: Usamos un Container en lugar de Drawer.
    // El tamaño (ancho) lo define el ConstrainedBox en HomePage.
    return Container(
      width: double.infinity,
      color: Colors.white, // O AppColors.background si prefieres
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header de Usuario
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white), // Asegura texto blanco
            ),
            accountEmail: Text(userEmail, style: TextStyle(color: Colors.white70)), // Asegura texto blanco
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Text(
                userInitials,
                style: const TextStyle(
                  fontSize: 40.0,
                  color: AppColors.primary,
                ),
              ),
            ),
            decoration: const BoxDecoration(color: AppColors.primary),
          ),

          // --- ÍTEMS DE NAVEGACIÓN (Venta, Compra, Inventario) ---
          ..._pageMenuItems.map((item) {
            final int itemIndex = item['index'] as int;

            return _buildMenuItem(
              context: context,
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              isSelected:
                  itemIndex == currentIndex, // Resalta según el PageView
              onTap: () {
                // Llama a la función de HomePage para cambiar de página
                onItemSelected(itemIndex);
              },
              // No pasamos 'route' aquí, ya que la navegación es interna (PageView)
            );
          }),

          const Divider(thickness: 1),

          // --- ÍTEMS DE NAVEGACIÓN DE RUTAS (Reportes, Usuarios, Configuración) ---

          // Ítem: Reportes
          _buildMenuItem(
            context: context,
            icon: Icons.assessment_outlined,
            title: 'Reportes',
            route: '/reports', // Usamos la ruta para resaltar
            currentPageRoute: currentPageRoute,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReportDashboardPage()),
              );
            },
          ),

          // Ítem: Administrar Usuarios
          /*_buildMenuItem(
            context: context,
            icon: Icons.group_outlined,
            title: 'Administrar usuarios',
            route: '/users',
            currentPageRoute: currentPageRoute,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminUserManagementPage()),
              );
            },
          ),*/

          // Ítem: Administrar Movimientos
          _buildMenuItem(
            context: context,
            icon: Icons.compare_arrows,
            title: 'Administrar movimientos',
            route: '/movements', // Usa una ruta única
            currentPageRoute: currentPageRoute,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MovementsPage()),
              );
            },
          ),

          const Divider(thickness: 1),

          // Ítem: Configuración
          _buildMenuItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Configuración',
            route: '/settings',
            currentPageRoute: currentPageRoute,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          // Ítem: Cerrar Sesión
          _buildMenuItem(
            context: context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  /// Helper para construir los ListTile del menú y manejar el estado 'selected'
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String route = '',
    String currentPageRoute = '',
    bool isSelected = false, // Lo usamos para los ítems del PageView
  }) {
    // Si la ruta no es PageView, usamos la comparación de rutas para resaltar
    if (route.isNotEmpty) {
      isSelected = route == currentPageRoute;
    }

    // Identificamos si es móvil o PC
    // Usamos el mismo breakpoint de HomePage
    final bool isMobile = MediaQuery.of(context).size.width < 650.0;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16, // Tamaño de fuente más estándar para menú
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        // --- LÓGICA CLAVE: Cierra el Drawer solo si es móvil ---
        if (isMobile) {
          // Si estamos en móvil, cerramos el drawer antes de navegar
          // Comprobamos si el drawer está abierto antes de hacer pop
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        }

        // Pequeña espera para una transición más suave (opcional)
        Future.delayed(const Duration(milliseconds: 150), onTap);
      },
    );
  }

  // (Mantenemos tu función _showLogoutConfirmation)
  void _showLogoutConfirmation(BuildContext context) {
    // ... (Tu código de _showLogoutConfirmation) ...
    // ...
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cierre de Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red[700]),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Si el drawer sigue abierto (solo posible en móvil), lo cerramos
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}