import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/config/app_routes.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/ui/pages/screen/inventory_screen.dart';
import 'package:sicv_flutter/ui/pages/screen/purchase_screen.dart';
import 'package:sicv_flutter/ui/pages/screen/sale_screen.dart';
import 'package:sicv_flutter/ui/widgets/detail_product_cart.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
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
  int _currentIndex = 0;

  // las pantallas que vamos a mostrar
  List<Widget> get _screens => [
    SaleScreen(saleItemsSelled: itemsSelled),
    PurchaseScreen(),
    InventoryScreen(),
  ];
  final List<String> _screenTitles = ['Venta', 'Compra', 'Inventario'];

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

  void _addNewItem() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => AddEditInventoryScreen()),
    // );
    Navigator.pushNamed(context, AppRoutes.addEditInventory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _screenTitles[_currentIndex],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
          textAlign: TextAlign.start,
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      drawer: const Menu(),

      // El 'body' ahora es un PageView
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,

        onTap: _onBottomNavTapped,

        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed, // Muestra todos los labels

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Venta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
        ],
      ),

      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Este método no necesita cambios, ya que depende de _currentIndex.
  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Pestaña venta
        return FloatingActionButton(
          onPressed: () => _mostrarDetallesDeMezcla(context),
          backgroundColor: AppColors.primary,
          child: Icon(Symbols.edit_arrow_up, color: AppColors.secondary),
        );
      case 1: // Pestaña compra
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: AppColors.secondary),
        );
      case 2: // Pestaña inventario
        return FloatingActionButton(
          onPressed: _addNewItem,
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5, // Empieza a la mitad de la pantalla
          minChildSize: 0.3, // Mínimo 30%
          maxChildSize: 0.9, // Máximo 90%
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

                  Text(
                    "Detalles de la Venta",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total: ${itemsSelled.length}",
                    style: AppTextStyles.bodyMediumBold,
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: itemsSelled.length,
                      itemBuilder: (context, index) {
                        return DetailProductCart(
                          item: itemsSelled[index],
                          onTap: () {},
                          onDelete: () {},
                          trailing: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.remove),
                              ),
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
  }
}
