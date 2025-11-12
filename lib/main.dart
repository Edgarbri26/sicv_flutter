import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // 2. Convierte main en 'async'
  

  // 3. Asegúrate de que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Carga el archivo .env
  // await dotenv.load(fileName: ".env");

  runApp(ProviderScope(child: InventoryApp())); // 5. Ejecuta tu app
}
