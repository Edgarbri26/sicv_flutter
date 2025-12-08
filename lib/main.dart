import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sicv_flutter/firebase_options.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';

// ⬇️ IMPORTANTE: Importa el servicio de notificaciones que creamos
// Asegúrate de que la ruta sea correcta según tu estructura de carpetas
import 'package:sicv_flutter/services/slow_stock_notifier_service.dart';

Future<void> main() async {
  // 1. Asegúrate de que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inicializa Remote Config
  await RemoteConfigService().initialize();

  // -----------------------------------------------------------
  // 🚀 CAMBIO CRÍTICO: Inicialización Manual de Riverpod
  // -----------------------------------------------------------

  // A. Creamos el contenedor de estado (el cerebro de Riverpod) manualmente.
  // Esto nos permite usarlo en lógica pura de Dart antes de lanzar la UI.
  final container = ProviderContainer();

  // B. Inicializamos el servicio de notificaciones usando el provider
  await container.read(slowStockNotifierProvider).initialize();

  // 4. Ejecuta tu app
  runApp(
    // C. Usamos UncontrolledProviderScope en lugar de ProviderScope.
    // Esto le dice a Flutter: "Usa este contenedor que ya creé y configuré arriba".
    UncontrolledProviderScope(container: container, child: InventoryApp()),
  );
}
