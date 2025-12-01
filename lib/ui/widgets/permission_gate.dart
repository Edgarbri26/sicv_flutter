import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importa el archivo donde definimos la variable 'userPermissionsProvider'
import 'package:sicv_flutter/providers/user_permissions_provider.dart';

class PermissionGate extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? alternative;

  const PermissionGate({
    Key? key,
    required this.permission,
    required this.child,
    this.alternative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. CORRECCIÓN AQUÍ:
    // Usamos la variable (minúscula), NO la clase (Mayúscula)
    final userPermissions = ref.watch(userPermissionsProvider);

    // 2. Verificamos si tiene el permiso
    final hasAccess = userPermissions.contains(permission);

    // 3. Renderizado condicional
    if (hasAccess) {
      return child;
    } else {
      return alternative ?? const SizedBox.shrink();
    }
  }
}
