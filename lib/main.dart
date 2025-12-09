import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sicv_flutter/firebase_options.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';

// ⬇️ IMPORTANTE: Importa el servicio de notificaciones que creamos
import 'package:sicv_flutter/services/slow_stock_notifier_service.dart';

Future<void> main() async {
  print("🔴 1. Iniciando Flutter...");
  WidgetsFlutterBinding.ensureInitialized();

  print("🔴 2. Conectando a Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("🔴 3. Cargando Remote Config...");
  await RemoteConfigService().initialize();

  final container = ProviderContainer();
  
  print("🔴 4. Iniciando Notificaciones de Stock...");
  container.read(slowStockNotifierProvider).initialize().then((_) {
    print("✅ Notificaciones listas (Cargaron en segundo plano)");
  }).catchError((e) {
    print("⚠️ Error inicializando notificaciones: $e");
  });

  print("🟢 5. ¡Todo listo! Lanzando la App...");
  runApp(
    UncontrolledProviderScope(container: container, child: InventoryApp()),
  );
}
