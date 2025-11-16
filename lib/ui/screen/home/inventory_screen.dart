// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/category_model.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'dart:io'; // Required for File (mobile/desktop)
import 'package:flutter/foundation.dart'; // Required for kIsWeb constant
import 'package:image_picker/image_picker.dart';
import 'package:sicv_flutter/services/category_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart'; // Required for image picking

class InventoryDatatableScreen extends StatefulWidget {
  const InventoryDatatableScreen({super.key});

  @override
  InventoryDatatableScreenState createState() =>
      InventoryDatatableScreenState();
}

class InventoryDatatableScreenState extends State<InventoryDatatableScreen> {
  //lista real de categorías desde el servicio
  late List<CategoryModel> _allCategories = [];

  // Lista completa de productos
  late final List<ProductModel> _allProducts;

  List<ProductModel> _filteredProducts = [];

  late List<CategoryModel> categoriesFilter = [];

  // Variable para almacenar la categoría seleccionada en el filtro
  String? categoriaSeleccionada = 'Todas';

  CategoryService categoryService = CategoryService();

  // Estado para los filtros
  String _searchQuery = '';
  CategoryModel? _selectedCategory;
  //final List<String> _categories = ['Todas', 'Bebidas', 'Limpieza', 'Alimentos', 'Personal'];

  int? _sortColumnIndex; // Índice de la columna ordenada (null = ninguna)
  bool _sortAscending = true; // Dirección del orden (true = Ascendente)

  static const int _stockLowThreshold = 10;

  // ⭐️ 2. DECLARA LA LISTA AQUÍ
  // List<CategoryModel> _allCategories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();

    _fetchCategories();
    

