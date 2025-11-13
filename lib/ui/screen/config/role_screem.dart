// screens/role_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/providers/role_provider.dart';
import 'package:sicv_flutter/ui/screen/config/role_edit_view.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:material_symbols_icons/symbols.dart';

// Usamos ConsumerWidget para escuchar providers de Riverpod
class RoleListView extends ConsumerWidget {
  const RoleListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado del FutureProvider
    final asyncRoles = ref.watch(allRolesProvider);

    String iconName = 'shield_outlined';

    return Scaffold(
      appBar: AppBarApp(
        title: 'Gestión de Roles',
        actions: [
          // Botón para refrescar la lista manualmente
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacingM),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: () {
                // Invalida el provider, forzando un "refetch"
                ref.invalidate(allRolesProvider);
              },
            ),
          ),
        ],
      ),
      body: asyncRoles.when(
        // Estado 1: Cargando
        loading: () => const Center(child: CircularProgressIndicator()),

        // Estado 2: Error
        error: (err, stack) =>
            Center(child: Text('Error al cargar roles: $err')),

        // Estado 3: Datos recibidos
        data: (roles) {
          if (roles.isEmpty) {
            return const Center(child: Text('No hay roles creados.'));
          }

          return ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return ListTile(
                title: Text(role.name),
                subtitle: Text('${role.permissions.length} permisos'),
                leading: const Icon(Symbols.person_shield_rounded),
                trailing: const Icon(Icons.chevron_right),
                onLongPress: () {},
                onTap: () {
                  // Navegar a la pantalla de edición (Modo "Actualizar")
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoleEditView(role: role),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Crear Rol',
        onPressed: () {
          // Navegar a la pantalla de edición (Modo "Crear")
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleEditView(role: null),
            ),
          );
        },
      ),
    );
  }
}
