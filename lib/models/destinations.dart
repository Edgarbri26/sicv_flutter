import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/destination.dart';
import 'package:sicv_flutter/config/app_routes.dart';

final List<Destination> destinationsPages = [
  Destination(label: 'Inicio', icon: Icons.home, route: AppRoutes.home),

  Destination(
    label: 'Ventas',
    icon: Icons.point_of_sale,
    route: AppRoutes.sales,
  ),

  Destination(
    label: 'Compras',
    icon: Icons.shopping_cart,
    route: AppRoutes.purchase,
  ),

  Destination(
    label: 'Inventario',
    icon: Icons.inventory,
    route: AppRoutes.inventory,
  ),

  Destination(
    label: 'Reportes',
    icon: Icons.assessment,
    route: AppRoutes.reportDashboard,
  ),

  Destination(
    label: 'Movimientos',
    icon: Icons.compare_arrows,
    route: AppRoutes.movements,
  ),
];
