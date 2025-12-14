import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sicv_flutter/firebase_options.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';

// ⬇️ IMPORTANTE: Importa el servicio de notificaciones que creamos
import 'package:sicv_flutter/services/slow_stock_notifier_service.dart';
import 'package:sicv_flutter/services/expiration_date_notifiere_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await RemoteConfigService().initialize();

  final container = ProviderContainer();

  container
      .read(slowStockNotifierProvider)
      .initialize()
      .then((_) {
        print("✅ Notificaciones listas (Cargaron en segundo plano)");
      })
      .catchError((e) {
        print("⚠️ Error inicializando notificaciones: $e");
      });

  container
      .read(expirationDateNotifierProvider)
      .initialize()
      .then((_) => print("✅ Alertas de vencimiento listas"))
      .catchError((e) => print("⚠️ Error inicializando vencimientos: $e"));

  runApp(
    UncontrolledProviderScope(container: container, child: InventoryApp()),
  );
}
