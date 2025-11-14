import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

// --- IMPORTACIONES AÑADIDAS ---
import 'package:sicv_flutter/models/depot_model.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/services/depot_service.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart'; // Reemplaza con tu ruta real
import 'package:sicv_flutter/ui/widgets/atomic/checkbox_field_app.dart'; // Reemplaza con tu ruta real

class DepotScreem extends StatefulWidget {
  const DepotScreem({super.key});

  @override
  _DepotScreemState createState() => _DepotScreemState();
}

class _DepotScreemState extends State<DepotScreem> {
  // --- ESTADO MANEJADO POR LA API ---
  final DepotService _depotService = DepotService();
  late Future<List<DepotModel>> _depotsFuture;
  List<DepotModel> _depotsOriginales = [];
  List<DepotModel> _depotsFiltrados = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _depotsFuture = _fetchDepots();
  }

  Future<List<DepotModel>> _fetchDepots() async {
    try {
      final depots = await _depotService.getDepots();
      setState(() {
        _depotsOriginales = depots;
        _depotsFiltrados = depots;
        _filtrarDepots(_searchController.text); // Aplica filtro existente
      });
      return depots;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar almacenes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('Error al cargar almacenes: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarDepots(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _depotsFiltrados = _depotsOriginales
          .where(
            (depot) =>
                depot.name.toLowerCase().contains(lowerCaseQuery) ||
                depot.location.toLowerCase().contains(lowerCaseQuery),
          )
          .toList();
    });
  }

  // --- FUNCIÓN DE AGREGAR (Sin cambios) ---
  void _agregarDepot() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Almacén'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldApp(controller: nameController, labelText: 'Nombre'),
              const SizedBox(height: 10),
              TextFieldApp(
                controller: locationController,
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
                final location = locationController.text.trim();

                if (name.isEmpty) return;

                try {
                  final newDepot = await _depotService.createDepot(
                    name: name,
                    location: location,
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Almacén "${newDepot.name}" creado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _depotsFuture = _fetchDepots();
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

  // --- FUNCIÓN DE EDITAR (Sin cambios) ---
  void _editarDepot(DepotModel depot) {
    final nameController = TextEditingController(text: depot.name);
    final locationController = TextEditingController(text: depot.location);
    bool currentStatus = depot.status;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Editar ${depot.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldApp(controller: nameController, labelText: 'Nombre'),
                  const SizedBox(height: 10),
                  TextFieldApp(
                    controller: locationController,
                    labelText: 'Ubicación',
                  ),
                  const SizedBox(height: 10),
                  CheckboxFieldApp(
                    title: "Activo",
                    value: currentStatus,
                    onChanged: (newValue) {
                      setDialogState(() {
                        currentStatus = newValue ?? false;
                      });
                    },
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
                    final location = locationController.text.trim();

                    if (name.isEmpty) return;

                    try {
                      await _depotService.updateDepot(
                        depot.depotId,
                        name: name,
                        location: location,
                        status: currentStatus,
                      );

                      if (!mounted) return;
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Almacén "$name" actualizado'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      setState(() {
                        _depotsFuture = _fetchDepots();
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
      },
    );
  }

  // --- 🔥 NUEVA FUNCIÓN DE ELIMINAR 🔥 ---
  void _showDeactivateConfirmDialog(DepotModel depot) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar Almacén'),
          content: Text(
            '¿Estás seguro de que deseas desactivar "${depot.name}"?',
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
                  await _depotService.deactivateDepot(depot.depotId);

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Cierra el diálogo

                  // 2. Muestra confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Almacén "${depot.name}" desactivado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // 3. Recarga la lista
                  setState(() {
                    _depotsFuture = _fetchDepots();
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

  void _showActivateConfirmDialog(DepotModel depot) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar Almacén'),
          content: Text(
            '¿Estás seguro de que deseas Activar "${depot.name}"? Esta acción puede afectar a los productos asociados.',
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
                  await _depotService.activateDepot(depot.depotId);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Almacén "${depot.name}" activado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _depotsFuture = _fetchDepots();
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
      appBar: AppBarApp(title: 'Almacenes', iconColor: AppColors.textPrimary),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<List<DepotModel>>(
            future: _depotsFuture,
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
                  child: Text('No se encontraron almacenes.'),
                );
              }

              // --- USAMOS _depotsFiltrados QUE YA TIENE LOS DATOS ---
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchTextFieldApp(
                      controller: _searchController,
                      labelText: 'Buscar Almacén',
                      hintText: 'Ej. Almacén Central',
                      onChanged: _filtrarDepots,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _depotsFiltrados.length,
                      itemBuilder: (context, index) {
                        final depot = _depotsFiltrados[index];

                        // --- 🔥 CHIP DE ESTADO AÑADIDO 🔥 ---
                        final statusChip = Chip(
                          label: Text(
                            depot.status ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              color: depot.status
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: depot.status
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          side: BorderSide.none,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );

                        // --- 🔥 LISTTILE ACTUALIZADO 🔥 ---
                        return ListTile(
                          title: Row(
                            children: [
                              Text(depot.name),
                              const SizedBox(width: 8),
                              statusChip, // Mostramos el chip
                            ],
                          ),
                          leading: const Icon(Icons.warehouse_outlined),
                          subtitle: depot.location.isNotEmpty
                              ? Text(depot.location)
                              : null,
                          // --- TRAILING ACTUALIZADO CON BOTÓN DE ELIMINAR ---
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Editar',
                                onPressed: () => _editarDepot(depot),
                              ),
                              depot.status
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.block,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Desactivar',
                                      onPressed: () =>
                                          _showDeactivateConfirmDialog(depot),
                                    )
                                  : IconButton(
                                      onPressed: () =>
                                          _showActivateConfirmDialog(depot),
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
        onPressed: _agregarDepot,
        tooltip: 'Agregar Almacén',
        child: const Icon(Icons.add),
      ),
    );
  }
}
