import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

// --- IMPORTACIONES AÑADIDAS ---
import 'package:sicv_flutter/models/provider_model.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/services/provider_service.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart'; // Reemplaza con tu ruta real
// CheckboxFieldApp se elimina porque el modelo no tiene 'status'
// import 'package:sicv_flutter/ui/widgets/atomic/checkbox_field_app.dart';

class ProviderScreem extends StatefulWidget {
  const ProviderScreem({super.key});

  @override
  _ProviderScreemState createState() => _ProviderScreemState();
}

class _ProviderScreemState extends State<ProviderScreem> {
  // --- ESTADO MANEJADO POR LA API ---
  final ProviderService _providerService = ProviderService();
  late Future<List<ProviderModel>> _providersFuture;
  List<ProviderModel> _providersOriginales = [];
  List<ProviderModel> _providersFiltrados = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _providersFuture = _fetchProviders();
  }

  Future<List<ProviderModel>> _fetchProviders() async {
    try {
      final providers = await _providerService.getProviders();
      setState(() {
        _providersOriginales = providers;
        _providersFiltrados = providers;
        _filtrarProviders(_searchController.text); // Aplica filtro existente
      });
      return providers;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar proveedores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('Error al cargar proveedores: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarProviders(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _providersFiltrados = _providersOriginales
          .where(
            (provider) =>
                provider.name.toLowerCase().contains(lowerCaseQuery) ||
                provider.located.toLowerCase().contains(lowerCaseQuery),
          )
          .toList();
    });
  }

  // --- FUNCIÓN DE AGREGAR ---
  void _agregarProvider() {
    final nameController = TextEditingController();
    final locatedController = TextEditingController(); // 'located'

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Proveedor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldApp(controller: nameController, labelText: 'Nombre'),
              const SizedBox(height: 10),
              TextFieldApp(
                controller: locatedController,
                labelText: 'Ubicación',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final located = locatedController.text.trim(); // 'located'

                if (name.isEmpty) return;

                try {
                  final newProvider = await _providerService.createProvider(
                    name: name,
                    located: located, // 'located'
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "${newProvider.name}" creado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _providersFuture = _fetchProviders();
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // --- FUNCIÓN DE EDITAR ---
  void _editarProvider(ProviderModel provider) {
    final nameController = TextEditingController(text: provider.name);
    final locatedController = TextEditingController(
      text: provider.located,
    ); // 'located'
    // Se elimina 'currentStatus' porque el modelo no lo tiene

    showDialog<void>(
      context: context,
      builder: (context) {
        // Ya no se necesita StatefulBuilder si no hay Checkbox
        return AlertDialog(
          title: Text('Editar ${provider.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldApp(controller: nameController, labelText: 'Nombre'),
              const SizedBox(height: 10),
              TextFieldApp(
                controller: locatedController,
                labelText: 'Ubicación',
              ),
              // --- SE ELIMINÓ EL CHECKBOX DE ESTADO ---
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final located = locatedController.text.trim(); // 'located'

                if (name.isEmpty) return;

                try {
                  await _providerService.updateProvider(
                    provider.providerId,
                    name: name,
                    located: located, // 'located'
                    // Se eliminó 'status'
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "$name" actualizado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _providersFuture = _fetchProviders();
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // --- FUNCIÓN DE ELIMINAR ---
  /* void _showDeleteConfirmDialog(ProviderModel provider) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Proveedor'),
          content: Text(
              '¿Estás seguro de que deseas eliminar "${provider.name}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await _providerService.deleteProvider(provider.providerId);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "${provider.name}" eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _providersFuture = _fetchProviders();
                  });
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
*/
  void _showDeactivateConfirmDialog(ProviderModel provider) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar Proveedor'),
          content: Text(
            '¿Estás seguro de que deseas desactivar "${provider.name}"?',
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
                  await _providerService.deactivateProvider(
                    provider.providerId,
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Cierra el diálogo

                  // 2. Muestra confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "${provider.name}" desactivado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // 3. Recarga la lista
                  setState(() {
                    _providersFuture = _fetchProviders();
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

  void _showActivateConfirmDialog(ProviderModel provider) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar Proveedor'),
          content: Text(
            '¿Estás seguro de que deseas Activar "${provider.name}"? Esta acción puede afectar a los productos asociados.',
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
                  await _providerService.activateProvider(provider.providerId);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "${provider.name}" activado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _providersFuture = _fetchProviders();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(title: 'Proveedores', iconColor: AppColors.textPrimary),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<List<ProviderModel>>(
            future: _providersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No se encontraron proveedores.'),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchTextFieldApp(
                      controller: _searchController,
                      labelText: 'Buscar Proveedor',
                      hintText: 'Ej. Tecno Suministros',
                      onChanged: _filtrarProviders,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _providersFiltrados.length,
                      itemBuilder: (context, index) {
                        final provider = _providersFiltrados[index];

                        // --- LISTTILE ACTUALIZADO (Sin Chip de Estado) ---
                        return ListTile(
                          title: Text(provider.name), // Título simple
                          leading: const Icon(
                            Icons.store_mall_directory_outlined,
                          ), // Icono cambiado
                          subtitle: provider.located.isNotEmpty
                              ? Text(provider.located) // 'located'
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Editar',
                                onPressed: () => _editarProvider(provider),
                              ),
                              provider.status
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.block,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Desactivar',
                                      onPressed: () =>
                                          _showDeactivateConfirmDialog(
                                            provider,
                                          ),
                                    )
                                  : IconButton(
                                      onPressed: () =>
                                          _showActivateConfirmDialog(provider),
                                      tooltip: 'Activar',
                                      icon: const Icon(
                                        Icons.restore,
                                        color: Colors.green,
                                      ),
                                    ),
                              /*IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                tooltip: 'Eliminar',
                                onPressed: () =>
                                    _showDeleteConfirmDialog(provider),
                              ),*/
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarProvider,
        tooltip: 'Agregar Proveedor',
        child: const Icon(Icons.add),
      ),
    );
  }
}
