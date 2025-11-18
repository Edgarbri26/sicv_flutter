import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/icon_menu.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:sicv_flutter/ui/screen/home/inventory_screen.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';

// Importaciones requeridas por tu widget 'Menu'
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/detail_product_cart.dart';
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
  int _currentIndex = 0;

  final List<IconMenu> _pageMenuItems = [
    IconMenu(icon: Icons.point_of_sale, label: 'Venta', index: 0),
    IconMenu(icon: Icons.shopping_cart, label: 'Compra', index: 1),
    IconMenu(icon: Icons.inventory, label: 'Inventario', index: 2),
  ];

  final List<ProductModel> _itemsParaLaVenta = [];
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

    _tabController = TabController(
      length: _screens.length,
      vsync: this,
      initialIndex: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 5. Esta función se llama CUANDO SE HACE SWIPE (solo móvil)
  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  // 6. Esta es la nueva función "maestra" para NAVEGAR CON CLIC
  void _navigateToPage(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
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

  void _onProductAddedToSale(ProductModel product) {
    setState(() {
      final index = _itemsParaLaVenta.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _itemsParaLaVenta[index].quantity =
            _itemsParaLaVenta[index].quantity + 1;
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

  /// El layout para pantallas angostas (móviles).
  Widget _buildNarrowLayout() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: _screens,
    );
  }

  /// El layout para pantallas anchas (desktop/tablet).
  Widget _buildWideLayout(TabController tabController) {
    return Row(
      children: [
        MySideBar(controller: widget.controller),
        Expanded(
          child: Row(
            children: [
              _buildDesktopNavigationRail(),
              Expanded(
                child: Column(
                  children: [
                    AppBarApp(title: _screenTitles[_currentIndex]),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TabBarView(
                              controller: tabController, 
                              physics:
                                  const NeverScrollableScrollPhysics(), // Deshabilita swipe en PC
                              children: _screens,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye el BottomNavigationBar (solo para modo angosto).
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
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
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _mostrarDetallesDeVenta(context),
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

  void _mostrarDetallesDeVenta(BuildContext context) {
    double total = _itemsParaLaVenta.fold(
      0,
      (previousValue, element) =>
          previousValue + (element.quantity * element.price),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: AppColors.border, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Detalles de la Venta",
                          style: AppTextStyles.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: \$${total.toStringAsFixed(2)}",
                            style: AppTextStyles.bodyLarge,
                          ),
                          PrimaryButtonApp(text: "Confirmar", onPressed: () {}),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _itemsParaLaVenta.length,
                          itemBuilder: (context, index) {
                            final item = _itemsParaLaVenta[index];
                            return DetailProductCart(
                              item: item,
                              onTap: () {
                                _mostrarDialogoEditarCantidad(context, item, (
                                  nuevaCantidad,
                                ) {
                                  modalSetState(() {
                                    item.quantity = nuevaCantidad;
                                  });
                                });
                              },
                              onDelete: () {
                                modalSetState(() {
                                  _itemsParaLaVenta.removeAt(index);
                                });
                              },
                              trailing: Row(
                                children: [
                                  // ... (Iconos de añadir/quitar)
                                  // Nota: Estos botones también deberían usar modalSetState
                                  // si quieres que actualicen la UI en tiempo real.
                                ],
                              ),
                            );
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
      },
    );
  }
  /// [context] El BuildContext para mostrar el diálogo.
  /// [item] El item cuya cantidad se está modificando (asumo que tiene .cantidad).
  /// [onConfirm] Callback que se ejecuta con la nueva cantidad si se confirma.
  void _mostrarDialogoEditarCantidad(
    BuildContext context,
    ProductModel
    item, 
    Function(int) onConfirm,
  ) {
    final TextEditingController cantidadController = TextEditingController();
    cantidadController.text = item.quantity.toString();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Modificar Cantidad"),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Nueva cantidad",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                final int? nuevaCantidad = int.tryParse(cantidadController.text);

                if (nuevaCantidad != null && nuevaCantidad >= 0) {
                  onConfirm(nuevaCantidad);
                  Navigator.of(dialogContext).pop();
                } else {
                  // Opcional: Mostrar un error si el valor no es válido
                  // (ej: usando un SnackBar o moviendo la lógica a un validador)
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopNavigationRail() {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0,
      backgroundColor: AppColors.background,
      selectedIndex: _currentIndex,
      onDestinationSelected: _navigateToPage,
      destinations: [
        ..._pageMenuItems.map(
          (item) => NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.icon),
            label: Text(item.label),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: !isWide
              ? AppBar(
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
                  iconTheme: IconThemeData(color: AppColors.textPrimary),
                )
              : null,

          drawer: isWide ? null : MySideBar(controller: widget.controller),
          body: isWide
              ? _buildWideLayout(_tabController)
              : _buildNarrowLayout(),
          bottomNavigationBar: isWide ? null : _buildBottomNavBar(),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }
}
