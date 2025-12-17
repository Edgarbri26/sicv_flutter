import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/models/product/stock_option_model.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  final ProductModel product;
  const AddProductSheet({super.key, required this.product});

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _selectedDepotId;
  int? _selectedLotId;
  int _maxStock = 0;
  String? _errorMessage; // Para mostrar errores generales sin usar SnackBar

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _updateMaxStock(List<StockOptionModel> allStock) {
    if (_selectedDepotId == null) {
      _maxStock = 0;
      return;
    }

    // Filtrar lotes del depósito seleccionado
    final depotItems = allStock
        .where((i) => i.depotId == _selectedDepotId)
        .toList();

    if (widget.product.perishable) {
      // Si es perecedero, el stock depende del LOTE específico
      if (_selectedLotId != null) {
        final lot = depotItems.firstWhere(
          (i) => i.lotId == _selectedLotId,
          orElse: () => StockOptionModel(
            depotId: 0,
            depotName: '',
            amount: 0,
            isLot: false,
          ),
        );
        _maxStock = lot.amount;
      } else {
        _maxStock = 0;
      }
    } else {
      // Si NO es perecedero, sumamos todo lo del depósito
      _maxStock = depotItems.fold(0, (sum, item) => sum + item.amount);
    }
    setState(() {});
  }

  void _incrementQty() {
    int current = int.tryParse(_qtyController.text) ?? 0;
    if (current < _maxStock) {
      _qtyController.text = (current + 1).toString();
    }
  }

  void _decrementQty() {
    int current = int.tryParse(_qtyController.text) ?? 0;
    if (current > 1) {
      _qtyController.text = (current - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productStockDetailProvider(widget.product.id), (previous, next) {
      next.whenData((stockList) {
        final uniqueDepots = {for (var e in stockList) e.depotId: e.depotName};

        if (uniqueDepots.length == 1 && _selectedDepotId == null) {
          _selectedDepotId = uniqueDepots.keys.first;
          _updateMaxStock(stockList);
        } else if (_selectedDepotId != null) {
          _updateMaxStock(stockList);
        }
      });
    });

    final stockAsync = ref.watch(productStockDetailProvider(widget.product.id));

    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ENCABEZADO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Precio: \$${widget.product.price}",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // --- CARGA DE DATOS ---
            stockAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, _) => Text(
                "Error: $e",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (stockList) {
                if (stockList.isEmpty) {
                  return Text(
                    "Sin stock disponible",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  );
                }

                final uniqueDepots = {
                  for (var e in stockList) e.depotId: e.depotName,
                };

                // Lista de lotes filtrada (si aplica)
                final availableLots = _selectedDepotId == null
                    ? <StockOptionModel>[]
                    : stockList
                          .where((e) => e.depotId == _selectedDepotId)
                          .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. SELECCIÓN DE DEPÓSITO (Estilo CHIPS) ---
                    const Text(
                      "Selecciona Depósito:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: uniqueDepots.entries.map((entry) {
                        final isSelected = _selectedDepotId == entry.key;
                        return ChoiceChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDepotId = entry.key;
                                _selectedLotId = null; // Reset lote
                                _errorMessage = null;
                                _updateMaxStock(stockList);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    if (_selectedDepotId == null && _errorMessage != null)
                      Text(
                        "Debes seleccionar un depósito",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),

                    const SizedBox(height: 20),

                    if (widget.product.perishable &&
                        availableLots.isNotEmpty) ...[
                      const Text(
                        "Selecciona Lote:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: availableLots.map((lot) {
                          final isSelected = _selectedLotId == lot.lotId;
                          final expirationDate = lot.expiration != null
                              ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(DateTime.parse(lot.expiration!))
                              : 'N/A';

                          return ChoiceChip(
                            label: Text(
                              "Lote #${lot.lotId} - Vence: $expirationDate (${lot.amount})",
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedLotId = lot.lotId;
                                  _updateMaxStock(stockList);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- 3. CANTIDAD (Estilo STEPPER) ---
                    Row(
                      children: [
                        const Text(
                          "Cantidad:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // Botón Menos
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _selectedDepotId == null
                                ? null
                                : _decrementQty,
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Campo de Texto
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            controller: _qtyController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            validator: (val) {
                              final num = int.tryParse(val ?? '');
                              if (num == null || num <= 0) return '!';
                              if (num > _maxStock) {
                                return '!'; // Validación visual simple
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Botón Más
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _selectedDepotId == null
                                ? null
                                : _incrementQty,
                          ),
                        ),
                      ],
                    ),

                    // Texto informativo de Stock
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        _selectedDepotId == null
                            ? "Selecciona un depósito primero"
                            : "Stock disponible: $_maxStock",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color:
                              (int.tryParse(_qtyController.text) ?? 0) >
                                  _maxStock
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Error general en texto rojo (Sustituto del SnackBar)
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // --- 4. BOTÓN DE ACCIÓN ---
                    ButtonApp(
                      text: "AGREGAR AL CARRITO",
                      fullWidth: true,
                      icon: Icons.add_shopping_cart,
                      onPressed: () {
                        // ... (validation logic unchanged)
                        if (_selectedDepotId == null) {
                          setState(
                            () => _errorMessage = "Selecciona un depósito",
                          );
                          return;
                        }
                        // Validación del Formulario
                        if (!_formKey.currentState!.validate()) {
                          setState(
                            () => _errorMessage =
                                "Verifica la cantidad y el lote",
                          );
                          return;
                        }

                        final amount = int.tryParse(_qtyController.text) ?? 0;

                        if (amount > _maxStock) {
                          setState(
                            () => _errorMessage =
                                "La cantidad excede el stock ($_maxStock)",
                          );
                          return;
                        }

                        // --- NUEVA LÓGICA PARA OBTENER LOS NOMBRES ---
                        String tempDepotName = "Depósito Desconocido";
                        String? tempExpirationInfo;

                        // 1. Buscamos el objeto del depósito seleccionado
                        if (_selectedDepotId != null) {
                          // stockList está disponible porque estamos dentro del .when(data: stockList)
                          final depotItem = stockList.firstWhere(
                            (e) => e.depotId == _selectedDepotId,
                            orElse: () => StockOptionModel(
                              depotId: 0,
                              depotName: '?',
                              amount: 0,
                              isLot: false,
                            ),
                          );
                          tempDepotName = depotItem.depotName;
                        }

                        // 2. Buscamos la info del lote/vencimiento seleccionado
                        if (_selectedLotId != null) {
                          final lotItem = stockList.firstWhere(
                            (e) => e.lotId == _selectedLotId,
                            orElse: () => StockOptionModel(
                              depotId: 0,
                              depotName: '',
                              amount: 0,
                              isLot: false,
                            ),
                          );
                          // Aquí usamos tu getter displayLabel o formateamos la fecha
                          tempExpirationInfo = lotItem.displayLabel;
                          // O si prefieres solo la fecha: item.expiration
                        }
                        final newItem = SaleItemModel(
                          productId: widget.product.id,
                          depotId: _selectedDepotId!,
                          stockLotId: _selectedLotId,
                          unitPriceUsd: widget.product.price,
                          unitPriceBs: widget.product.priceBs,
                          amount: amount,
                          productName: widget.product.name,

                          // GUARDAMOS LA INFO VISUAL:
                          depotName: tempDepotName,
                          expirationInfo: tempExpirationInfo,
                        );

                        Navigator.pop(context, newItem);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
