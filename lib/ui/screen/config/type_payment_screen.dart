import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';
import 'package:sicv_flutter/services/type_payment_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_card.dart';
// Importa el servicio

class TypePaymentScreen extends StatefulWidget {
  const TypePaymentScreen({super.key});

  @override
  _TypePaymentScreenState createState() => _TypePaymentScreenState();
}

class _TypePaymentScreenState extends State<TypePaymentScreen> {
  // Instancia del servicio. (En una app de escala Google, esto sería inyectado).
  final TypePaymentService _service = TypePaymentService();
  // El Future que alimenta al FutureBuilder.
  late Future<List<TypePaymentModel>> _paymentTypesFuture;

  @override
  void initState() {
    super.initState();
    // Iniciar la carga de datos cuando el widget se construye.
    _loadPaymentTypes();
  }

  /// Método para cargar o recargar los datos
  void _loadPaymentTypes() {
    setState(() {
      _paymentTypesFuture = _service.getPaymentTypes();
    });
  }

  void _showActivateConfirmDialog(TypePaymentModel typePayment) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar Tipo de Pago'),
          content: Text(
            '¿Estás seguro de que deseas Activar "${typePayment.name}"? Esta acción puede afectar a los productos asociados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () async {
                try {
                  await _service.activateTypePayment(typePayment.typePaymentId);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tipo de Pago "${typePayment.name}" activado',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _paymentTypesFuture = _service.getPaymentTypes();
                  });
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al activar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Activar'),
            ),
          ],
        );
      },
    );
  }

  // --- 🔥 NUEVA FUNCIÓN DE ELIMINAR 🔥 ---
  void _showDeactivateConfirmDialog(TypePaymentModel typePayment) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar Tipo de Pago'),
          content: Text(
            '¿Estás seguro de que deseas desactivar "${typePayment.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  // 1. Llama al servicio de desactivación
                  await _service.deactivateTypePayment(
                    typePayment.typePaymentId,
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Cierra el diálogo

                  // 2. Muestra confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tipo de Pago "${typePayment.name}" desactivado',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // 3. Recarga la lista
                  setState(() {
                    _paymentTypesFuture = _service.getPaymentTypes();
                  });
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al desactivar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(title: 'Gestión de Tipos de Pago', actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPaymentTypes,
            ),
        ),
        ],
      ),
      body: Center(
        
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<List<TypePaymentModel>>(
            future: _paymentTypesFuture,
            builder: (context, snapshot) {
              // 1. Estado de Carga
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
          
              // 2. Estado de Error
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error al cargar datos: ${snapshot.error}'),
                  ),
                );
              }
          
              // 3. Estado de Éxito (pero sin datos)
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No se encontraron tipos de pago.'),
                );
              }
          
              // 4. Estado de Éxito (con datos)
              final paymentTypes = snapshot.data!;
          
              return ListView.builder(
                itemCount: paymentTypes.length,
                itemBuilder: (context, index) {
                  final type = paymentTypes[index];
                  return AppCard(
                    title: (type.name),
                    subTitle: 'ID: ${type.typePaymentId}',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón EDITAR (Update)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showFormDialog(context, type: type),
                        ),
                        // Botón BORRAR (Delete)
                        type.status
                            ? IconButton(
                                icon: const Icon(Icons.block, color: Colors.red),
                                tooltip: 'Desactivar',
                                onPressed: () => _showDeactivateConfirmDialog(type),
                              )
                            : IconButton(
                                onPressed: () => _showActivateConfirmDialog(type),
                                tooltip: 'Activar',
                                icon: const Icon(
                                  Icons.restore,
                                  color: Colors.green,
                                ),
                              ),
                      ],
                    ),
                    leading: Icon(
                      Icons.payment,
                      color: AppColors.primary,
                      size: AppSizes.iconL,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      // Botón para CREAR
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo Tipo de Pago',
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Lógica de Operaciones (Diálogos y Acciones) ---

  /// Muestra un diálogo para CREAR o ACTUALIZAR un tipo de pago.
  void _showFormDialog(BuildContext context, {TypePaymentModel? type}) {
    final formKey = GlobalKey<FormState>();
    // Si 'type' no es nulo, estamos editando.
    final isUpdating = type != null;
    final nameController = TextEditingController(text: type?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isUpdating ? 'Editar Tipo de Pago' : 'Nuevo Tipo de Pago',
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  final newName = nameController.text.trim();

                  if (isUpdating) {
                    _performUpdate(context, type.typePaymentId, newName);
                  } else {
                    _performCreate(context, newName);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Muestra un SnackBar genérico para feedback.
  void _showFeedback(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _performCreate(BuildContext context, String name) async {
    try {
      await _service.createPaymentType(name);
      _showFeedback(context, 'Creado exitosamente.');
      _loadPaymentTypes(); // Recargar la lista
    } catch (e) {
      _showFeedback(context, 'Error al crear: $e', isError: true);
    }
  }

  Future<void> _performUpdate(BuildContext context, int id, String name) async {
    try {
      await _service.updatePaymentType(id, name);
      _showFeedback(context, 'Actualizado exitosamente.');
      _loadPaymentTypes(); // Recargar la lista
    } catch (e) {
      _showFeedback(context, 'Error al actualizar: $e', isError: true);
    }
  }
}
