import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/core/theme/app_sizes.dart';
import 'package:sicv_flutter/providers/role_provider.dart';
// Asegúrate de importar el archivo donde definiste los nuevos providers
import 'package:sicv_flutter/ui/screen/config/role_edit_view.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:material_symbols_icons/symbols.dart';

class RoleListView extends ConsumerWidget {
  const RoleListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos el estado del StateNotifier
    final asyncRoles = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBarApp(
        title: 'Gestión de Roles',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacingM),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: () {
                // 2. Usamos el método refresh() del notifier
                ref.read(rolesProvider.notifier).refresh();
              },
            ),
          ),
        ],
      ),
      body: asyncRoles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
                onTap: () {
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
        tooltip: 'Crear role',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoleEditView(role: null),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}