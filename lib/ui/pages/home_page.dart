import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/ui/screen/home/inventory_screen.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart';
import 'package:sicv_flutter/ui/widgets/MyDrawer.dart';
import 'package:sicv_flutter/ui/widgets/my_side_nav_rail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  final double breakpoint = 650.0;
  int _currentIndex = 0;

  final List<IconMenu> bottomNavItems = [
    IconMenu(icon: Icons.point_of_sale, label: 'Venta'),
    IconMenu(icon: Icons.shopping_cart, label: 'Compra'),
    IconMenu(icon: Icons.inventory, label: 'Inventario'),
  ];

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
    InventoryItem(
      id: '2',
      name: 'Cigarros Marlboro',
      description: 'Cigarros de tabaco rubio',
      quantity: 5,
      price: 5.99,
      category: 'Tabaco',
      lastUpdated: DateTime.now().subtract(Duration(days: 1)),
    ),
    InventoryItem(
      id: '3',
      name: 'Café',
      description: 'Café de granos',
      quantity: 0,
      price: 10.99,
      category: 'Bebidas',
      lastUpdated: DateTime.now().subtract(Duration(days: 1)),
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // cuando cambia de pagina
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // cuando tocan un boton de navegacion
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onProductAddedToSale(Product product) {
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
    // Usamos un LayoutBuilder como widget raíz para tomar TODAS
    // las decisiones de layout (drawer, body, bottomNav) en un solo lugar.
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. Definimos nuestro punto de decisión
        final bool isWide = constraints.maxWidth >= breakpoint;

        return DefaultTabController(
          initialIndex: _currentIndex,
          length: _screens.length,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              bottom: !isWide
                  ? null
                  : TabBar(
                      tabs: bottomNavItems
                          .map(
                            (item) =>
                                Tab(icon: Icon(item.icon), text: item.label),
                          )
                          .toList(),
                    ),
              // El AppBar sabe automáticamente si mostrar el ícono de 'menu'
              // basado en si la propiedad 'drawer' del Scaffold es nula o no.
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _screenTitles[_currentIndex],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              toolbarHeight: 64.0,
              actions: [const SizedBox(width: 16)],
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // 2. Lógica del Drawer
            // Si es ancho, NO hay drawer modal (null).
            // Si es angosto, SÍ hay drawer modal (Menu).
            drawer: isWide ? null : const MyDrawer(),

            // 3. Lógica del Body
            // Separamos la lógica en métodos para mayor claridad.
            body: isWide ? _buildWideLayout() : _buildNarrowLayout(),

            // 4. Lógica del BottomNavigationBar
            // Si es ancho, NO hay barra inferior (null).
            // Si es angosto, SÍ hay barra inferior.
            bottomNavigationBar: isWide ? null : _buildBottomNavBar(),

            floatingActionButton: _buildFloatingActionButton(),
          ),
        );
      },
    );
  }

  /// El layout para pantallas angostas (móviles).
  /// Solo muestra el PageView.
  Widget _buildNarrowLayout() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: _screens,
    );
  }

  /// El layout para pantallas anchas (desktop/tablet).
  /// Muestra el menú persistente a la izquierda.
  Widget _buildWideLayout() {
    return Row(
      children: [
        // El menú persistente
        const MySideNavRail(),
        const VerticalDivider(thickness: 1, width: 1),

        // El contenido principal
        Expanded(child: TabBarView(children: _screens)),
      ],
    );
  }

  /// Construye el BottomNavigationBar (solo para modo angosto).
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onBottomNavTapped,
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
      // [
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.point_of_sale),
      //     label: 'Venta',
      //   ),
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.shopping_cart),
      //     label: 'Compra',
      //   ),
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.inventory),
      //     label: 'Inventario',
      //   ),
      // ],
    );
  }

  Widget? _buildFloatingActionButton() {
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
