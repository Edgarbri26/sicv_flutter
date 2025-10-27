import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/ui/screen/home/inventory_screen.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';
import 'package:sicv_flutter/ui/widgets/add_product_form.dart';

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
  final List<String> _screenTitles = ['Registro de Ventas', 'Registro de Compras', 'Gestión del Inventario'];

  final GlobalKey<PurchaseScreenState> _purchaseScreenKey = GlobalKey<PurchaseScreenState>();

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header with handle and title using app palette
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Text('Agregar Producto', style: TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.secondary),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: AddProductForm(),
                      ),
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
    SaleScreen(
      onProductAdded: _onProductAddedToSale,
    ),
    PurchaseScreen(key: _purchaseScreenKey),
    InventoryDatatableScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // 1. Apariencia limpia: Fondo blanco/claro y sin elevación marcada
        backgroundColor: Theme.of(context).colorScheme.surface, // Usa el color de fondo del tema
        surfaceTintColor: Colors.transparent, // Elimina el tinte al hacer scroll (Android 12+)
        elevation: 0, // 0 para un look plano y moderno

        // 2. Título estilizado
        title: Text(
          _screenTitles[_currentIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold, // Título en negrita
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface, // Color de texto basado en el tema
          ),
        ),
        
        // 3. Altura de la barra (opcional pero profesional)
        toolbarHeight: 64.0, // Un poco más de altura para un mejor 'feel'

        // 4. Integración con la interfaz de usuario (Buscador y Ajuste Manual)
        // Nota: Si el FAB (Ajuste Manual) está en la parte inferior, puedes dejar esto vacío.
        // Si deseas una acción de ícono en la AppBar, úsala aquí.
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.add_circle_outline),
          //   onPressed: () => _showAddMovementModal(context),
          //   tooltip: 'Registrar Ajuste Manual',
          // ),
          const SizedBox(width: 16), // Espacio al final
        ],
        
        // 5. Configuración de Tema (para íconos y otros elementos)
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary, // Íconos con color primario del tema
        ),
      ),
      drawer: const Menu(),

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
        type: BottomNavigationBarType.fixed, 

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
          onPressed: () => _purchaseScreenKey.currentState?.showProductSearchModal(),
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, color: AppColors.secondary),
        );
      case 2:
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
                        return ListTile(
                          title: Text(product.name),
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

