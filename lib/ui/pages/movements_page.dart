import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/core/utils/date_utils.dart';
import 'package:sicv_flutter/models/movement/movement_type.dart';
import 'package:sicv_flutter/providers/current_user_permissions_provider.dart';
import 'package:sicv_flutter/providers/movement_provider.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/my_side_bar.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/modals/add_movement_modal.dart';
import 'package:sicv_flutter/ui/widgets/wide_layuout.dart';
import 'package:sidebarx/sidebarx.dart';

import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';

// CAMBIO 1: Convertimos a ConsumerStatefulWidget para manejar el Controller
class MovementsPage extends ConsumerStatefulWidget {
  final SidebarXController controller;
  const MovementsPage({super.key, required this.controller});

  @override
  ConsumerState<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends ConsumerState<MovementsPage> {
  // CAMBIO 2: Instanciamos el controlador para el buscador
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose(); // Limpieza de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(filteredMovementsProvider);
    final isLoading = ref.watch(movementsProvider).isLoading;

    final userPermissions = ref.watch(currentUserPermissionsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AppSizes.breakpoint;

        final hasAccessCreateMovements = userPermissions.can(
          AppPermissions.createMovements,
        );
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: !isWide ? AppBarApp(title: 'Movimientos') : null,
          drawer: isWide ? null : MySideBar(controller: widget.controller),

          floatingActionButton: hasAccessCreateMovements
              ? SizedBox(
                  width: 220,
                  height: 60,
                  child: ButtonApp(
                    text: "Agregar Movimiento",
                    icon: Symbols.add,
                    onPressed: () => AddMovementModal.show(context),
                  ),
                )
              : null,

          body: isWide
              ? WideLayout(
                  controller: widget.controller,
                  appbartitle: 'Movimientos de Inventario',
                  child: _buildBody(context, ref, movements, isLoading, true),
                )
              : _buildBody(context, ref, movements, isLoading, false),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> movements,
    bool isLoading,
    bool isWide,
  ) {
    return Column(
      children: [
        // --- FILTROS ---
        // --- FILTROS ---
        _buildFilters(ref, isWide),

        // --- CONTENIDO ---
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : movements.isEmpty
              ? const Center(child: Text("No se encontraron movimientos."))
              : isWide
              ? _buildDataTable(movements)
              : _buildListView(movements),
        ),
      ],
    );
  }

  Widget _buildFilters(WidgetRef ref, bool isWide) {
    if (!isWide) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFieldApp(
              controller: _searchController,
              labelText: 'Buscar producto...',
              prefixIcon: Icons.search,
              onChanged: (val) =>
                  ref.read(movementSearchProvider.notifier).state = val,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MovementType>(
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    value: ref.watch(movementTypeFilterProvider),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Todos")),
                      ...MovementType.values.map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.displayName),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        ref.read(movementTypeFilterProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    value: ref.watch(movementDateRangeProvider),
                    items:
                        ['Hoy', 'Ayer', 'Últimos 7 días', 'Este mes', 'Todos']
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                    onChanged: (v) =>
                        ref.read(movementDateRangeProvider.notifier).state = v!,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Buscador
          SizedBox(
            width: 300,
            child: TextFieldApp(
              controller: _searchController,
              labelText: 'Buscar producto...',
              prefixIcon: Icons.search,
              onChanged: (val) =>
                  ref.read(movementSearchProvider.notifier).state = val,
            ),
          ),
          // Filtro Tipo
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<MovementType>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              value: ref.watch(movementTypeFilterProvider),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text("Todos", overflow: TextOverflow.ellipsis),
                ),
                ...MovementType.values.map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.displayName, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (v) =>
                  ref.read(movementTypeFilterProvider.notifier).state = v,
            ),
          ),
          // Filtro Fecha
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              value: ref.watch(movementDateRangeProvider),
              items: ['Hoy', 'Ayer', 'Últimos 7 días', 'Este mes', 'Todos']
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(d, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  ref.read(movementDateRangeProvider.notifier).state = v!,
            ),
          ),
        ],
      ),
    );
  }

  // Vista Tabla (Escritorio)
  Widget _buildDataTable(List<dynamic> movements) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).dividerColor,
          ),
          columns: const [
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Producto')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Cant.')),
            DataColumn(label: Text('Deposito')),
            DataColumn(label: Text('Usuario')),
          ],
          rows: movements.map((m) {
            final isPos = m.amount >= 0;
            return DataRow(
              cells: [
                DataCell(Text(DateFormatter.format(m.movedAt))),
                DataCell(Text(m.productName)),
                DataCell(Text(m.type)),
                DataCell(
                  Text(
                    m.amount.toStringAsFixed(0),
                    style: TextStyle(
                      color: isPos ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(m.depotName)),
                DataCell(Text(m.userName)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Vista Lista (Móvil)
  Widget _buildListView(List<dynamic> movements) {
    return ListView.separated(
      itemCount: movements.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final m = movements[index];
        final isPos = m.amount >= 0;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isPos ? Colors.green[100] : Colors.red[100],
            child: Icon(
              isPos ? Icons.arrow_downward : Icons.arrow_upward,
              color: isPos ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          title: Text(
            m.productName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${DateFormatter.format(m.movedAt)} • ${m.userName}\n${m.observation}',
          ),
          isThreeLine: true,
          trailing: Text(
            "${isPos ? '+' : ''}${m.amount.toStringAsFixed(0)}",
            style: TextStyle(
              color: isPos ? Colors.green : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
