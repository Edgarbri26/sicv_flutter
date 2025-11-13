// lib/ui/screen/movements_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
// Importa tus modelos
// Necesario para el modelo Product
import 'package:sicv_flutter/models/movement_type.dart';
import 'package:sicv_flutter/models/movement.dart'; // Asegúrate que este sea el nombre correcto
import 'package:sicv_flutter/models/product.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sidebarx/sidebarx.dart';

class MovementsPage extends StatefulWidget {
  final SidebarXController controller;
  const MovementsPage({super.key, required this.controller});

  @override
  State<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends State<MovementsPage> {
  // --- Estado ---
  late List<StockMovement> _allMovements;
  late List<StockMovement> _filteredMovements;
  final TextEditingController _searchController = TextEditingController();

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
  // --- ¡IMPORTANTE! Mueve la lista de productos aquí ---
  // Esta lista (_allProducts) debe estar disponible para el diálogo
  // Asegúrate de que esta lista se cargue/actualice correctamente desde tu API
  late List<Product> _allProducts;

  @override
  void initState() {
    super.initState();
    // Primero carga los productos (necesario para el diálogo)
    _loadProducts(); // Función separada para productos
    // Luego carga los movimientos
    _loadMovements(); // Función separada para movimientos
    _searchController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Carga productos (simulación)
  void _loadProducts() {
    // --- SIMULACIÓN DE PRODUCTOS ---
    _allProducts = [
      // Product(
      //   id: 1,
      //   name: 'Harina PAN',
      //   description: '...',
      //   price: 1.40,
      //   stock: 50,
      //   category: ProductCategory(id: 1, name: 'Alimentos'),
      //   sku: 'ALI-001',
      // ),
      // Product(
      //   id: 2,
      //   name: 'Cigarros Marlboro',
      //   description: '...',
      //   price: 5.99,
      //   stock: 5,
      //   category: ProductCategory(id: 2, name: 'Tabaco'),
      //   sku: 'TAB-001',
      // ),
      // Product(
      //   id: 3,
      //   name: 'Café',
      //   description: '...',
      //   price: 10.99,
      //   stock: 0,
      //   category: ProductCategory(id: 3, name: 'Bebidas'),
      //   sku: 'BEB-001',
      // ),
      // Product(
      //   id: 4,
      //   name: 'Gaseosa 2L',
      //   description: '...',
      //   price: 2.5,
      //   stock: 50,
      //   category: ProductCategory(id: 3, name: 'Bebidas'),
      //   sku: 'BEB-002',
      // ),
      // Product(
      //   id: 5,
      //   name: 'Pan Campesino',
      //   description: '...',
      //   price: 2.0,
      //   stock: 15,
      //   category: ProductCategory(id: 1, name: 'Alimentos'),
      //   sku: 'ALI-002',
      // ),
      // Product(
      //   id: 6,
      //   name: 'Agua Minalba 1L',
      //   description: '...',
      //   price: 1.0,
      //   stock: 30,
      //   category: ProductCategory(id: 3, name: 'Bebidas'),
      //   sku: 'BEB-003',
      // ),
    ];
    // --- FIN SIMULACIÓN ---

    // Llama a setState si esta carga fuera asíncrona
    // setState((){});
  }

  // Carga movimientos (simulación)
  void _loadMovements() {
    // --- SIMULACIÓN DE DATOS (Reemplaza con tu API) ---
    final now = DateTime.now();
    _allMovements = [
      StockMovement(
        dateTime: now.subtract(const Duration(hours: 1)),
        productName: 'Harina PAN',
        productSku: 'ALI-001',
        movementType: MovementType.venta,
        quantity: -2,
        stockBefore: 52,
        stockAfter: 50,
        userName: 'Vendedor1',
        referenceId: 'VTA-101',
      ),
      StockMovement(
        dateTime: now.subtract(const Duration(hours: 3)),
        productName: 'Gaseosa 2L',
        productSku: 'BEB-002',
        movementType: MovementType.compra,
        quantity: 24,
        stockBefore: 26,
        stockAfter: 50,
        userName: 'Admin',
        referenceId: 'CMP-050',
      ),
      StockMovement(
        dateTime: now.subtract(const Duration(days: 1)),
        productName: 'Cigarros Marlboro',
        productSku: 'TAB-001',
        movementType: MovementType.venta,
        quantity: -1,
        stockBefore: 6,
        stockAfter: 5,
        userName: 'Vendedor1',
        referenceId: 'VTA-100',
      ),
      StockMovement(
        dateTime: now.subtract(const Duration(days: 2)),
        productName: 'Harina PAN',
        productSku: 'ALI-001',
        movementType: MovementType.compra,
        quantity: 50,
        stockBefore: 2,
        stockAfter: 52,
        userName: 'Admin',
        referenceId: 'CMP-048',
      ),
      StockMovement(
        dateTime: now.subtract(const Duration(days: 3)),
        productName: 'Café',
        productSku: 'BEB-001',
        movementType: MovementType.ajusteNegativo,
        quantity: -1,
        stockBefore: 1,
        stockAfter: 0,
        userName: 'Admin',
        referenceId: 'Ajuste por daño',
      ),
      StockMovement(
        dateTime: now.subtract(const Duration(days: 8)),
        productName: 'Gaseosa 2L',
        productSku: 'BEB-002',
        movementType: MovementType.venta,
        quantity: -4,
        stockBefore: 30,
        stockAfter: 26,
        userName: 'Vendedor2',
        referenceId: 'VTA-095',
      ),
    ];
    _allMovements.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    _filteredMovements = _allMovements;
    _runFilter(); // Aplica filtros iniciales
    // --- FIN SIMULACIÓN ---
  }

  void _runFilter() {
    // Verifica que _allMovements no sea null antes de usarla
    List<StockMovement> results = _allMovements;
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
                  m.dateTime.isAfter(startDate) &&
                  m.dateTime.isBefore(DateTime(now.year, now.month, now.day)),
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
      results = results.where((m) => m.dateTime.isAfter(startDate)).toList();
    }

    // 2. Filtrar por Tipo de Movimiento
    if (_selectedMovementType != null) {
      results = results
          .where((m) => m.movementType == _selectedMovementType)
          .toList();
    }

    // Se ejecuta solo si _selectedUser NO es null (es decir, no es 'Todos')
    if (_selectedUser != null && _selectedUser!.isNotEmpty) {
      results = results.where((m) => m.userName == _selectedUser).toList();
    }

    // 3. Filtrar por Texto de Búsqueda
    if (searchText.isNotEmpty) {
      results = results
          .where(
            (m) =>
                m.productName.toLowerCase().contains(searchText) ||
                (m.productSku ?? '').toLowerCase().contains(searchText),
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
            aValue = a.dateTime;
            bValue = b.dateTime;
            break;
          case 1: // ✅ Producto (Nombre)
            // Usar ?? '' para manejar nulls de forma segura en Strings
            aValue = a.productName;
            bValue = b.productName;
            break;
          case 2: // ✅ Tipo (MovementType)
            // Convertir el enum o tipo a String para poder compararlo
            aValue = a.movementType.toString();
            bValue = b.movementType.toString();
            break;
          case 3: // ✅ Cant. (Quantity)
            aValue = a.quantity;
            bValue = b.quantity;
            break;
          // Los casos 4 y 5 (Stock Ant./Desp.) no tienen onSort, se omite.
          case 6: // ✅ Usuario
            // Usar ?? '' para manejar nulls de forma segura en Strings
            aValue = a.userName;
            bValue = b.userName;
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

  @override
  Widget build(BuildContext context) {
    //final double breakpoint = 600.0;
    //final bool isWide = MediaQuery.of(context).size.width >= breakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface, // Color de texto basado en el tema
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
          color: Theme.of(
            context,
          ).colorScheme.primary, // Íconos con color primario del tema
        ),
      ),
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
                      width: 3.0, // <-- Puedes poner un grosor mayor al enfocar
                      color:
                          AppColors.textSecondary, // Color del borde al enfocar
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
                  ? const Center(child: Text('No se encontraron movimientos.'))
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
      drawer: MySideBar(controller: widget.controller),
      // drawer: isWide ? null : MySideBar(controller: widget.controller),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Ajuste Manual'),
        onPressed: () => _showAddMovementModal(context),
      ),
    );
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
        .map((m) => m.userName)
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
            // Índice de Columna 4: Stock Ant. (Sin onSort, por defecto)
            DataColumn(
              label: Text(
                'Stock Ant.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            // Índice de Columna 5: Stock Desp. (Sin onSort, por defecto)
            DataColumn(
              label: Text(
                'Stock Desp.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            final qtyColor = movement.quantity >= 0
                ? Colors.green.shade700
                : Colors.red.shade700;
            final qtyPrefix = movement.quantity > 0
                ? '+'
                : ''; // Solo '+' si es positivo

            return DataRow(
              cells: [
                DataCell(
                  Text(dateFormat.format(movement.dateTime)),
                ), // Fecha formateada
                DataCell(
                  Tooltip(
                    // Añade Tooltip si el nombre es largo
                    message:
                        '${movement.productName}\nSKU: ${movement.productSku ?? 'N/A'}',
                    child: Text(
                      movement.productName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      // Muestra ícono y nombre del tipo
                      Icon(
                        movement.movementType.icon,
                        color: movement.movementType.color,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(movement.movementType.displayName),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    // Cantidad con color y signo
                    qtyPrefix + movement.quantity.toString(),
                    style: TextStyle(
                      color: qtyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(movement.stockBefore.toString())), // Stock antes
                DataCell(Text(movement.stockAfter.toString())), // Stock después
                DataCell(Text(movement.userName)), // Usuario
                DataCell(
                  Tooltip(
                    // Tooltip para referencias largas
                    message: movement.referenceId ?? '-',
                    child: Text(
                      movement.referenceId ?? '-',
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
        final qtyColor = movement.quantity >= 0
            ? Colors.green.shade700
            : Colors.red.shade700;
        final qtyPrefix = movement.quantity >= 0 ? '+' : '';

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
              message: movement.movementType.displayName,
              child: Icon(
                movement.movementType.icon,
                color: movement.movementType.color,
              ),
            ),
            title: Text(
              '${movement.productName} (${movement.productSku ?? 'N/A'})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${dateFormat.format(movement.dateTime)} - ${movement.userName}\n' // Fecha y usuario
              'Ref: ${movement.referenceId ?? '-'} | Stock: ${movement.stockBefore} -> ${movement.stockAfter}', // Referencia y cambio de stock
            ),
            trailing: Text(
              // Cantidad al final
              qtyPrefix + movement.quantity.toString(),
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
    Product? selectedProduct;

    // Lista de productos para el Dropdown (aseguramos que no sea null)
    final List<Product> productsForSelection = _allProducts;

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
                            DropdownButtonFormField<Product>(
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
                                          '${product.name} (Stock: ${product.stock})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                              onChanged: productsForSelection.isEmpty
                                  ? null
                                  : (Product? newValue) {
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
    Product product,
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
    final int currentStock = currentProductData.stock!;
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

    final newMovement = StockMovement(
      dateTime: DateTime.now(),
      productName: product.name,
      productSku: product.sku,
      movementType: selectedAdjustmentType,
      quantity: signedQuantity,
      stockBefore: currentStock,
      stockAfter: stockAfter,
      userName: 'UsuarioActual', // Reemplaza
      referenceId: reasonController.text.isNotEmpty
          ? reasonController.text
          : 'Ajuste manual',
    );

    // --- LLAMADA A API Y ACTUALIZACIÓN LOCAL (dentro del setState de la página) ---
    setState(() {
      _allMovements.insert(0, newMovement);

      // Actualiza el stock en la lista _allProducts (simulación de mutación de stock)
      final productIndex = _allProducts.indexWhere((p) => p.id == product.id);
      if (productIndex != -1) {
        // Usa copyWith (idealmente) o crea un nuevo objeto para actualizar la lista
        _allProducts[productIndex] = Product(
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
          stock: stockAfter, // Stock actualizado
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
} // Fin de _MovementsScreenState
