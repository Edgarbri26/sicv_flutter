import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteConfigService {
  // --- Configuración Singleton ---
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  // --- Constantes y Lógica ---
  // Hacemos _remoteConfig nullable porque en Windows/Linux no existe
  FirebaseRemoteConfig? _remoteConfig;

  // Define tu URL estática como el valor *por defecto*
  // Esto es crucial si el usuario abre la app offline por primera vez.
  static const String _defaultApiUrl = 'http://localhost:3000/api';
  static const String _apiKey = 'ApiBackend'; // El nombre exacto de la consola

  static const String _prefKeyCustomUrl = 'custom_api_url';
  String? _localCustomUrl;

  // Getter público: Prioridad: Local > Remote Config > Default
  String get apiUrl {
    if (_localCustomUrl != null && _localCustomUrl!.isNotEmpty) {
      return _localCustomUrl!;
    }
    // Si remote config existe, intentamos usarlo
    if (_remoteConfig != null) {
      return _remoteConfig!.getString(_apiKey);
    }
    // Fallback absoluto
    return _defaultApiUrl;
  }

  Future<void> initialize() async {
    // 0. Cargar URL local si existe
    try {
      final prefs = await SharedPreferences.getInstance();
      _localCustomUrl = prefs.getString(_prefKeyCustomUrl);
      if (_localCustomUrl != null) {
        debugPrint('📦 Usando URL de backend personalizada: $_localCustomUrl');
      }
    } catch (e) {
      debugPrint('Error cargando preferencias: $e');
    }

    // Si es Web, permitimos continuar (Firebase SDK Web soporta Remote Config).
    // Si es Nativo (Desktop Windows/Linux), lo bloqueamos porque no hay soporte oficial aún.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      debugPrint(
        '⚠️ Remote Config no soportado en Desktop (Windows/Linux). Usando valores por defecto.',
      );
      return;
    }

    try {
      // Inicializamos Firebase Remote Config SOLO si no es desktop
      _remoteConfig = FirebaseRemoteConfig.instance;

      if (_remoteConfig != null) {
        // 1. Establece los valores por defecto
        // La app usará esto si no puede contactar a Firebase.
        await _remoteConfig!.setDefaults(const {_apiKey: _defaultApiUrl});

        // 2. Configura los ajustes (opcional pero recomendado)
        // Esto define qué tan seguido la app buscará actualizaciones.
        // Un intervalo bajo es bueno para desarrollo, pero súbelo en producción.
        await _remoteConfig!.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 5),
            minimumFetchInterval: const Duration(
              seconds: 10,
            ), // ¡Bajo solo para testing!
          ),
        );

        // 3. Obtiene y activa los valores del servidor
        await _remoteConfig!.fetchAndActivate();
      }
    } catch (e) {
      debugPrint('Error al inicializar Remote Config: $e');
    }
  }

  // Métodos para gestionar la URL personalizada
  Future<void> setCustomUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyCustomUrl, url);
    _localCustomUrl = url;
    debugPrint('💾 Nueva URL de backend guardada: $url');
  }

  Future<void> clearCustomUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyCustomUrl);
    _localCustomUrl = null;
  }
}
