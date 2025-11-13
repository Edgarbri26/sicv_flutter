import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/type_payment_model.dart';
import 'package:sicv_flutter/services/type_payment_service.dart';
// Importa el servicio

class TypePaymentScreen extends StatefulWidget {
  const TypePaymentScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Tipos de Pago'),
        actions: [
          // Botón para refrescar la lista manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentTypes,
          ),
        ],
      ),
      body: FutureBuilder<List<TypePaymentModel>>(
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
              return ListTile(
                title: Text(type.name),
                subtitle: Text('ID: ${type.typePaymentId}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón EDITAR (Update)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _showFormDialog(context, type: type),
                    ),
                    // Botón BORRAR (Delete)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirmation(context, type),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // Botón para CREAR
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Tipo de Pago',
        onPressed: () => _showFormDialog(context),
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
                    _performUpdate(context, type.typePaymentId!, newName);
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

  /// Muestra confirmación antes de BORRAR.
  void _showDeleteConfirmation(BuildContext context, TypePaymentModel type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Borrado'),
        content: Text('¿Estás seguro de que quieres eliminar "${type.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              _performDelete(context, type.typePaymentId!);
            },
          ),
        ],
      ),
    );
  }

  // --- Métodos Helper para ejecutar acciones del servicio y refrescar la UI ---

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

  Future<void> _performDelete(BuildContext context, int id) async {
    try {
      await _service.deletePaymentType(id);
      _showFeedback(context, 'Eliminado exitosamente.');
      _loadPaymentTypes(); // Recargar la lista
    } catch (e) {
      _showFeedback(context, 'Error al eliminar: $e', isError: true);
    }
  }
}
