import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/icon_menu.dart';

class SideNavigationMenu extends StatefulWidget {
  // 1. Inmutabilidad: Pasamos el estado necesario a través del constructor.
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<MenuItemData> menuItems;
  final TabController? tabController;
  final PageController? pageController;

  final Color backgroundColor;

  const SideNavigationMenu({
    super.key,
    required this.selectedIndex,
    this.onDestinationSelected,
    required this.menuItems,
    this.backgroundColor =
        Colors.white, // Valor por defecto o AppColors.background
    this.tabController,
    this.pageController,
  });

  @override
  State<SideNavigationMenu> createState() => _SideNavigationMenuState();
}

class _SideNavigationMenuState extends State<SideNavigationMenu> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant SideNavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el índice externo cambia, sincronizamos el estado interno
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
    }
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    if (mounted) {
      // Sincroniza el TabController
      widget.tabController?.animateTo(index);

      if (widget.pageController?.hasClients ?? false) {
        widget.pageController?.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      // Estilo y Configuración
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0.0, // Centro vertical
      backgroundColor: widget.backgroundColor,

      // Estado
      selectedIndex: _currentIndex,
      onDestinationSelected: _navigateToPage,

      // Mapeo de Destinos
      // Optimizamos el rendimiento generando la lista dentro del build
      destinations: widget.menuItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(
            item.icon,
            color: Theme.of(context).primaryColor,
          ), // Feedback visual mejorado
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}
