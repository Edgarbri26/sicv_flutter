import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_text_styles.dart';
import 'package:sicv_flutter/models/category.dart';
import 'package:sicv_flutter/models/inventory_item.dart';
import 'package:sicv_flutter/models/product.dart';
import 'package:sicv_flutter/ui/screen/home/inventory_screen.dart';
import 'package:sicv_flutter/ui/screen/home/purchase_screen.dart';
import 'package:sicv_flutter/ui/screen/home/sale_screen.dart';
import 'package:sicv_flutter/ui/widgets/menu.dart';
import 'dart:io';        // Required for File (mobile/desktop)
import 'package:flutter/foundation.dart'; // Required for kIsWeb constant
import 'package:image_picker/image_picker.dart'; // Required for image picking

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  // ⭐️ 1. MUEVE LAS DEFINICIONES AQUÍ
  final ProductCategory catBebidas = ProductCategory(id: 1, name: 'Bebidas');
  final ProductCategory catLimpieza = ProductCategory(id: 2, name: 'Limpieza');
  final ProductCategory catAlimentos = ProductCategory(id: 3, name: 'Alimentos');
  final ProductCategory catPersonal = ProductCategory(id: 4, name: 'Cuidado Personal');
  
  // ⭐️ 2. DECLARA LA LISTA AQUÍ
  late final List<ProductCategory> _allCategories;

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

    // ⭐️ 3. INICIALIZA LA LISTA AQUÍ
    _allCategories = [
      catBebidas,
      catLimpieza,
      catAlimentos,
      catPersonal,
    ];
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

  // Las funciones auxiliares _buildInputDecoration y _buildCustomTextField se mantienen iguales.

