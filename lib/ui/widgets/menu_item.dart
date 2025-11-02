import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

class MenuItem extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String? title;
  final VoidCallback onTap;
  final String? route;
  final String? currentPageRoute; //creo que es inecesario
  final bool isSelected;
  final bool isExpanded;
  const MenuItem({
    super.key,
    required this.context,
    required this.icon,
    this.title,
    required this.onTap,
    this.route,
    this.currentPageRoute,
    required this.isSelected,
    required this.isExpanded,
  });
  // final bool isMobile = MediaQuery.of(context).size.width < 650.0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      hoverColor: AppColors.primary,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: 30,
      ),

      title: isExpanded
          ? title?.isNotEmpty ?? false
                ? Text(
                    title!,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16, // Tamaño de fuente más estándar para menú
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Previene desbordamiento al expandir
                    maxLines: 1,
                  )
                : null
          : null,

      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      onTap: () {
        // --- LÓGICA CLAVE: Cierra el Drawer solo si es móvil ---
        // if (isMobile) {
        //   // Si estamos en móvil, cerramos el drawer antes de navegar
        //   // Comprobamos si el drawer está abierto antes de hacer pop
        //   if (Scaffold.of(context).isDrawerOpen) {
        //     Navigator.pop(context);
        //   }
        // }
        // Pequeña espera para una transición más suave (opcional)
        if (isExpanded) {
          Future.delayed(const Duration(milliseconds: 150), onTap);
        } else {
          onTap();
        }
      },
    );
  }
}
