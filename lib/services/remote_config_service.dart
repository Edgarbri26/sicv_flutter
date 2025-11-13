import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  // --- Configuración Singleton ---
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  // --- Constantes y Lógica ---
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Define tu URL estática como el valor *por defecto*
  // Esto es crucial si el usuario abre la app offline por primera vez.
  static const String _defaultApiUrl = 'http://localhost:3000/api';
  static const String _apiKey = 'ApiBackend'; // El nombre exacto de la consola

  // Getter público para que el resto de la app acceda a la URL
  String get apiUrl => _remoteConfig.getString(_apiKey);

  Future<void> initialize() async {
    try {
      // 1. Establece los valores por defecto
      // La app usará esto si no puede contactar a Firebase.
      await _remoteConfig.setDefaults(const {_apiKey: _defaultApiUrl});

      // 2. Configura los ajustes (opcional pero recomendado)
      // Esto define qué tan seguido la app buscará actualizaciones.
      // Un intervalo bajo es bueno para desarrollo, pero súbelo en producción.
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 5),
          minimumFetchInterval: const Duration(
            seconds: 10,
          ), // ¡Bajo solo para testing!
        ),
      );

      // 3. Obtiene y activa los valores del servidor
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Si falla (ej. sin conexión), la app usará los valores por defecto
      // establecidos en setDefaults().
      print('Error al inicializar Remote Config: $e');
    }
  }
}
