import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/providers/providers_provider.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/models/provider_model.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class ProviderScreem extends ConsumerStatefulWidget {
  const ProviderScreem({super.key});

  @override
  ConsumerState<ProviderScreem> createState() => _ProviderScreemState();
}

class _ProviderScreemState extends ConsumerState<ProviderScreem> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarProviders(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  // --- FUNCIÓN DE AGREGAR ---
  void _agregarProvider() {
    final nameController = TextEditingController();
    final locatedController = TextEditingController();

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
                final located = locatedController.text.trim();

                if (name.isEmpty) return;

                try {
                  await ref
                      .read(providersProvider.notifier)
                      .createProvider(name: name, located: located);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "$name" creado'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
    final locatedController = TextEditingController(text: provider.located);

    showDialog<void>(
      context: context,
      builder: (context) {
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
                final located = locatedController.text.trim();

                if (name.isEmpty) return;

                try {
                  await ref
                      .read(providersProvider.notifier)
                      .updateProvider(
                        id: provider.id,
                        newName: name,
                        located: located,
                      );

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "$name" actualizado'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
                  await ref
                      .read(providersProvider.notifier)
                      .deactivateProvider(id: provider.id);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "${provider.name}" desactivado'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
                  await ref
                      .read(providersProvider.notifier)
                      .activateProvider(id: provider.id);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Proveedor "${provider.name}" activado'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
    final providersAsyncValue = ref.watch(providersProvider);

    return Scaffold(
      appBar: AppBarApp(title: 'Proveedores', iconColor: AppColors.textPrimary),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: providersAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (providers) {
              if (providers.isEmpty) {
                return const Center(
                  child: Text('No se encontraron proveedores.'),
                );
              }

              final filteredProviders = providers.where((provider) {
                return provider.name.toLowerCase().contains(_searchQuery) ||
                    provider.located.toLowerCase().contains(_searchQuery);
              }).toList();

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
                      itemCount: filteredProviders.length,
                      itemBuilder: (context, index) {
                        final provider = filteredProviders[index];

                        return ListTile(
                          title: Text(provider.name),
                          leading: const Icon(
                            Icons.store_mall_directory_outlined,
                          ),
                          subtitle: provider.located.isNotEmpty
                              ? Text(provider.located)
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
