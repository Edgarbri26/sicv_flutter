import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sicv_flutter/config/app_permissions.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
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
          backgroundColor: AppColors.background,
          appBar: !isWide ? AppBarApp(title: 'Movimientos') : null,
          drawer: isWide ? null : MySideBar(controller: widget.controller),

          floatingActionButton: hasAccessCreateMovements
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  icon: Icon(Symbols.add, color: AppColors.secondary),
                  label: Text(
                    "Agregar Movimiento",
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => AddMovementModal.show(context),
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
        _buildFilters(ref),

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

  Widget _buildFilters(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          // Buscador
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: TextFieldApp(
              // CAMBIO 3: Pasamos el controlador requerido
              controller: _searchController,
              labelText: 'Buscar producto...',
              prefixIcon: Icons.search,
              onChanged: (val) =>
                  ref.read(movementSearchProvider.notifier).state = val,
            ),
          ),
          // Filtro Tipo
          DropdownButton<MovementType>(
            hint: const Text("Tipo"),
            value: ref.watch(movementTypeFilterProvider),
            items: [
              const DropdownMenuItem(value: null, child: Text("Todos")),
              ...MovementType.values.map(
                (t) => DropdownMenuItem(value: t, child: Text(t.displayName)),
              ),
            ],
            onChanged: (v) =>
                ref.read(movementTypeFilterProvider.notifier).state = v,
          ),
          // Filtro Fecha
          DropdownButton<String>(
            value: ref.watch(movementDateRangeProvider),
            items: [
              'Hoy',
              'Ayer',
              'Últimos 7 días',
              'Este mes',
              'Todos',
            ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) =>
                ref.read(movementDateRangeProvider.notifier).state = v!,
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
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
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
