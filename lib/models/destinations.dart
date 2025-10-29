import 'package:flutter/material.dart';
import 'package:sicv_flutter/models/destination.dart';
import 'package:sicv_flutter/config/app_routes.dart';

final List<Destination> destinations = [
    Destination(
      label: 'Inicio',
      icon: Icon(Icons.home),
      route: AppRoutes.home,
    ),
    Destination(  
      label: 'Reportes',
      icon: Icon(Icons.assessment),
      route: AppRoutes.reportDashboard,
    ),
    Destination(
      label: 'Movimientos',
      icon: Icon(Icons.compare_arrows),
      route: AppRoutes.movements 
    ),
    Destination(
      label: 'Perfil',
      icon: Icon(Icons.person),
      route: AppRoutes.perfil 
    ),
    Destination(
      label: 'Configuración',
      icon: Icon(Icons.settings),
      route: AppRoutes.settings
    ),
    Destination(
      label: 'Cerrar Sesión',
      icon: Icon(Icons.logout),
    ),
  ] ;