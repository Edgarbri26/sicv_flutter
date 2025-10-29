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
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/side_bar_app.dart';
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
          //appBar: AppBarApp(title:_screenTitles[_currentIndex], iconColor: AppColors.textPrimary,)
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
              color: AppColors.textPrimary,
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
