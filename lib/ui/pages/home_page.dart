import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/icon_menu.dart';
import 'package:sicv_flutter/ui/screen/home/inventory_screen.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart';

// Importaciones requeridas por tu widget 'Menu'
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/side_naviation_menu.dart';
import 'package:sicv_flutter/ui/widgets/wide_layuout.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends StatefulWidget {
  final SidebarXController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  final double breakpoint = 600.0;
  int _selectedIndex = 0;

  final List<MenuItemData> _pageMenuItems = [
    MenuItemData(
      icon: Icons.point_of_sale,
      iconActive: Icons.point_of_sale,
      label: 'Venta',
      index: 0,
    ),
    MenuItemData(
      icon: Icons.shopping_cart,
      iconActive: Icons.shopping_cart,
      label: 'Compra',
      index: 1,
    ),
    MenuItemData(
      icon: Icons.inventory,
      iconActive: Icons.inventory,
      label: 'Inventario',
      index: 2,
    ),
  ];

  final List<String> _screenTitles = [
    'Registro de Ventas',
    'Registro de Compras',
    'Gestión del Inventario',
  ];

  final GlobalKey<PurchaseScreenState> _purchaseScreenKey =
      GlobalKey<PurchaseScreenState>();
  final GlobalKey<InventoryDatatableScreenState> _inventoryScreenKey =
      GlobalKey<InventoryDatatableScreenState>();
  final GlobalKey<SaleScreenState> _saleScreenKey =
      GlobalKey<SaleScreenState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    _tabController = TabController(
      length: _screens.length,
      vsync: this,
      initialIndex: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: !isWide
              ? AppBarApp(title: _screenTitles[_selectedIndex])
              : null,

          drawer: isWide ? null : MySideBar(controller: widget.controller),
          body: isWide
              ? WideLayout(
                  controller: widget.controller,
                  appbartitle: _screenTitles[_selectedIndex],
                  sideNavigationMenu: SideNavigationMenu(
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    selectedIndex: _selectedIndex,
                    // onDestinationSelected: _navigateToPage,
                    tabController: _tabController,
                    pageController: _pageController,
                    menuItems: _pageMenuItems,
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Deshabilita swipe en PC
                    children: _screens,
                  ),
                )
              : _buildNarrowLayout(),
          bottomNavigationBar: isWide ? null : _buildBottomNavBar(),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  void _navigateToPage(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    //gracias a esto se soluciona el error de que no sincroniza el tabcontroller con el pageview y no se petatea
    if (mounted) {
      // Sincroniza el TabController
      _tabController.animateTo(index);

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  List<Widget> get _screens => [
    SaleScreen(key: _saleScreenKey),
    PurchaseScreen(key: _purchaseScreenKey),
    InventoryDatatableScreen(key: _inventoryScreenKey),
  ];

  /// El layout para pantallas angostas (móviles).
  Widget _buildNarrowLayout() {
    return PageView(
      controller: _pageController,
      onPageChanged: _navigateToPage,
      children: _screens,
    );
  }

  /// Construye el BottomNavigationBar (solo para modo angosto).
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _navigateToPage,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: _pageMenuItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _saleScreenKey.currentState?.showSaleDetail(context),
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
          onPressed: () => _inventoryScreenKey.currentState?.showProductForm(),
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: AppColors.secondary),
        );
      default:
        return null;
    }
  }
}