void _addNewProduct() {
  // --- Controllers ---
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final skuController = TextEditingController();

  // --- State variables for the modal ---
  ProductCategory? selectedCategory;
  File? selectedImageFile;      // Used for mobile/desktop
  Uint8List? selectedImageBytes; // Used for web

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext modalContext) {
      return Padding(
        padding: MediaQuery.of(modalContext).viewInsets,
        child: StatefulBuilder(
          builder: (context, setStateModal) {
            // --- Image Picking Logic ---
            Future<void> _pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                if (kIsWeb) {
                  // On Web: Read bytes
                  final bytes = await image.readAsBytes();
                  setStateModal(() {
                    selectedImageBytes = bytes;
                    selectedImageFile = null; // Clear file state if switching
                  });
                } else {
                  // On Mobile/Desktop: Use File path
                  setStateModal(() {
                    selectedImageFile = File(image.path);
                    selectedImageBytes = null; // Clear byte state if switching
                  });
                }
              }
            }
            // --- End of Image Picking Logic ---

            return Container(
              height: MediaQuery.of(context).size.height * 0.85, // Adjust height as needed
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- Modal Title ---
                  Text(
                    'Registrar Nuevo Producto',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),

                  // --- Form Body ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          // --- Image Selection Section ---
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 2),
                                    // Platform-aware image display
                                    image: kIsWeb
                                      ? (selectedImageBytes != null ? DecorationImage(image: MemoryImage(selectedImageBytes!), fit: BoxFit.cover) : null)
                                      : (selectedImageFile != null ? DecorationImage(image: FileImage(selectedImageFile!), fit: BoxFit.cover) : null),
                                  ),
                                  // Placeholder Icon
                                  child: (kIsWeb ? selectedImageBytes == null : selectedImageFile == null)
                                    ? const Center(
                                        child: Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 40,
                                          color: AppColors.textSecondary,
                                        ),
                                      )
                                    : null,
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  icon: Icon((kIsWeb ? selectedImageBytes == null : selectedImageFile == null) ? Icons.add : Icons.edit, size: 18),
                                  label: Text((kIsWeb ? selectedImageBytes == null : selectedImageFile == null) ? 'Añadir Imagen' : 'Cambiar Imagen'),
                                  onPressed: _pickImage, // Call the picker function
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- Other Form Fields ---
                          _buildCustomTextField(controller: nameController, labelText: 'Nombre del Producto', prefixIcon: Icons.shopping_bag_outlined),
                          const SizedBox(height: 16),
                          _buildCustomTextField(controller: skuController, labelText: 'SKU / Código', prefixIcon: Icons.qr_code, keyboardType: TextInputType.text),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ProductCategory>(
                            initialValue: selectedCategory,
                            decoration: _buildInputDecoration(labelText: 'Categoría'),
                            items: _allCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                            onChanged: (ProductCategory? newValue) => setStateModal(() => selectedCategory = newValue),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildCustomTextField(controller: priceController, labelText: 'Precio', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildCustomTextField(controller: stockController, labelText: 'Stock Inicial', prefixIcon: Icons.inventory_2_outlined, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCustomTextField(controller: descriptionController, labelText: 'Descripción (Opcional)', maxLines: 3),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // --- Action Buttons ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        child: const Text('CANCELAR'),
                        onPressed: () => Navigator.of(modalContext).pop(),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 250, 
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          // Disable button if required fields are empty
                          onPressed: (nameController.text.isEmpty || skuController.text.isEmpty || selectedCategory == null)
                            ? null
                            : () async { // Make onPressed async
                                // --- Prepare Image Bytes for Upload ---
                                Uint8List? imageBytesToSend;
                                if (kIsWeb) {
                                  imageBytesToSend = selectedImageBytes; // Already have bytes on web
                                } else if (selectedImageFile != null) {
                                  imageBytesToSend = await selectedImageFile!.readAsBytes(); // Read bytes from File
                                }
                                // --- End of Image Preparation ---
                        
                                // --- Placeholder for your save logic ---
                                print('--- Saving Product ---');
                                print('Name: ${nameController.text}');
                                print('SKU: ${skuController.text}');
                                print('Category: ${selectedCategory?.name}');
                                print('Price: ${priceController.text}');
                                print('Stock: ${stockController.text}');
                                print('Description: ${descriptionController.text}');
                                print('Image Bytes length: ${imageBytesToSend?.length ?? 'No Image Selected'}');
                                
                                // 🚨 Replace the print statements above with your actual API call
                                // Example:
                                // bool success = await ApiService.saveProduct(
                                //   name: nameController.text,
                                //   sku: skuController.text,
                                //   categoryId: selectedCategory!.id,
                                //   price: double.tryParse(priceController.text) ?? 0.0,
                                //   stock: int.tryParse(stockController.text) ?? 0,
                                //   description: descriptionController.text,
                                //   imageBytes: imageBytesToSend, // Pass the prepared bytes
                                // );
                                // if (success && mounted) { // Check mounted before interacting with context
                                //    Navigator.of(modalContext).pop();
                                //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto guardado!')));
                                //    // Optionally refresh the product list here
                                // } else {
                                //   // Show error message
                                // }
                                // --- End of Placeholder ---
                        
                                if (mounted) { // Check if widget is still in the tree
                                    Navigator.of(modalContext).pop(); // Close modal after saving attempt
                                }
                              },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 8),
                              Text('GUARDAR PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  ).whenComplete(() {
    // Dispose controllers
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    skuController.dispose();
  });
}

// Keep your helper functions _buildInputDecoration and _buildCustomTextField as they were
// InputDecoration _buildInputDecoration(...) { ... }
// Widget _buildCustomTextField(...) { ... }
// ---------------------------------------------------
// FUNCIONES AUXILIARES PARA EL ESTILO DEL FORMULARIO
// ---------------------------------------------------

// Crea la decoración con el estilo uniforme que has definido
InputDecoration _buildInputDecoration({required String labelText, IconData? prefixIcon}) {
  return InputDecoration(
    labelStyle: const TextStyle(
      fontSize: 16.0,
      color: AppColors.textSecondary,
    ),
    filled: true,
    fillColor: AppColors.secondary,
    labelText: labelText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        width: 3.0,
        color: AppColors.border,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        width: 3.0,
        color: AppColors.textSecondary,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
  );
}

// Widget auxiliar para mantener el código más limpio
Widget _buildCustomTextField({
  required TextEditingController controller,
  required String labelText,
  IconData? prefixIcon,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    decoration: _buildInputDecoration(labelText: labelText, prefixIcon: prefixIcon),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    textCapitalization: TextCapitalization.sentences,
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
          onPressed: _addNewProduct,
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

