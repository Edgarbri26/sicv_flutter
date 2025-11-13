import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sicv_flutter/firebase_options.dart';
import 'package:sicv_flutter/services/remote_config_service.dart';

Future<void> main() async {
  // 2. Convierte main en 'async'

  // 3. Asegúrate de que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa tu servicio de Remote Config
  await RemoteConfigService().initialize();
  // 4. Carga el archivo .env
  // await dotenv.load(fileName: ".env");

  runApp(ProviderScope(child: InventoryApp())); // 5. Ejecuta tu app
}
