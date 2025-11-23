// lib/ui/screen/movements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/movement_model.dart';
// Importa tus modelos
// Necesario para el modelo Product
import 'package:sicv_flutter/models/movement_type.dart';
import 'package:sicv_flutter/models/product_model.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/services/movement_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sidebarx/sidebarx.dart';

class MovementsPage extends ConsumerStatefulWidget {
  final SidebarXController controller;
  const MovementsPage({super.key, required this.controller});

  @override
  ConsumerState<MovementsPage> createState() => MovementsPageState();
}

class MovementsPageState extends ConsumerState<MovementsPage> {
  // --- Estado ---
  List<MovementModel> _allMovements = [];
  List<MovementModel> _filteredMovements = [];
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];

  // Filtros
  MovementType? _selectedMovementType;
  String _selectedDateRange = 'Últimos 7 días'; // Valor inicial
  final List<String> _dateRangeOptions = [
    'Hoy',
    'Ayer',
    'Últimos 7 días',
    'Este mes',
    'Todos',
  ];
  int? _sortColumnIndex; // Índice de la columna ordenada (null = ninguna)
  bool _sortAscending = true; // Dirección del orden (true = Ascendente)
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadMovements(); // Función separada para movimientos
    _searchController.addListener(_runFilter);
    allproducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carga movimientos (simulación)
  void _loadMovements() async {  
    _allMovements = await MovementService().getAll();
    _allMovements.sort((a, b) => b.movedAt.compareTo(a.movedAt));
    _filteredMovements = _allMovements;
    _runFilter(); // Aplica filtros iniciales
    // --- FIN SIMULACIÓN ---
  }

  void allproducts () async {
    final productsState = ref.watch(productsProvider);
    productsState.when(
      data: (products) {
        setState(() {
          // Actualiza el estado con los productos obtenidos
          _allProducts = products;
        });
      },
      loading: () {
        // Maneja el estado de carga si es necesario
      },
      error: (error, stackTrace) {
        // Maneja el error si es necesario
      },
    );
  }

  void _runFilter() {
    // Verifica que _allMovements no sea null antes de usarla
    List<MovementModel> results = _allMovements;
    String searchText = _searchController.text.toLowerCase();
    final now = DateTime.now();
    DateTime startDate;

    // 1. Filtrar por Rango de Fechas
    switch (_selectedDateRange) {
      case 'Hoy':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Ayer':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        results = results
            .where(
              (m) =>
                  m.movedAt.isAfter(startDate) &&
                  m.movedAt.isBefore(DateTime(now.year, now.month, now.day)),
            )
            .toList();
        break;
      case 'Últimos 7 días':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Este mes':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Todos':
      default:
        startDate = DateTime(2000);
        break;
    }

    if (_selectedDateRange != 'Ayer') {
      results = results.where((m) => m.movedAt.isAfter(startDate)).toList();
    }

    // 2. Filtrar por Tipo de Movimiento
    if (_selectedMovementType != null) {
      results = results
          .where((m) => m.type == _selectedMovementType)
          .toList();
    }

    // Se ejecuta solo si _selectedUser NO es null (es decir, no es 'Todos')
    if (_selectedUser != null && _selectedUser!.isNotEmpty) {
      results = results.where((m) => m.user!.name == _selectedUser).toList();
    }

    // 3. Filtrar por Texto de Búsqueda
    if (searchText.isNotEmpty) {
      results = results
          .where(
            (m) =>
                m.product!.name.toLowerCase().contains(searchText) //||
                //(m.product.sku ?? '').toLowerCase().contains(searchText),
          )
          .toList();
    }

    if (_sortColumnIndex != null) {
      results.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        // ⚠️ Corregido: Los índices ahora coinciden con las columnas
        switch (_sortColumnIndex) {
          case 0: // ✅ Fecha y Hora
            aValue = a.movedAt;
            bValue = b.movedAt;
            break;
          case 1: // ✅ Producto (Nombre)
            // Usar ?? '' para manejar nulls de forma segura en Strings
            aValue = a.product!.name;
            bValue = b.product!.name;
            break;
          case 2: // ✅ Tipo (MovementType)
            // Convertir el enum o tipo a String para poder compararlo
            aValue = a.type.toString();
            bValue = b.type.toString();
            break;
          case 3: // ✅ Cant. (Quantity)
            aValue = a.amount;
            bValue = b.amount;
            break;
          // Los casos 4 y 5 (Stock Ant./Desp.) no tienen onSort, se omite.
          case 6: // ✅ Usuario
            // Usar ?? '' para manejar nulls de forma segura en Strings
            aValue = a.user!.name;
            bValue = b.user!.name;
            break;
          default:
            return 0; // No ordenar
        }

        // Función de comparación genérica
        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    setState(() {
      _filteredMovements = results;
    });
  }

  // --- Dropdowns (_buildDateRangeFilter, _buildMovementTypeFilter) ---

  /// Dropdown para filtro de Rango de Fechas
  Widget _buildDateRangeFilter() {
    return DropdownButton<String>(
      value: _selectedDateRange,
      items: _dateRangeOptions.map((range) {
        return DropdownMenuItem(value: range, child: Text(range));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedDateRange = newValue;
          });
          _runFilter(); // Llama al filtro
        }
      },
      hint: const Text('Periodo'),
      //underline: Container(), // Quita la línea de abajo para un look más limpio
    );
  }

  /// Dropdown para filtro de Tipo de Movimiento
  Widget _buildMovementTypeFilter() {
    return DropdownButton<MovementType>(
      value: _selectedMovementType,
      items: [
        // Opción para quitar el filtro ("Todos")
        const DropdownMenuItem(value: null, child: Text('Todos los tipos')),
        // Genera las opciones desde el enum MovementType
        ...MovementType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Para que el Row no sea muy ancho
              children: [
                Icon(
                  type.icon,
                  color: type.color,
                  size: 18,
                ), // Muestra ícono y color
                const SizedBox(width: 8),
                Text(type.displayName), // Muestra el nombre legible
              ],
            ),
          );
        }),
      ],
      onChanged: (MovementType? newValue) {
        setState(() {
          _selectedMovementType =
              newValue; // Puede ser null si selecciona "Todos"
        });
        _runFilter(); // Llama al filtro
      },
      hint: const Text('Tipo'),
      //underline: Container(), // Quita la línea de abajo
    );
  }

  Widget _buildUserFilter() {
    // 1. Obtener la lista única de usuarios
    final List<String> uniqueUsers = _allMovements
        .map((m) => m.user!.name)
        .whereType<String>() // Filtra solo los que son String y no null
        .where((name) => name.isNotEmpty) // Filtra strings vacías
        .toSet()
        .toList();

    // 2. Opciones finales: null (para 'Todos') + la lista de usuarios.
    // Usar String? como tipo del Dropdown para aceptar null (Todos).
    List<String?> userOptions = [null, ...uniqueUsers];

    return DropdownButton<String>(
      // ⭐️ Usamos DropdownButton simple
      // Muestra el valor seleccionado (null si es 'Todos')
      value: _selectedUser,

      // ⭐️ Hint cuando no hay nada seleccionado, aunque 'Todos' siempre estará seleccionado al inicio
      hint: const Text('Usuario'),

      items: userOptions.map((user) {
        // Si user es null (la primera entrada), muestra "Todos"
        final displayLabel = user ?? 'Todos los usuarios';

        return DropdownMenuItem<String>(
          // El valor del item es null si es "Todos", y el nombre de usuario si es un filtro activo.
          value: user,
          child: Text(displayLabel),
        );
      }).toList(),

      onChanged: (String? newValue) {
        setState(() {
          _selectedUser = newValue;
          _runFilter(); // Llama a la función para aplicar el nuevo filtro
        });
      },
      // Si quieres quitar la línea de abajo, puedes descomentar:
      // underline: Container(),
    );
  }

  // --- DataTable y ListView (_buildMovementsDataTable, _buildMovementsListView) ---
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _runFilter();
    });
  }

  /// Vista de Tabla para PC
  Widget _buildMovementsDataTable() {
    // Define el formato de fecha una sola vez
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    // Usa SingleChildScrollView para permitir scroll horizontal si la tabla es muy ancha
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

        child: DataTable(
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
          // Define las columnas de la tabla
          columns: [
            // Índice de Columna 0: Fecha y Hora (Debería tener onSort)
            DataColumn(
              label: Text(
                'Fecha y Hora',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: _onSort, // ✅ Añadido onSort
            ),
            // Índice de Columna 1: Producto
            DataColumn(
              label: Text(
                'Producto',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: _onSort,
            ),
            // Índice de Columna 2: Tipo
            DataColumn(
              label: Text(
                'Tipo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: _onSort,
            ),
            // Índice de Columna 3: Cant.
            DataColumn(
              label: Text(
                'Cant.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: _onSort,
              numeric: true,
            ),
            // Índice de Columna 6: Usuario
            DataColumn(
              label: Text(
                'Usuario',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onSort: _onSort,
            ),
            // Índice de Columna 7: Referencia (Sin onSort, por defecto)
            DataColumn(
              label: Text(
                'Referencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Row(
                children: [
                  SizedBox(width: 15.0),
                  Text(
                    'Acciones',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          // Genera las filas a partir de la lista filtrada
          rows: _filteredMovements.map((movement) {
            // Determina el color y prefijo de la cantidad
            final qtyColor = movement.amount >= 0
                ? Colors.green.shade700
                : Colors.red.shade700;
            final qtyPrefix = movement.amount > 0
                ? '+'
                : ''; // Solo '+' si es positivo

            return DataRow(
              cells: [
                DataCell(
                  Text(dateFormat.format(movement.movedAt)),
                ), // Fecha formateada
                DataCell(
                  Tooltip(
                    // Añade Tooltip si el nombre es largo
                    message:
                        '${movement.product!.name}\nSKU: ${movement.product?.sku ?? 'N/A'}',
                    child: Text(
                      movement.product!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Text(movement.type),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    // Cantidad con color y signo
                    qtyPrefix + movement.amount.toString(),
                    style: TextStyle(
                      color: qtyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(movement.user!.name)), // Usuario
                DataCell(
                  Tooltip(
                    // Tooltip para referencias largas
                    message: movement.observation,
                    child: Text(
                      movement.observation,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ), // Referencia
                DataCell(
                  Row(
                    children: [
                      SizedBox(width: 15.0),
                      IconButton(
                        icon: Icon(
                          Icons.info,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        tooltip: 'Ver detalle completo',
                        onPressed: () => {} /*_editProduct(product)*/,
                      ),
                      /*IconButton(
                    icon: Icon(Icons.inventory_2, size: 20, color: Colors.green.shade700),
                    tooltip: 'Ajustar Stock',
                    onPressed: () => {}/*_editProduct(product)*/,
                  ),*/
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red.shade700,
                        ),
                        tooltip: 'Eliminar Producto',
                        onPressed: () => {} /*_editProduct(product)*/,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Vista de Lista para Móvil
  Widget _buildMovementsListView() {
    // Define el formato de fecha
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    return ListView.builder(
      itemCount: _filteredMovements.length,
      itemBuilder: (context, index) {
        final movement = _filteredMovements[index];
        // Determina color y prefijo de cantidad
        final qtyColor = movement.amount >= 0
            ? Colors.green.shade700
            : Colors.red.shade700;
        final qtyPrefix = movement.amount >= 0 ? '+' : '';

        return Card(
          elevation: 0.0,
          color: AppColors.secondary,
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
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: Tooltip(
              // Tooltip para el tipo de movimiento
              message: movement.type,
            ),
            title: Text(
              '${movement.product!.name} (${movement.product?.sku ?? 'N/A'})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${dateFormat.format(movement.movedAt)} - ${movement.user!.name}\n' // Fecha y usuario
              'Ref: ${movement.observation} | Stock: ${movement.amount}', // Referencia y cambio de stock
            ),
            trailing: Text(
              // Cantidad al final
              qtyPrefix + movement.amount.toString(),
              style: TextStyle(
                color: qtyColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            isThreeLine: true, // Da más espacio vertical al ListTile
          ),
        );
      },
    );
  }

  // --- Diálogo _showAddMovementDialog ---
  // Se asume que tienes estas variables de estado en tu StatefulWidget
  // final List<Product> _allProducts;
  // void _runFilter();

  void _showAddMovementModal(BuildContext context) {
    // Controladores y estado local para el modal
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    // Se inicializa con el primer tipo de ajuste para evitar nulls.
    // Es importante que este valor se mantenga a lo largo del modal.
    MovementType selectedAdjustmentType = MovementType.ajustePositivo;
    ProductModel? selectedProduct;

    // Lista de productos para el Dropdown (aseguramos que no sea null)
    final List<ProductModel> productsForSelection = _allProducts;

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que ocupe casi toda la pantalla para el teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext dialogContext) {
        // Usamos un Padding al inicio para manejar el desplazamiento del teclado
        return Padding(
          padding: MediaQuery.of(dialogContext).viewInsets,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.75, // 75% de la pantalla
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- Título ---
                    Text(
                      'Registrar Ajuste Manual de Stock',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // 1. Selector de Producto (Dropdown)
                            DropdownButtonFormField<ProductModel>(
                              initialValue: selectedProduct,
                              hint: const Text('Selecciona Producto...'),
                              isExpanded: true,
                              items: productsForSelection.isEmpty
                                  ? [
                                      const DropdownMenuItem(
                                        enabled: false,
                                        child: Text(
                                          "Cargando productos...",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ]
                                  : productsForSelection.map((product) {
                                      return DropdownMenuItem(
                                        value: product,
                                        child: Text(
                                          '${product.name} (Stock: ${product.totalStock})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                              onChanged: productsForSelection.isEmpty
                                  ? null
                                  : (ProductModel? newValue) {
                                      setStateDialog(() {
                                        selectedProduct = newValue;
                                      });
                                    },
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize:
                                      16.0, // <-- Cambia el tamaño de la fuente del label
                                  color: AppColors
                                      .textSecondary, // (Opcional: define el color del label)
                                ),

                                filled: true,
                                fillColor: AppColors.secondary,
                                labelText: 'Producto',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 3.0, // <-- Tu grosor deseado
                                    color: AppColors.border, // Color del borde
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width:
                                        3.0, // <-- Puedes poner un grosor mayor al enfocar
                                    color: AppColors
                                        .textSecondary, // Color del borde al enfocar
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Selector de Tipo de Ajuste
                            DropdownButtonFormField<MovementType>(
                              initialValue: selectedAdjustmentType,
                              items:
                                  [
                                        MovementType.ajustePositivo,
                                        MovementType.ajusteNegativo,
                                      ]
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Row(
                                            children: [
                                              Icon(
                                                type.icon,
                                                color: type.color,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(type.displayName),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (MovementType? newValue) {
                                if (newValue != null) {
                                  setStateDialog(() {
                                    selectedAdjustmentType = newValue;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize:
                                      16.0, // <-- Cambia el tamaño de la fuente del label
                                  color: AppColors
                                      .textSecondary, // (Opcional: define el color del label)
                                ),

                                filled: true,
                                fillColor: AppColors.secondary,
                                labelText: 'Tipo de Ajuste',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 3.0, // <-- Tu grosor deseado
                                    color: AppColors.border, // Color del borde
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width:
                                        3.0, // <-- Puedes poner un grosor mayor al enfocar
                                    color: AppColors
                                        .textSecondary, // Color del borde al enfocar
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Campo de Cantidad
                            TextField(
                              controller: quantityController,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize:
                                      16.0, // <-- Cambia el tamaño de la fuente del label
                                  color: AppColors
                                      .textSecondary, // (Opcional: define el color del label)
                                ),

                                filled: true,
                                fillColor: AppColors.secondary,
                                labelText: 'Cantidad a Ajustar',
                                hintText: 'Ej: 5',
                                prefixIcon: Icon(Icons.numbers, size: 18),
                                alignLabelWithHint:
                                    true, // Alinea el label en multilínea
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 3.0, // <-- Tu grosor deseado
                                    color: AppColors.border, // Color del borde
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width:
                                        3.0, // <-- Puedes poner un grosor mayor al enfocar
                                    color: AppColors
                                        .textSecondary, // Color del borde al enfocar
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 4. Campo de Razón (Opcional)
                            TextField(
                              controller: reasonController,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize:
                                      16.0, // <-- Cambia el tamaño de la fuente del label
                                  color: AppColors
                                      .textSecondary, // (Opcional: define el color del label)
                                ),

                                filled: true,
                                fillColor: AppColors.secondary,
                                labelText: 'Razón del ajuste (Opcional)',
                                hintText: 'Ej: Mercancía dañada, Conteo físico',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 3.0, // <-- Tu grosor deseado
                                    color: AppColors.border, // Color del borde
                                  ),
                                ),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width:
                                        3.0, // <-- Puedes poner un grosor mayor al enfocar
                                    color: AppColors
                                        .textSecondary, // Color del borde al enfocar
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Botones de Acción (al final del modal) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          child: TextButton(
                            child: const Text('CANCELAR'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 8.0,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 300),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  'GUARDAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight
                                        .w600, // Ligeramente más negrita
                                    letterSpacing:
                                        0.8, // Aumenta el espaciado entre letras
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  // Usa el color primario de tu tema para un look de marca
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  // Color del texto y el ícono
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  // Define un padding más generoso para hacerlo más grande
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ), // Esquinas ligeramente redondeadas
                                  ),
                                ),
                                onPressed: selectedProduct == null
                                    ? null // Deshabilita si no hay producto seleccionado
                                    : () => _handleSaveAdjustment(
                                        context,
                                        dialogContext,
                                        selectedProduct!, // Ya verificado
                                        selectedAdjustmentType,
                                        quantityController,
                                        reasonController,
                                      ),
                              ),
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
      // Liberar recursos al cerrar el modal
      quantityController.dispose();
      reasonController.dispose();
    });
  }

  // ----------------------------------------------------------------------
  // Función de Guardado Separada para mantener la lógica limpia
  // ----------------------------------------------------------------------

  void _handleSaveAdjustment(
    BuildContext pageContext, // Contexto de la página (para ScaffoldMessenger)
    BuildContext dialogContext, // Contexto del modal (para pop)
    ProductModel product,
    MovementType selectedAdjustmentType,
    TextEditingController quantityController,
    TextEditingController reasonController,
  ) {
    final quantity = int.tryParse(quantityController.text);

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, ingresa una cantidad válida (mayor a cero).',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Determina la cantidad con signo (+ o -)
    final int signedQuantity =
        (selectedAdjustmentType == MovementType.ajustePositivo)
        ? quantity
        : -quantity;

    // Busca el producto en la lista _allProducts para obtener el stock MÁS RECIENTE
    final currentProductData = _allProducts.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );
    final int currentStock = currentProductData.totalStock;
    final int stockAfter = currentStock + signedQuantity;

    if (stockAfter < 0) {
      ScaffoldMessenger.of(pageContext).showSnackBar(
        SnackBar(
          content: Text(
            'Ajuste inválido. El stock no puede ser negativo (quedaría en $stockAfter).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; // No permite stock negativo
    }

    final newMovement = MovementModel(
      movementId: 0, // Asumir que el ID será asignado por el backend
      depotId: 1, // Reemplaza con el depósito adecuado
      movedAt: DateTime.now(),
      productId: product.id,
      type: selectedAdjustmentType.displayName,
      amount: signedQuantity,
      userCi: "31350493", // Reemplaza con el CI de usuario adecuado
      observation: reasonController.text.isNotEmpty
          ? reasonController.text
          : 'Ajuste manual',
      status: true,
    );

    // --- LLAMADA A API Y ACTUALIZACIÓN LOCAL (dentro del setState de la página) ---
    setState(() {
      _allMovements.insert(0, newMovement);

      // Actualiza el stock en la lista _allProducts (simulación de mutación de stock)
      final productIndex = _allProducts.indexWhere((p) => p.id == product.id);
      if (productIndex != -1) {
        // Usa copyWith (idealmente) o crea un nuevo objeto para actualizar la lista
        _allProducts[productIndex] = ProductModel(
          stockGenerals: _allProducts[productIndex].stockGenerals,
          stockLots: _allProducts[productIndex].stockLots,
          priceBs: _allProducts[productIndex].priceBs,
          minStock: _allProducts[productIndex].minStock,
          perishable: _allProducts[productIndex].perishable,
          status: _allProducts[productIndex].status,
          id: _allProducts[productIndex].id,
          name: _allProducts[productIndex].name,
          description: _allProducts[productIndex].description,
          price: _allProducts[productIndex].price,
          totalStock: stockAfter, // Stock actualizado
          category: _allProducts[productIndex].category,
          sku: _allProducts[productIndex].sku,
          imageUrl: _allProducts[productIndex].imageUrl,
        );
      }
      _runFilter(); // Llama a tu función para actualizar la lista mostrada en la página
    });

    Navigator.of(dialogContext).pop(); // Cierra el modal
    ScaffoldMessenger.of(pageContext).showSnackBar(
      const SnackBar(
        content: Text('Ajuste guardado exitosamente.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final double breakpoint = 600.0;
    //final bool isWide = MediaQuery.of(context).size.width >= breakpoint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: !isWide
              ? AppBar(
                  // 1. Apariencia limpia: Fondo blanco/claro y sin elevación marcada
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surface, // Usa el color de fondo del tema
                  surfaceTintColor: Colors
                      .transparent, // Elimina el tinte al hacer scroll (Android 12+)
                  elevation: 0, // 0 para un look plano y moderno
                  // 2. Título estilizado
                  title: Text(
                    'Historial de Movimientos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Título en negrita
                      fontSize: 20,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface, // Color de texto basado en el tema
                    ),
                  ),

                  // 3. Altura de la barra (opcional pero profesional)
                  toolbarHeight:
                      64.0, // Un poco más de altura para un mejor 'feel'
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
                    color: Theme.of(
                      context,
                    ).colorScheme.primary, // Íconos con color primario del tema
                  ),
                )
              : null,

          body: Column(
            children: [
              // Buscador y Filtros (sin cambios)
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        fontSize:
                            14.0, // <-- Cambia el tamaño de la fuente del label
                        color: AppColors
                            .textSecondary, // (Opcional: define el color del label)
                      ),

                      filled: true,
                      fillColor: AppColors.secondary,
                      labelText: 'Buscar por el nombre del producto...',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          width: 3.0, // <-- Tu grosor deseado
                          color: AppColors.border, // Color del borde
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          width:
                              3.0, // <-- Puedes poner un grosor mayor al enfocar
                          color: AppColors
                              .textSecondary, // Color del borde al enfocar
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    _buildDateRangeFilter(),
                    _buildMovementTypeFilter(),
                    _buildUserFilter(),
                  ],
                ),
              ),
              //const Divider(height: 24),

              // Lista/Tabla
              Center(
                child: Expanded(
                  // Empieza directamente comprobando si está vacía
                  child: _filteredMovements.isEmpty
                      ? const Center(
                          child: Text('No se encontraron movimientos.'),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            bool isDesktop = constraints.maxWidth > 700;
                            return isDesktop
                                ? _buildMovementsDataTable()
                                : _buildMovementsListView();
                          },
                        ),
                ),
              ),
            ],
          ),
          drawer: isWide ? null : MySideBar(controller: widget.controller),
          // drawer: isWide ? null : MySideBar(controller: widget.controller),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Ajuste Manual'),
            onPressed: () => _showAddMovementModal(context),
          ),
        );
      },
    );
  }
} // Fin de _MovementsScreenState

class MovementsWideLayout extends StatelessWidget {
  const MovementsWideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MovementsNarrowLayot extends StatelessWidget {
  const MovementsNarrowLayot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
