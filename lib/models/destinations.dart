import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/destination.dart';
import 'package:sicv_flutter/config/app_routes.dart';

final List<Destination> destinationsPages = [
  Destination(
    label: 'Inicio', 
    icon: Icons.home, 
    route: AppRoutes.home, 
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