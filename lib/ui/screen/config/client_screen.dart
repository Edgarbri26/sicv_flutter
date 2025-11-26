import 'package:flutter/material.dart';

// --- Asegúrate de que estas rutas de importación sean correctas ---
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/add_client_form.dart';
import 'package:sicv_flutter/ui/widgets/edit_client_form.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';

// --- IMPORTACIONES DEL SERVICIO Y MODELO ---
import 'package:sicv_flutter/services/client_service.dart';
import 'package:sicv_flutter/models/client_model.dart'; // Usa ClientModel

class ClientManagementPage extends StatefulWidget {
  const ClientManagementPage({super.key});

  @override
  ClientManagementPageState createState() => ClientManagementPageState();
}

class ClientManagementPageState extends State<ClientManagementPage> {
  final ClientService _clientService = ClientService();
  late Future<List<ClientModel>> _clientsFuture; // Usa ClientModel

  List<ClientModel> _clientsOriginales = []; // Usa ClientModel
  List<ClientModel> _filteredClients = []; // Usa ClientModel

  final List<String> _statusDisponibles = ['Todos', 'Activo', 'Inactivo'];
  String _searchQuery = '';
  String _selectedStatus = 'Todos';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _fetchClients();
  }

  Future<List<ClientModel>> _fetchClients() async {
    try {
      final clients = await _clientService.getAll();
      setState(() {
        _clientsOriginales = clients;
        _filterUsers(runSetState: false);
      });
      return clients;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar clientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw Exception('Error al cargar clientes: $e');
    }
  }

  void _filterUsers({bool runSetState = true}) {
    List<ClientModel> tempClients = _clientsOriginales; // Usa ClientModel

    // Filtrar por Estado
    if (_selectedStatus != 'Todos') {
      final bool targetStatus = _selectedStatus == 'Activo';
      tempClients = tempClients
          .where((client) => client.status == targetStatus)
          .toList();
    }

    // Filtrar por Búsqueda (Nombre o Teléfono)
    if (_searchQuery.isNotEmpty) {
      tempClients = tempClients
          .where(
            (client) =>
                client.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                client.phone.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Aplicar Ordenamiento
    if (_sortColumnIndex != null) {
      tempClients.sort((a, b) {
        dynamic aValue;
        dynamic bValue;
        switch (_sortColumnIndex) {
          case 0: // Cliente (Nombre)
            aValue = a.name.toLowerCase();
            bValue = b.name.toLowerCase();
            break;
          case 1: // Teléfono
            aValue = a.phone;
            bValue = b.phone;
            break;
          case 2: // Estado
            aValue = a.status;
            bValue = b.status;
            break;
          default:
            return 0;
        }
        final comparison = aValue.compareTo(bValue);
        return _sortAscending ? comparison : -comparison;
      });
    }

    if (runSetState) {
      setState(() {
        _filteredClients = tempClients;
      });
    } else {
      _filteredClients = tempClients;
    }
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filterUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarApp(
        title: 'Gestionar Clientes',
        iconColor: Colors.black,
        toolbarHeight: 64.0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25.0),
            child: _buildFiltersAndSearch(),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 3.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: FutureBuilder<List<ClientModel>>(
                  future: _clientsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (!snapshot.hasData || _filteredClients.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron clientes.'),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: _buildDataTable(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewClient,
        tooltip: 'Agregar Cliente',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          if (isWideScreen) {
            return Row(
              children: [
                Expanded(flex: 2, child: _buildSearchField()),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildStatusFilter()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 16),
                _buildStatusFilter(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return SearchTextFieldApp(
      labelText: 'Buscar por Nombre o Teléfono', // Actualizado
      hintText: 'Escribe el nombre o teléfono...', // Actualizado
      prefixIcon: Icons.search,
      onChanged: (value) {
        _searchQuery = value;
        _filterUsers();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropDownApp<String>(
      labelText: 'Filtrar por Estado',
      prefixIcon: Icons.filter_list,
      initialValue: _selectedStatus,
      items: _statusDisponibles,
      itemToString: (status) => status,
      onChanged: (newValue) {
        if (newValue == null) return;
        setState(() {
          _selectedStatus = newValue;
        });
        _filterUsers();
      },
    );
  }

  void _showDeactivateConfirmDialog(ClientModel client) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar Cliente'),
          content: Text(
            '¿Estás seguro de que deseas desactivar "${client.name}"?',
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
                  await _clientService.deactivateClient(client.clientCi);

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Cierra el diálogo

                  // 2. Muestra confirmación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cliente "${client.name}" desactivado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // 3. Recarga la lista
                  setState(() {
                    _clientsFuture = _fetchClients();
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

  void _showActivateConfirmDialog(ClientModel client) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Activar Cliente'),
          content: Text(
            '¿Estás seguro de que deseas Activar "${client.name}"? Esta acción puede afectar a los productos asociados.',
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
                  await _clientService.activateClient(client.clientCi);

                  if (!mounted) return;
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cliente "${client.name}" activado'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _clientsFuture = _fetchClients();
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

  Widget _buildDataTable() {
    return DataTable(
      horizontalMargin: 12.0,
      columnSpacing: 20.0,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      dataRowColor: WidgetStateProperty.all(AppColors.background),
      headingRowColor: WidgetStateProperty.all(AppColors.border),
      headingRowHeight: 48.0,
      columns: [
        DataColumn(
          label: const Text(
            'Cliente',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Teléfono', // Actualizado
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Dirección', // Actualizado
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        DataColumn(
          label: const Text(
            'Estado',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onSort: _onSort,
        ),
        const DataColumn(
          label: Text(
            'Acciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _filteredClients.map((client) {
        return DataRow(
          cells: [
            // CELDA 1: CLIENTE
            DataCell(
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // CELDA 2: TELÉFONO
            DataCell(
              Text(
                client.phone,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataCell(
              Text(
                client.address,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // CELDA 3: ESTADO
            DataCell(
              Chip(
                label: Text(client.status ? 'Activo' : 'Inactivo'),
                backgroundColor: client.status
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: client.status
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                side: BorderSide.none,
              ),
            ),
            // CELDA 4: ACCIONES
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Editar Cliente',
                    onPressed: () => _showEditClientDialog(context, client),
                  ),
                  client.status
                      ? IconButton(
                          icon: const Icon(Icons.block, color: Colors.red),
                          tooltip: 'Desactivar',
                          onPressed: () => _showDeactivateConfirmDialog(client),
                        )
                      : IconButton(
                          onPressed: () => _showActivateConfirmDialog(client),
                          tooltip: 'Activar',
                          icon: const Icon(Icons.restore, color: Colors.green),
                        ),
                  /*IconButton(
                    icon:
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Eliminar Cliente',
                    onPressed: () => _showDeleteConfirmDialog(context, client),
                  ),*/
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /*void _showDeleteConfirmDialog(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Cliente'),
          content: Text(
            '¿Estás seguro de que deseas eliminar a ${client.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _clientService.deleteClient(client.clientCi);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cliente ${client.name} eliminado'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  setState(() {
                    _clientsFuture = _fetchClients();
                  });
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }*/

  void _showEditClientDialog(BuildContext context, ClientModel client) async {
    final bool? clientWasUpdated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return EditClientForm(client: client, clientService: _clientService);
      },
    );

    if (clientWasUpdated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente actualizado correctamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {
        _clientsFuture = _fetchClients();
      });
    }
  }

  void addNewClient() async {
    final bool? clientWasAdded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return AddClientForm(clientService: _clientService);
      },
    );

    if (clientWasAdded == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente agregado correctamente'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _clientsFuture = _fetchClients();
      });
    }
  }
}