    _allProducts = [
      ProductModel(
        id: 1,
        name: 'Gaseosa 2L',
        description: 'Refresco sabor a cola de 2 litros.',
        price: 2.5,
        priceBs: 2.5,
        imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Gaseosa',
        category: CategoryModel(
          id: 11,
          name: 'hola',
          status: true,
          description: 'description',
        ),
        totalStock: 50,
        sku: 'GAS-001', // <-- ¡AÑADIDO!
        minStock: 10,
        perishable: true,
        status: true,
        stockGenerals: [],
        stockLots: [],
      ),
      ProductModel(
        id: 2,
        name: 'Jabón en Polvo 1kg',
        description: 'Detergente en polvo para ropa blanca y de color.',
        price: 4.0,
        priceBs: 354.0,
        imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Jabon',
        totalStock: 8,
        category: CategoryModel(
          id: 11,
          name: 'hola',
          status: true,
          description: 'description',
        ),
        sku: 'LIM-001',
        minStock: 10,
        perishable: true,
        status: true,
        stockGenerals: [],
        stockLots: [], // <-- ¡AÑADIDO!
      ),
    ];
    _filteredProducts = _allProducts;
  }

  Future<void> _fetchCategories() async {
    _allCategories = await CategoryService().getAllCategories();

    categoriesFilter = [CategoryModel(id: 0, name: 'Todas', status: true, description: 'Todas las categorías'), ..._allCategories];

    setState(() {
      _isLoadingCategories = false;
    });
  }

  /// Filtra Y ORDENA la lista de productos
  void _filterProducts() {
    // 1. Haz TODO el trabajo pesado AFUERA
    List<ProductModel> tempProducts = _allProducts;

    if (_selectedCategory != null && _selectedCategory!.name != 'Todas') {
      tempProducts = tempProducts
          .where((product) => product.category.name == _selectedCategory!.name)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      tempProducts = tempProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.sku!.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_sortColumnIndex != null) {
      tempProducts.sort((a, b) {
        // ... tu lógica de sort ...
        dynamic aValue;
        dynamic bValue;

        switch (_sortColumnIndex) {
          case 1: // Producto (Nombre)
            aValue = a.name.toLowerCase();
            bValue = b.name.toLowerCase();
            break;
          case 2: // SKU
            aValue = a.sku!.toLowerCase();
            bValue = b.sku!.toLowerCase();
            break;
          case 3: // Categoría
            aValue = a.category.name.toLowerCase();
            bValue = b.category.name.toLowerCase();
            break;
          case 4: // Stock
            // aValue = a.stock;
            // bValue = b.stock;
            break;
          case 5: // Precio
            aValue = a.price;
            bValue = b.price;
            break;
          default:
            return 0;
        }

        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    // 2. Llama a setState SÓLO para asignar el resultado final
    setState(() {
      _filteredProducts = tempProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView para que toda la pantalla
    // pueda hacer scroll si el contenido es muy alto.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinear todo a la izquierda
        children: [
          _buildKpiDashboard(),
          SizedBox(height: 16),
          _buildFiltersAndSearch(),
          SizedBox(height: 16),
          // El DataTable debe estar envuelto para permitir
          // scroll horizontal si las columnas son muy anchas.
          SizedBox(
            width: double.infinity, // Ocupa todo el ancho posible
            child: Card(
              elevation: 0.0,
              // 2. Define el borde exterior usando 'shape'
              shape: RoundedRectangleBorder(
                // Define el radio de las esquinas
                borderRadius: BorderRadius.circular(8.0),

                // Define el borde (grosor y color)
                side: BorderSide(
                  color: AppColors.border, // El color del borde
                  width: 3.0, // El grosor del borde
                ),
              ),
              clipBehavior: Clip.antiAlias, // Evita que la tabla se salga
              // 1. Usamos LayoutBuilder para obtener el ancho del padre (la Card)
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 2. Mantenemos el SingleChildScrollView para el scroll
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // 3. Usamos ConstrainedBox para forzar el ancho mínimo
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // 4. El ancho mínimo de la tabla será el ancho máximo del padre
                        minWidth: constraints.maxWidth,
                      ),
                      child: _buildDataTable(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el "Dashboard" superior con KPIs (Valores clave)
  Widget _buildKpiDashboard() {
    double totalValue = _allProducts.fold(
      0,
      (sum, item) => sum + (item.price * item.stockGenerals.length),
    );
    int lowStockItems = _allProducts
        .where(
          (p) =>
              p.stockGenerals.length > 0 &&
              p.stockGenerals.length <= _stockLowThreshold,
        )
        .length;
    // Añadí el contador de Agotados que tenías en el código anterior
    //int outOfStockItems = _allProducts.where((p) => p.stock == 0).length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ajusta este valor si lo necesitas
          bool isWideScreen = constraints.maxWidth > 600;

          if (isWideScreen) {
            // --- VISTA ANCHA: (3 en fila) ---
            return Row(
              children: [
                Expanded(
                  flex: 2, // Más espacio para el valor total
                  child: _buildKpiCard(
                    'Valor Total (Precio)',
                    '\$${totalValue.toStringAsFixed(2)}',
                    Colors.blue.shade800,
                  ),
                ),
                SizedBox(width: 8), // Reduje el espacio
                Expanded(
                  flex: 1,
                  child: _buildKpiCard(
                    'Items (SKUs)',
                    _allProducts.length.toString(),
                    Colors.green.shade800,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildKpiCard(
                    'Stock Bajo',
                    lowStockItems.toString(),
                    Colors.orange.shade800,
                  ),
                ),
              ],
            );
          } else {
            // --- VISTA ANGOSTA: (2 en fila, 1 abajo) ---
            return Column(
              children: [
                // Fila 1: Dos tarjetas
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Items (SKUs)',
                        _allProducts.length.toString(),
                        Colors.green.shade800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiCard(
                        'Stock Bajo',
                        lowStockItems.toString(),
                        Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Espacio entre filas
                // Fila 2: Una tarjeta (al estar sola en un Row+Expanded, ocupa todo el ancho)
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        'Valor Total (Precio)',
                        '\$${totalValue.toStringAsFixed(2)}',
                        Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),

                // (Opcional: Si también quieres mostrar "Agotados")
                // SizedBox(height: 8),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildKpiCard('Agotados', outOfStockItems.toString(), Colors.red.shade800)
                //     ),
                //   ],
                // ),
              ],
            );
          }
        },
      ),
    );
  }

  /// Widget helper para una tarjeta de KPI
  Widget _buildKpiCard(String title, String value, Color color) {
    return Card(
      color: AppColors.secondary,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.border, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la barra de búsqueda, filtro y botón de añadir (RESPONSIVO)
  Widget _buildFiltersAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // *** ¡AQUÍ ESTÁ LA MAGIA! ***
          // LayoutBuilder nos da el ancho disponible
          LayoutBuilder(
            builder: (context, constraints) {
              // Define un "punto de quiebre". 600px es un buen estándar
              // (la mayoría de los teléfonos en vertical son < 600px)
              bool isWideScreen = constraints.maxWidth > 600;

              if (isWideScreen) {
                // --- VISTA ANCHA: Usa un Row ---
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SearchTextFieldApp(
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterProducts();
                        },
                        labelText: 'Buscar por Nombre o SKU',
                      ), // TextField
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropDownApp(
                        labelText: "Categorías",
                        hintText: "Selecciona una categoría...",
                        initialValue: _selectedCategory,
                        items: categoriesFilter,
                        itemToString: (CategoryModel categoria) {
                          return categoria
                              .name; // <-- Cambia 'name' por la propiedad de texto de tu clase
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                          _filterProducts();
                        },
                      ),
                    ),
                  ],
                );
              } else {
                // --- VISTA ANGOSTA: Usa un Column ---
                return Column(
                  children: [
                    SearchTextFieldApp(
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterProducts();
                      },
                      labelText: 'Buscar por Nombre o SKU',
                    ), // TextField
                    SizedBox(height: 16),
                    DropDownApp(
                      labelText: "Categorías",
                      hintText: "Selecciona una categoría...",
                      initialValue: _selectedCategory,
                      items: _allCategories,
                      itemToString: (CategoryModel categoria) {
                        return categoria
                            .name; // <-- Cambia 'name' por la propiedad de texto de tu clase
                      },
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                        _filterProducts();
                      },
                    ), // Dropdown
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _filterProducts();
    });
  }
  // --- Widgets de ayuda (separados para limpieza) ---

  /// Construye el campo de búsqueda
  /* Widget _buildSearchField() {
    return TextField(
      style: TextStyle(
        fontSize: 15.0, // <-- Cambia este valor al tamaño que quieras
        color: AppColors.textPrimary, // (Opcional: define el color del texto)
      ),
      
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondary,
        labelText: 'Buscar por Nombre o SKU',
        prefixIcon: Icon(Icons.search),
        labelStyle: TextStyle(
          fontSize: 14.0, // <-- Cambia el tamaño de la fuente del label
          color: AppColors.textSecondary, // (Opcional: define el color del label)
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2.0, // <-- Tu grosor deseado
            color: AppColors.border, // Color del borde
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              width: 3.0, // <-- Puedes poner un grosor mayor al enfocar
              color: AppColors.textSecondary, // Color del borde al enfocar
          ),
        ),
        
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (value) {
        _searchQuery = value;
        _filterProducts();
      },
    );
  }
*/
  /// Construye el filtro de categoría
  /* Widget _buildCategoryFilter() {
    return DropdownButtonFormField<String>(
      // --- 👇 2. ESTILO DEL MENÚ DESPLEGABLE (LA CAJA QUE APARECE) ---
      dropdownColor: AppColors.background, // Color de fondo del menú
      borderRadius: BorderRadius.circular(12), // Bordes redondeados del menú

      // --- 👇 3. ESTILO DEL ÍCONO (LA FLECHA) ---
      icon: Icon(Icons.keyboard_arrow_down_rounded), // Cambia el ícono
      iconSize: 24, // Tamaño del ícono
      //focusColor: AppColors.textSecondary, // Color del ícono

      menuMaxHeight: 500.0,

      decoration: InputDecoration(
        labelStyle: TextStyle(
          fontSize: 14.0, // <-- Cambia el tamaño de la fuente del label
          color: AppColors.textSecondary, // (Opcional: define el color del label)
        ),
        
        filled: true,
        fillColor: AppColors.secondary,
        labelText: 'Categoría',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2.0, // <-- Tu grosor deseado
            color: AppColors.border, // Color del borde
          ),
        ),
      
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              width: 3.0, // <-- Puedes poner un grosor mayor al enfocar
              color: AppColors.textSecondary, // Color del borde al enfocar
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      initialValue: _selectedCategory,
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: TextStyle(
              color: Colors.black87, // Color del texto de los ítems
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
        _filterProducts();
      },
    );
  }
*/
  /// Construye el DataTable principal
  Widget _buildDataTable() {
    return DataTable(
      horizontalMargin: 15.0,
      columnSpacing: 20.0, // <-- Reduje un poco el espacio
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,

      dataRowColor: WidgetStateProperty.all(
        AppColors.background,
      ), // Color de fondo de las filas
      headingRowColor: WidgetStateProperty.all(
        AppColors.border,
      ), // Color de fondo de la cabecera
      //dataRowHeight: 60.0, // <-- Altura fija para las filas (útil para imágenes)
      headingRowHeight: 48.0, // <-- Altura fija para la cabecera
      //border: TableBorder.all(width: 2, color: AppColors.border), // <-- Borde para toda la tabla

      // Definición de las Columnas
      columns: [
        // *** ¡NUEVA COLUMNA DE IMAGEN! (Índice 0) ***
        // Esta columna no tiene 'onSort'
        const DataColumn(
          label: Padding(
            padding: EdgeInsets.only(
              left: 8.0,
            ), // Padding para centrar el 'Img'
            child: Text('Img', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),

        // Columna 1: Producto
        DataColumn(
          label: Text(
            'Producto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        // Columna 2: SKU
        DataColumn(
          label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
          onSort: _onSort,
        ),
        // Columna 3: Categoría
        DataColumn(
          label: Text(
            'Categoría',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        // Columna 4: Stock
        DataColumn(
          label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: _onSort,
        ),
        // Columna 5: Precio
        DataColumn(
          label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
          onSort: _onSort,
        ),
        // Columna 6: Acciones (SIN onSort)
        DataColumn(
          label: Row(
            children: [
              SizedBox(width: 15.0),
              Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],

      // Definición de las Filas
      rows: _filteredProducts.map((product) {
        final stockColor = _getStockColor(product.stockGenerals.length);

        return DataRow(
          cells: [
            // *** ¡NUEVA CELDA DE IMAGEN! (Índice 0) ***
            DataCell(
              Padding(
                // Padding vertical para que el CircleAvatar quepa bien
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: CircleAvatar(
                  radius: 20,
                  // Muestra la imagen. Si falla, muestra un ícono.
                  backgroundImage: NetworkImage(product.imageUrl!),
                  onBackgroundImageError: (e, s) {}, // Captura el error
                  child: Builder(
                    // Se usa si la imagen falla
                    builder: (context) {
                      // Si la imagen falla (onBackgroundImageError se dispara)
                      // el backgroundImage es null, y el child se muestra.
                      // Aquí podrías poner un ícono por defecto
                      return const Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Celdas existentes (ahora 1-6)
            DataCell(Text(product.name)),
            DataCell(Text(product.sku!)),
            DataCell(Text(product.category.name)),
            DataCell(
              Text(
                product.stockGenerals.length.toString(),
                style: TextStyle(
                  color: stockColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
            DataCell(
              Row(
                children: [
                  SizedBox(width: 15.0),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    tooltip: 'Editar Producto',
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.inventory_2,
                      size: 20,
                      color: Colors.green.shade700,
                    ),
                    tooltip: 'Ajustar Stock',
                    onPressed: () => _adjustStock(product),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.red.shade700,
                    ),
                    tooltip: 'Eliminar Producto',
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Helper para determinar el color del indicador de stock
  Color _getStockColor(int stock) {
    if (stock == 0) {
      return Colors.red.shade900;
    } else if (stock <= _stockLowThreshold) {
      return Colors.orange.shade900;
    } else {
      return Colors.green.shade800;
    }
  }

  void _editProduct(ProductModel product) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editando ${product.name}...')));
  }

  void _adjustStock(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mostrando diálogo para ajustar stock de ${product.name}...',
        ),
      ),
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar ${product.name}?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                _allProducts.remove(product);
                _filterProducts();
              });
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void addNewProduct() async {
    // --- Controllers ---
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final skuController = TextEditingController();

    // --- State variables for the modal ---
    CategoryModel? selectedCategory;
    File? selectedImageFile; // Used for mobile/desktop
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
              Future<void> pickImage() async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

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
                      selectedImageBytes =
                          null; // Clear byte state if switching
                    });
                  }
                }
              }
              // --- End of Image Picking Logic ---

              return Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.85, // Adjust height as needed
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- Modal Title ---
                    Text(
                      'Registrar Nuevo Producto',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 2,
                                      ),
                                      // Platform-aware image display
                                      image: kIsWeb
                                          ? (selectedImageBytes != null
                                                ? DecorationImage(
                                                    image: MemoryImage(
                                                      selectedImageBytes!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null)
                                          : (selectedImageFile != null
                                                ? DecorationImage(
                                                    image: FileImage(
                                                      selectedImageFile!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null),
                                    ),
                                    // Placeholder Icon
                                    child:
                                        (kIsWeb
                                            ? selectedImageBytes == null
                                            : selectedImageFile == null)
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
                                    icon: Icon(
                                      (kIsWeb
                                              ? selectedImageBytes == null
                                              : selectedImageFile == null)
                                          ? Icons.add
                                          : Icons.edit,
                                      size: 18,
                                    ),
                                    label: Text(
                                      (kIsWeb
                                              ? selectedImageBytes == null
                                              : selectedImageFile == null)
                                          ? 'Añadir Imagen'
                                          : 'Cambiar Imagen',
                                    ),
                                    onPressed:
                                        pickImage, // Call the picker function
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- Other Form Fields ---
                            TextFieldApp(
                              controller: nameController,
                              labelText: 'Nombre del Producto',
                              prefixIcon: Icons.shopping_bag_outlined,
                            ),
                            const SizedBox(height: 16),
                            TextFieldApp(
                              controller: skuController,
                              labelText: 'SKU / Código',
                              prefixIcon: Icons.qr_code,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            DropDownApp(
                              labelText: "Categoría",
                              prefixIcon: Icons.category,
                              initialValue: selectedCategory,
                              items: _allCategories,
                              itemToString: (CategoryModel categoria) {
                                return categoria
                                    .name; // <-- Cambia 'name' por la propiedad de texto de tu clase
                              },
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFieldApp(
                                    controller: priceController,
                                    labelText: 'Precio',
                                    prefixIcon: Icons.attach_money,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFieldApp(
                                    controller: stockController,
                                    labelText: 'Stock Inicial',
                                    prefixIcon: Icons.inventory_2_outlined,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFieldApp(
                              controller: descriptionController,
                              labelText: 'Descripción (Opcional)',
                              maxLines: 3,
                            ),
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
                          constraints: BoxConstraints(maxWidth: 250),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // Disable button if required fields are empty
                            onPressed:
                                (nameController.text.isEmpty ||
                                    skuController.text.isEmpty)
                                ? null
                                : () async {
                                    // Make onPressed async
                                    // --- Prepare Image Bytes for Upload ---
                                    Uint8List? imageBytesToSend;
                                    if (kIsWeb) {
                                      imageBytesToSend =
                                          selectedImageBytes; // Already have bytes on web
                                    } else if (selectedImageFile != null) {
                                      imageBytesToSend = await selectedImageFile!
                                          .readAsBytes(); // Read bytes from File
                                    }
                                    // --- End of Image Preparation ---

                                    // --- Placeholder for your save logic ---
                                    print('--- Saving Product ---');
                                    print('Name: ${nameController.text}');
                                    print('SKU: ${skuController.text}');
                                    print(
                                      'Category: ${selectedCategory!.name}',
                                    );
                                    print('Price: ${priceController.text}');
                                    print('Stock: ${stockController.text}');
                                    print(
                                      'Description: ${descriptionController.text}',
                                    );
                                    print(
                                      'Image Bytes length: ${imageBytesToSend?.length ?? 'No Image Selected'}',
                                    );

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

                                    if (mounted) {
                                      // Check if widget is still in the tree
                                      Navigator.of(
                                        modalContext,
                                      ).pop(); // Close modal after saving attempt
                                    }
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'GUARDAR PRODUCTO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
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

  /*  InputDecoration _buildInputDecoration({required String labelText, IconData? prefixIcon}) {
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
*/
  // Widget auxiliar para mantener el código más limpio
  /*  Widget _buildCustomTextField({
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

*/
}
