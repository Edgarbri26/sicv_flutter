import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/models/index.dart';
import 'package:sicv_flutter/providers/cliente_provider.dart';
import 'package:sicv_flutter/providers/type_payment_provider.dart';
import 'package:sicv_flutter/ui/skeletom/cartd_sceleton.dart';
import 'package:sicv_flutter/ui/widgets/add_client_form.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/sale/sale_item_card.dart';

class SaleDetailModal extends ConsumerStatefulWidget {
  final List<SaleItemModel> items;
  final ClientModel? initialClient;
  final TypePaymentModel? initialTypePayment;
  final ValueChanged<ClientModel?> onClientChanged;
  final ValueChanged<TypePaymentModel?> onTypePaymentChanged;
  final VoidCallback onRestart;
  final Future<void> Function(
    BuildContext context,
    GlobalKey<ScaffoldMessengerState> messengerKey,
  )
  onConfirm;

  const SaleDetailModal({
    super.key,
    required this.items,
    this.initialClient,
    this.initialTypePayment,
    required this.onClientChanged,
    required this.onTypePaymentChanged,
    required this.onRestart,
    required this.onConfirm,
  });

  @override
  ConsumerState<SaleDetailModal> createState() => _SaleDetailModalState();
}

class _SaleDetailModalState extends ConsumerState<SaleDetailModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _modalMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late ClientModel? _selectedClient;
  late TypePaymentModel? _selectedTypePayment;
  final FocusNode _paymentFocusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.initialClient;
    _selectedTypePayment = widget.initialTypePayment;
  }

  @override
  void dispose() {
    _paymentFocusNode.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _modalMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- 1. HANDLE BAR ---
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // --- 2. TÍTULO ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "Detalles de la Venta",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // --- A. SECCIÓN CLIENTE ---
                          Text(
                            "Cliente",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          _buildClientSelector(),

                          // Tarjeta de Cliente Seleccionado
                          if (_selectedClient != null)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Seleccionado: ${_selectedClient!.name}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          // --- TIPO DE PAGO ---
                          _buildPaymentSelector(),
                          const SizedBox(height: 20),
                          const Divider(),

                          // --- C. LISTA DE PRODUCTOS ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Productos",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${widget.items.length} Items",
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (widget.items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Center(
                                child: Text(
                                  "El carrito está vacío",
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...widget.items.asMap().entries.map((entry) {
                              final item = entry.value;
                              return SaleItemCard(
                                item: item,
                                onDecrement: () {
                                  setState(() {
                                    if (item.amount > 1) {
                                      item.amount--;
                                    } else {
                                      widget.items.removeAt(entry.key);
                                    }
                                  });
                                },
                                onIncrement: () {
                                  setState(() {
                                    item.amount++;
                                  });
                                },
                                onTapAmount: () {
                                  _mostrarDialogoEditarCantidad(
                                    context,
                                    item,
                                    (val) => setState(() {
                                      item.amount = val;
                                    }),
                                  );
                                },
                              );
                            }).toList(),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildClientSelector() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Autocomplete<ClientModel>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<ClientModel>.empty();
              }
              final currentClients = ref.read(clientProvider).value ?? [];
              final term = textEditingValue.text.toLowerCase();
              return currentClients.where((ClientModel option) {
                return option.name.toLowerCase().contains(term) ||
                    option.clientCi.toLowerCase().contains(term);
              });
            },
            displayStringForOption: (ClientModel option) =>
                "CI:${option.clientCi} ${option.name} ",
            onSelected: (ClientModel selection) {
              setState(() {
                _selectedClient = selection;
              });
              widget.onClientChanged(selection);
              _paymentFocusNode.requestFocus();
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
                  return SearchTextFieldApp(
                    autofocus: true,
                    controller: textEditingController,
                    focusNode: focusNode,
                    labelText: 'Buscar Cliente',
                    prefixIcon: Icons.search,
                    onSubmitted: (String val) {
                      onFieldSubmitted();
                    },
                    validator: (value) {
                      if (_selectedClient == null) {
                        return 'Seleccione un cliente';
                      }
                      return null;
                    },
                  );
                },
          ),
        ),
        const SizedBox(width: 10),
        ButtonApp(
          text: "Nuevo",
          onPressed: () async {
            final bool? clientWasAdded = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Theme.of(context).primaryColor,
              builder: (ctx) => AddClientForm(),
            );

            if (clientWasAdded == true) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cliente agregado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );

              await ref.read(clientProvider.notifier).refresh();

              if (!mounted) return;

              setState(() {
                final newClients = ref.read(clientProvider).value ?? [];
                if (newClients.isNotEmpty) {
                  _selectedClient = newClients.last;
                  widget.onClientChanged(_selectedClient);
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSelector() {
    final typePaymentsState = ref.watch(typePaymentProvider);
    return typePaymentsState.when(
      loading: () => const CategoryLoadingSkeleton(),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (typePayments) {
        return DropDownApp(
          items: typePayments,
          initialValue: _selectedTypePayment,
          onChanged: (newValue) {
            setState(() {
              _selectedTypePayment = newValue;
            });
            widget.onTypePaymentChanged(newValue);
          },
          itemToString: (tp) => tp.name,
          labelText: 'Seleccionar Tipo de Pago',
          prefixIcon: Icons.payment,
          focusNode: _paymentFocusNode,
          validator: (value) {
            if (value == null) {
              return 'Seleccione un tipo de pago';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total
            Builder(
              builder: (ctx) {
                double totalUsd = widget.items.fold(
                  0,
                  (prev, el) => prev + (el.amount * el.unitPriceUsd),
                );
                double totalBs = widget.items.fold(
                  0,
                  (prev, el) => prev + (el.amount * el.unitPriceBs),
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total a Pagar:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "\$${totalUsd.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          "Bs. ${totalBs.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 15),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ButtonApp(
                      text: "CANCELAR VENTA",
                      type: ButtonType.secondary,
                      icon: Icons.restart_alt_rounded,
                      onPressed: _restartSale,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ButtonApp(
                      text: "CONFIRMAR VENTA",
                      type: ButtonType.primary,
                      fullWidth: true,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        if (widget.items.isEmpty) {
                          _modalMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ El carrito está vacío.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Confirmar Venta"),
                            content: const Text(
                              "¿Estás seguro de que deseas procesar esta venta?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text("NO"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  // Reproducir sonido
                                  _audioPlayer.play(
                                    AssetSource('sounds/cash_register.mp3'),
                                  );
                                  widget.onConfirm(context, _modalMessengerKey);
                                },
                                child: const Text("SI"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restartSale() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Reiniciar Venta"),
        content: const Text(
          "¿Estás seguro de que deseas limpiar todo el carrito y el cliente seleccionado?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              widget.onRestart();
            },
            child: const Text("SÍ"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarCantidad(
    BuildContext context,
    SaleItemModel item,
    Function(int) onConfirm,
  ) {
    final TextEditingController cantidadController = TextEditingController();
    cantidadController.text = item.amount.toString();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Modificar Cantidad"),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Nueva cantidad",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text("Aceptar"),
              onPressed: () {
                final int? nuevaCantidad = int.tryParse(
                  cantidadController.text,
                );
                if (nuevaCantidad != null && nuevaCantidad > 0) {
                  onConfirm(nuevaCantidad);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
