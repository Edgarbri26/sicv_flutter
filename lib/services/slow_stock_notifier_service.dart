// 📝 Archivo: inventory_notifier_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ¡Añadido para Riverpod!

// 💡 CORRECCIÓN CLAVE: Usamos un prefijo para las clases de notificaciones locales
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:sicv_flutter/models/app_noficacion_model.dart';

// Dependencias de estado (asumo que existen)
import 'package:sicv_flutter/providers/notificacion_provider.dart';

// ----------------------------------------------------------------------
// 1. Manejador de Notificaciones en Background (Top-Level Function)
// ----------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("🔔 Manejando mensaje en background: ${message.messageId}");
  }
  // En este punto, no podemos usar Riverpod directamente ya que la app está en background.
  // Solo se puede manejar la persistencia local (ej: Hive/Isar) si es necesario.
}

class SlowStockNotifierService {
  final ProviderContainer
  container; // 💡 PROPIEDAD AÑADIDA para acceder a Riverpod
  final _firebaseMessaging = FirebaseMessaging.instance;
  // Inicializamos el plugin local usando el prefijo fln
  final _localNotifications = fln.FlutterLocalNotificationsPlugin();

  // 💡 CONSTRUCTOR CORREGIDO: Ahora requiere el ProviderContainer
  SlowStockNotifierService(this.container);

  Future<void> initialize() async {
    // ------------------------------------
    // 1. Request de Permisos (iOS & Web)
    // ------------------------------------
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Permisos de notificaciones: ${settings.authorizationStatus}');
    }

    // ------------------------------------
    // 2. Setup del Manejador de Background
    // ------------------------------------
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ------------------------------------
    // 3. Inicialización Local Multiplataforma
    // ------------------------------------

    // 💡 Android, iOS y Web también necesitan configuración de inicialización
    const initializationSettingsAndroid = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // Icono para Android
    const initializationSettingsIOS = fln.DarwinInitializationSettings();

    // 💡 CORRECCIÓN DE ERRORES: Usamos 'final' y el prefijo 'fln'
    fln.WindowsInitializationSettings? initializationSettingsWindows;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      initializationSettingsWindows = fln.WindowsInitializationSettings(
        // ⬅️ ¡Aquí la corrección clave!
        appName: 'Inventario App',
        appUserModelId: 'com.sicv.inventario_app',
        // GUID generado para identificar la app en Windows (necesario para acciones)
        guid: '5d4b8e90-c23a-4e20-91c6-21805628469d',
        // ... otros parámetros
      );
    }

    // 💡 Inicialización Final:
    final initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      // Solo incluimos Windows si estamos en esa plataforma para evitar errores de compilación innecesarios
      windows: initializationSettingsWindows,
    );

    await _localNotifications.initialize(
      initializationSettings,
      // Manejador al tocar una notificación (ej. abrir el listado de notificaciones)
      onDidReceiveNotificationResponse:
          (fln.NotificationResponse response) async {
            // Lógica de acción al tocar la notificación.
            if (response.payload != null && kDebugMode) {
              print('Payload de Notificación Tocado: ${response.payload}');
            }
          },
    );

    // ------------------------------------
    // 4. Configurar Streams para Foreground
    // ------------------------------------
    _setupForegroundMessageHandling();

    // ------------------------------------
    // 5. Suscripción a Tópico Específico
    // ------------------------------------
    await _firebaseMessaging.subscribeToTopic('low_stock');

    final token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }
  }

  void _setupForegroundMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Mensaje Recibido en Foreground. Data: ${message.data}');
      }

      // 💡 INTEGRACIÓN RIVERPOD: Agregamos la notificación al estado de la campanita
      final newNotification = AppNotificationModel.fromRemoteMessage(message);
      container
          .read(notificationProvider.notifier)
          .addNotification(newNotification);

      // Si el mensaje tiene contenido (notification != null) y NO es Android/iOS
      // (que manejan su propia UI), disparamos la notificación local.
      if (message.notification != null &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              kIsWeb) // Web también requiere el plugin local para funcionar como popup
          ) {
        _showLocalNotification(message);
      }
    });
  }

  // ------------------------------------
  // Helper para mostrar notificaciones locales (Windows/Desktop/Web)
  // ------------------------------------
  void _showLocalNotification(RemoteMessage message) async {
    // 💡 CORRECCIÓN DE PREFIJOS: Usamos el prefijo 'fln' en NotificationDetails
    final details = fln.NotificationDetails(
      android: const fln.AndroidNotificationDetails(
        'low_stock_channel',
        'Alertas de Stock Bajo',
        channelDescription:
            'Notificaciones sobre productos con bajo inventario.',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
      ),
      iOS: const fln.DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      windows: fln.WindowsNotificationDetails(), // 💡 CORREGIDO: prefijo 'fln'
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data['productId']?.toString(),
    );
  }
}
