// lib/ui/screen/movements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/movement_model.dart';
import 'package:sicv_flutter/models/movement_type.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
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
  bool _isLoading = true; // <--- NUEVO: Control de carga
  List<MovementModel> _allMovements = [];
  List<MovementModel> _filteredMovements = [];
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];

  // Filtros
  MovementType? _selectedMovementType;
  String _selectedDateRange = 'Últimos 7 días';
  final List<String> _dateRangeOptions = [
    'Hoy',
    'Ayer',
    'Últimos 7 días',
    'Este mes',
    'Todos',
  ];
  
  // Ordenamiento
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_runFilter);
    // Usamos microtask para cargar datos después del primer frame
    Future.microtask(() => _loadMovements());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoading = true); // Activa loading

    try {
      final movements = await MovementService().getAll();
      
      if (!mounted) return;

      setState(() {
        _allMovements = movements;
        // Orden por defecto: Fecha descendente
        _allMovements.sort((a, b) => b.movedAt.compareTo(a.movedAt));
        _filteredMovements = _allMovements;
        _isLoading = false; // Desactiva loading
      });
      
      _runFilter();
    } catch (e) {
      print("Error cargando movimientos: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _runFilter() {
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
        // Caso especial ayer: Rango específico de 24h pasadas
        results = results.where((m) => 
          m.movedAt.isAfter(startDate) && 
          m.movedAt.isBefore(DateTime(now.year, now.month, now.day))
        ).toList();
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

    // 2. Filtrar por Tipo
    if (_selectedMovementType != null) {
      results = results.where((m) => m.type == _selectedMovementType!.displayName).toList();
    }

    // 3. Filtrar por Usuario
    if (_selectedUser != null && _selectedUser!.isNotEmpty) {
      results = results.where((m) => m.user?.name == _selectedUser).toList();
    }

    // 4. Búsqueda Texto
    if (searchText.isNotEmpty) {
      results = results.where((m) {
        final productName = m.product?.name.toLowerCase() ?? '';
        final obs = m.observation.toLowerCase();
        return productName.contains(searchText) || obs.contains(searchText);
      }).toList();
    }

    // 5. Ordenamiento
    if (_sortColumnIndex != null) {
      results.sort((a, b) {
        dynamic aValue, bValue;
        
        switch (_sortColumnIndex) {
          case 0: // Fecha
            aValue = a.movedAt; bValue = b.movedAt; break;
          case 1: // Producto
            aValue = a.product?.name ?? ''; bValue = b.product?.name ?? ''; break;
          case 2: // Tipo
            aValue = a.type; bValue = b.type; break;
          case 3: // Cantidad
            aValue = a.amount; bValue = b.amount; break;
          case 4: // Usuario
            aValue = a.user?.name ?? ''; bValue = b.user?.name ?? ''; break;
          default:
            return 0;
        }
        
        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    setState(() {
      _filteredMovements = results;
    });
  }

  // --- Widgets de Filtros ---

  Widget _buildDateRangeFilter() {
    return DropdownButton<String>(
      value: _selectedDateRange,
      items: _dateRangeOptions.map((range) {
        return DropdownMenuItem(value: range, child: Text(range));
      }).toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() => _selectedDateRange = v);
          _runFilter();
        }
      },
      hint: const Text('Periodo'),
    );
  }

  Widget _buildMovementTypeFilter() {
    return DropdownButton<MovementType>(
      value: _selectedMovementType,
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos los tipos')),
        ...MovementType.values.map((type) => DropdownMenuItem(
          value: type,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type.icon, color: type.color, size: 18),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        )),
      ],
      onChanged: (v) {
        setState(() => _selectedMovementType = v);
        _runFilter();
      },
      hint: const Text('Tipo'),
    );
  }

  Widget _buildUserFilter() {
    final uniqueUsers = _allMovements
        .map((m) => m.user?.name)
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .toSet().toList();

    List<String?> userOptions = [null, ...uniqueUsers];

    return DropdownButton<String>(
      value: _selectedUser,
      hint: const Text('Usuario'),
      items: userOptions.map((user) {
        return DropdownMenuItem(
          value: user,
          child: Text(user ?? 'Todos los usuarios'),
        );
      }).toList(),
      onChanged: (v) {
        setState(() => _selectedUser = v);
        _runFilter();
      },
    );
  }

  // --- Tablas y Listas ---

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _runFilter();
    });
  }

  Widget _buildMovementsDataTable() {
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    // SOLUCIÓN DE SCROLL: 
    // Scroll Vertical externo + Scroll Horizontal interno para la tabla
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Permite bajar si la lista es larga
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Permite mover a la derecha si es ancha
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            dataRowColor: WidgetStateProperty.all(AppColors.background),
            headingRowColor: WidgetStateProperty.all(AppColors.border),
            headingRowHeight: 48.0,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            columns: [
              DataColumn(label: const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
              DataColumn(label: const Text('Producto', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
              DataColumn(label: const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
              DataColumn(label: const Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort, numeric: true),
              DataColumn(label: const Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
              const DataColumn(label: Text('Referencia', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _filteredMovements.map((movement) {
              final isPositive = movement.amount >= 0;
              final qtyColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
              
              return DataRow(
                cells: [
                  DataCell(Text(dateFormat.format(movement.movedAt))),
                  DataCell(
                    Tooltip(
                      message: 'SKU: ${movement.product ?? 'N/A'}',
                      child: Text(movement.product?.name ?? 'Producto desconocido'),
                    ),
                  ),
                  DataCell(Text(movement.type)),
                  DataCell(Text(
                    '${isPositive && movement.amount > 0 ? '+' : ''}${movement.amount}',
                    style: TextStyle(color: qtyColor, fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(movement.user?.name ?? 'N/A')),
                  DataCell(
                    Tooltip(
                      message: movement.observation,
                      child: SizedBox(
                        width: 150, // Limita el ancho de la observación
                        child: Text(movement.observation, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementsListView() {
    final dateFormat = DateFormat('dd/MM/yy HH:mm');
    // ScrollView directo, sin Center
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Espacio para el FAB
      itemCount: _filteredMovements.length,
      itemBuilder: (context, index) {
        final movement = _filteredMovements[index];
        final isPositive = movement.amount >= 0;
        final qtyColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;

        return Card(
          elevation: 0,
          color: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.border, width: 1.5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(
              Icons.circle, 
              size: 12, 
              color: isPositive ? Colors.green : Colors.orange
            ),
            title: Text(
              movement.product?.name ?? 'Desconocido',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('${dateFormat.format(movement.movedAt)} • ${movement.user?.name}'),
                 Text('Ref: ${movement.observation}', maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: Text(
              '${isPositive && movement.amount > 0 ? '+' : ''}${movement.amount}',
              style: TextStyle(color: qtyColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  // --- Modal y Guardado ---

  void _showAddMovementModal(BuildContext context) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    MovementType selectedAdjustmentType = MovementType.ajustePositivo;
    ProductModel? selectedProduct;
    
    // Lista segura
    final List<ProductModel> productsForSelection = _allProducts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: MediaQuery.of(dialogContext).viewInsets,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registrar Ajuste Manual', style: Theme.of(context).textTheme.headlineSmall),
                    const Divider(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            DropdownButtonFormField<ProductModel>(
                              value: selectedProduct,
                              hint: const Text('Selecciona Producto...'),
                              isExpanded: true,
                              items: productsForSelection.map((p) => DropdownMenuItem(
                                value: p,
                                child: Text('${p.name} (Stock: ${p.totalStock})'),
                              )).toList(),
                              onChanged: (v) => setStateDialog(() => selectedProduct = v),
                              decoration: _inputDecoration('Producto'),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<MovementType>(
                              value: selectedAdjustmentType,
                              items: [MovementType.ajustePositivo, MovementType.ajusteNegativo].map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.displayName),
                              )).toList(),
                              onChanged: (v) {
                                if(v!=null) setStateDialog(() => selectedAdjustmentType = v);
                              },
                              decoration: _inputDecoration('Tipo de Ajuste'),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: _inputDecoration('Cantidad', icon: Icons.numbers),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: reasonController,
                              maxLines: 2,
                              decoration: _inputDecoration('Razón (Opcional)'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('CANCELAR'),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('GUARDAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: selectedProduct == null 
                            ? null 
                            : () => _handleSaveAdjustment(context, dialogContext, selectedProduct!, selectedAdjustmentType, quantityController, reasonController),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      quantityController.dispose();
      reasonController.dispose();
    });
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border, width: 2),
      ),
    );
  }

  void _handleSaveAdjustment(
    BuildContext context, 
    BuildContext dialogContext, 
    ProductModel product, 
    MovementType type, 
    TextEditingController qtyCtrl, 
    TextEditingController reasonCtrl
  ) {
    final quantity = int.tryParse(qtyCtrl.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cantidad inválida'), backgroundColor: Colors.orange));
      return;
    }

    final signedQuantity = (type == MovementType.ajustePositivo) ? quantity : -quantity;
    final stockAfter = product.totalStock + signedQuantity;

    if (stockAfter < 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock no puede ser negativo ($stockAfter)'), backgroundColor: Colors.red));
      return;
    }

    // Aquí simulas la creación. En producción, esto viene del Backend
    final newMovement = MovementModel(
      movementId: 0,
      depotId: 1,
      movedAt: DateTime.now(),
      productId: product.id,
      type: type.displayName,
      amount: signedQuantity,
      userCi: "31350493", // Hardcoded temporalmente
      observation: reasonCtrl.text.isEmpty ? 'Ajuste manual' : reasonCtrl.text,
      status: true,
      // IMPORTANTE: Asegúrate de pasar el objeto product aquí para que la tabla lo lea
      // product: ProductSummaryModel(...) si usas el DTO, o el product mismo si usas el modelo completo
    );

    setState(() {
      // Simulación de actualización local optimista
      _allMovements.insert(0, newMovement);
      
      // Actualizar stock localmente (Opcional, idealmente recargarías de la API)
      final index = _allProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _allProducts[index].quantity = stockAfter; // O el campo que uses para stock
      }
      _runFilter();
    });

    Navigator.pop(dialogContext);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajuste guardado'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en productos
    ref.listen(productsProvider, (previous, next) {
      next.whenData((products) => setState(() => _allProducts = products));
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: !isWide ? AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Movimientos', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
            elevation: 0,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
          ) : null,
          drawer: isWide ? null : MySideBar(controller: widget.controller),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('Ajuste'),
            onPressed: () => _showAddMovementModal(context),
          ),
          body: Center(
            child: Column(
              children: [
                // --- Header y Filtros ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      controller: _searchController,
                      decoration: _inputDecoration('Buscar producto...', icon: Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildDateRangeFilter(),
                      _buildMovementTypeFilter(),
                      _buildUserFilter(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
            
                // --- Cuerpo (Loading / Empty / Data) ---
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator()) // LOADING STATE
                    : _filteredMovements.isEmpty
                      ? const Center(child: Text('No se encontraron movimientos.'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return constraints.maxWidth > 700
                                ? _buildMovementsDataTable()
                                : _buildMovementsListView();
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}