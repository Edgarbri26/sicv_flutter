import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/movement/movement_model.dart';
import 'package:sicv_flutter/models/movement/movement_type.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/models/product/stock_lot_model.dart';
import 'package:sicv_flutter/providers/auth_provider.dart';
import 'package:sicv_flutter/providers/movement_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/services/movement_service.dart';
import 'package:sicv_flutter/services/stock_lot_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class AddMovementModal extends ConsumerStatefulWidget {
  const AddMovementModal({super.key});

  // Método estático para llamar al modal fácilmente
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddMovementModal(),
    );
  }

  @override
  ConsumerState<AddMovementModal> createState() => _AddMovementModalState();
}

class _AddMovementModalState extends ConsumerState<AddMovementModal> {
  final _stockLotService = StockLotService();
  final _quantityCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  MovementType _selectedType = MovementType.ajustePositivo;
  ProductModel? _selectedProduct;
  DateTime? _expirationDate;
  int? _selectedLotId;
  
  List<StockLotModel> _availableLots = [];
  bool _isLoadingLots = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _reasonCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LOTES ---
  Future<void> _fetchLots(int productId) async {
    setState(() { 
      _isLoadingLots = true; 
      _availableLots = []; 
      _selectedLotId = null; 
    });
    
    try {
      final lots = await _stockLotService.getByProduct(productId);
      lots.sort((a, b) => a.expirationDate.compareTo(b.expirationDate)); // FEFO
      if (mounted) setState(() => _availableLots = lots);
    } catch (e) {
      debugPrint("Error lotes: $e");
    } finally {
      if (mounted) setState(() => _isLoadingLots = false);
    }
  }

  // --- LÓGICA DE GUARDADO ---
  Future<void> _handleSave() async {
    // 1. Obtener usuario (Riverpod 2.0 style)
    final user = ref.read(authProvider).value; 
    if (user == null) {
      _showError("No hay sesión activa");
      return;
    }

    // 2. Validar cantidad
    final qty = int.tryParse(_quantityCtrl.text);
    if (qty == null || qty <= 0) {
      _showError("Cantidad inválida");
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 3. Crear modelo
      final movement = MovementModel.forCreation(
        depotId: 1, 
        product: _selectedProduct!,
        type: _selectedType.displayName,
        amount: qty.toDouble(),
        userCi: user.userCi,
        observation: _reasonCtrl.text.isEmpty ? 'Ajuste Manual' : _reasonCtrl.text,
      );

      // 4. Enviar al servicio (usando el método genérico que fusiona datos)
      await MovementService().createAdjustment(
        movement,
        extraData: {
          if (_expirationDate != null) 'date_expiration': _expirationDate!.toIso8601String(),
          if (_selectedLotId != null) 'stock_lot_id': _selectedLotId,
        },
      );

      // 5. Refrescar listas
      ref.invalidate(productsProvider); // Actualiza el stock en la lista de productos
      ref.invalidate(movementsProvider); // Actualiza la tabla de movimientos

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajuste guardado'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final isPerishable = _selectedProduct?.perishable ?? false;

    // Calculamos padding inferior para el teclado
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 16;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuevo Ajuste de Inventario', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. PRODUCTO
                  productsAsync.when(
                    data: (products) => DropDownApp<ProductModel>(
                      labelText: 'Producto',
                      prefixIcon: Icons.shopping_bag_outlined,
                      items: products,
                      initialValue: _selectedProduct,
                      itemToString: (p) => '${p.name} (Stock: ${p.totalStock})',
                      onChanged: (p) {
                        setState(() {
                          _selectedProduct = p;
                          // Resetear campos dependientes
                          _expirationDate = null; 
                          _dateCtrl.clear();
                          _selectedLotId = null; 
                          _availableLots = [];
                        });
                        if (p != null && p.perishable) _fetchLots(p.id);
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_,__) => const Text("Error cargando productos"),
                  ),
                  const SizedBox(height: 16),

                  // 2. TIPO
                  DropDownApp<MovementType>(
                    labelText: 'Tipo',
                    prefixIcon: Icons.swap_vert,
                    initialValue: _selectedType,
                    items: const [MovementType.ajustePositivo, MovementType.ajusteNegativo],
                    itemToString: (t) => t.displayName,
                    onChanged: (t) {
                      if (t != null) setState(() => _selectedType = t);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. PERECEDEROS
                  if (isPerishable) ...[
                    // Caso Entrada: Fecha Vencimiento
                    if (_selectedType == MovementType.ajustePositivo)
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context, initialDate: DateTime.now(),
                            firstDate: DateTime.now(), lastDate: DateTime(2100)
                          );
                          if (picked != null) {
                            setState(() {
                              _expirationDate = picked;
                              _dateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFieldApp(
                            controller: _dateCtrl,
                            labelText: 'Fecha Vencimiento',
                            prefixIcon: Icons.calendar_today,
                          ),
                        ),
                      ),
                    
                    // Caso Salida: Lote
                    if (_selectedType == MovementType.ajusteNegativo)
                      _isLoadingLots 
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ))
                        : _availableLots.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: const Row(children: [
                                Icon(Icons.warning, color: Colors.orange), 
                                SizedBox(width: 8), 
                                Expanded(child: Text("Sin lotes disponibles"))
                              ]),
                            )
                          : DropDownApp<int>(
                              labelText: 'Lote a descontar',
                              prefixIcon: Icons.layers,
                              initialValue: _selectedLotId,
                              items: _availableLots.map((l) => l.stockLotId).toList(),
                              itemToString: (id) {
                                final lot = _availableLots.firstWhere((l) => l.stockLotId == id, orElse: () => _availableLots.first);
                                return lot.displayLabel;
                              },
                              onChanged: (v) => setState(() => _selectedLotId = v),
                            ),
                    const SizedBox(height: 16),
                  ],

                  // 4. CANTIDAD
                  TextFieldApp(
                    controller: _quantityCtrl,
                    labelText: 'Cantidad',
                    prefixIcon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),

                  // 5. MOTIVO
                  TextFieldApp(
                    controller: _reasonCtrl,
                    labelText: 'Motivo',
                    prefixIcon: Icons.comment,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // --- BOTONES (CORREGIDO EL ERROR DE INFINITE WIDTH) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("CANCELAR")
              ),
              const SizedBox(width: 8),
              
              // AQUÍ ESTABA EL ERROR: El estilo del botón no debe tener ancho infinito en un Row
              ElevatedButton.icon(
                icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
                label: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Text("GUARDAR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  // Usamos Size(0, 45) para que se adapte al contenido, no al infinito
                  minimumSize: const Size(0, 45), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSaving ? null : () {
                  // Validaciones simples antes de llamar a guardar
                  if (_selectedProduct == null) return;
                  if (_quantityCtrl.text.isEmpty) return;
                  
                  if (isPerishable) {
                    if (_selectedType == MovementType.ajustePositivo && _expirationDate == null) return;
                    if (_selectedType == MovementType.ajusteNegativo && _selectedLotId == null) return;
                  }
                  
                  _handleSave();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}