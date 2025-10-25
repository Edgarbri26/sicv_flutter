import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/ui/pages/add_product_screen.dart';
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
  final List<Product> _itemsParaLaVenta = [];
  
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
  }
  // *** ¡PASO 1: CREA ESTA FUNCIÓN! ***
  // Esta función se llamará desde SaleScreen
  void _onProductAddedToSale(Product product) {
    setState(() {
      // Revisa si el producto ya está en el carrito
      final index = _itemsParaLaVenta.indexWhere((p) => p.id == product.id);

      if (index != -1) {
        // Si ya está, aumenta la cantidad (asumiendo que tu modelo Product tiene 'quantity')
        // (Nota: Tu modelo 'Product' no tiene 'quantity', 
        // tu 'InventoryItem' sí. ¡Deberías unificarlos!)
        
        // Por ahora, solo lo añadiremos de nuevo, pero lo ideal es manejar cantidades.
        // _itemsParaLaVenta[index].quantity++; 
        
        // (Como tu 'Product' no tiene cantidad, lo añadiremos de nuevo
        // para que veas el efecto)
        _itemsParaLaVenta.add(product);
        
      } else {
        // Si es nuevo, lo añade a la lista
        _itemsParaLaVenta.add(product);
      }
    });

    // Muestra un 'feedback' rápido
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido a la venta.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<Widget> get _screens => [
    // Pásale la función a SaleScreen
    SaleScreen(
      onProductAdded: _onProductAddedToSale,
    ),
    PurchaseScreen(), // (Haremos lo mismo para PurchaseScreen)
    InventoryDatatableScreen(),
  ];

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

  // *** ¡PASO 3: ACTUALIZA TU DraggableScrollableSheet! ***
  // Asegúrate de que usa la lista correcta (_itemsParaLaVenta)
  // Tu código original usa 'itemsSelled', lo cual es confuso.
  // Vamos a usar '_itemsParaLaVenta'
  void _mostrarDetallesDeMezcla(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // ... (el resto de tu código)
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          // ... (el resto de tu código)
          builder: (context, scrollController) {
            return Container(
              // ... (el resto de tu código)
              child: Column(
                children: [
                  // ... (el agarrador y el título)
                  
                  Text(
                    // Usa la lista correcta
                    "Total: ${_itemsParaLaVenta.length} items", 
                    style: AppTextStyles.bodyMediumBold,
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _itemsParaLaVenta.length, // Lista correcta
                      itemBuilder: (context, index) {
                        // ¡PROBLEMA!
                        // Tu 'DetailProductCart' espera un 'InventoryItem'
                        // pero tu lista es de 'Product'.
                        // Debes crear un 'DetailProductCart' que acepte 'Product'
                        // o (mejor) unificar tus modelos.
                        
                        // Por ahora, solo mostraré el nombre
                        final product = _itemsParaLaVenta[index];
                        return ListTile(
                          title: Text(product.name),
                          // (Aquí iría tu 'DetailProductCart' adaptado)
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

