// 📝 Archivo: inventory_notifier_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos local_notifications con el prefijo 'fln'
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

// Importa tus modelos y providers
import 'package:sicv_flutter/models/app_noficacion_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/providers/notificacion_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';
// import 'package:sicv_flutter/services/product_service.dart'; // Ya no lo usamos directo aqui

// ----------------------------------------------------------------------
// 1. Manejador de Notificaciones en Background (Top-Level Function)
// ----------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("🔔 Background Handler: ${message.messageId}");
  }
  // Aquí la app está cerrada o en segundo plano.
  // No podemos acceder al 'container' de Riverpod directamente aquí sin inicializarlo de nuevo,
  // pero FCM se encarga de mostrar la notificación nativa si viene con payload 'notification'.
}

// 🚀 PROVIDER
final slowStockNotifierProvider = Provider<SlowStockNotifierService>((ref) {
  return SlowStockNotifierService(ref);
});

class SlowStockNotifierService {
  final Ref ref; // Cambiado de ProviderContainer a Ref
  FirebaseMessaging? _firebaseMessaging;
  final _localNotifications = fln.FlutterLocalNotificationsPlugin();

  SlowStockNotifierService(this.ref) {
    // 👂 Listener REACTIVO (Debe ir en el constructor)
    // Escuchamos los cambios de stock. Si cambia y el servicio está listo, revisamos.
    ref.listen<AsyncValue<List<ProductModel>>>(productsProvider, (
      previous,
      next,
    ) {
      next.whenData((products) {
        if (_isReady) _checkLowStock(products);
      });
    });
  }

  bool _isReady = false;

  Future<void> initialize() async {
    // ------------------------------------
    // 1. Request de Permisos (iOS, Web y Android 13+)
    // ------------------------------------

    // Inicializar Firebase Messaging solo si es soportado (no Windows/Linux, excepto si es Web)
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.windows &&
            defaultTargetPlatform != TargetPlatform.linux)) {
      _firebaseMessaging = FirebaseMessaging.instance;
    }

    // Permisos básicos (iOS/Web)
    if (_firebaseMessaging != null) {
      NotificationSettings settings = await _firebaseMessaging!
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: true,
            provisional: false,
            sound: true,
          );

      if (kDebugMode) {
        print('Permiso usuario: ${settings.authorizationStatus}');
      }
    }

    // 🚨 Permisos específicos para Android 13+ (necesario para ver notificaciones)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }

    // ------------------------------------
    // 2. Setup del Manejador de Background
    // ------------------------------------
    if (_firebaseMessaging != null) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    // ------------------------------------
    // 3. Inicialización Local Multiplataforma
    // ------------------------------------

    // Android: Icono de la app (asegúrate que 'ic_launcher' exista en android/app/src/main/res/mipmap-*)
    const initializationSettingsAndroid = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS
    const initializationSettingsIOS = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Windows
    fln.WindowsInitializationSettings? initializationSettingsWindows;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      initializationSettingsWindows = fln.WindowsInitializationSettings(
        appName: 'Inventario App',
        appUserModelId: 'com.sicv.inventario_app',
        guid: '5d4b8e90-c23a-4e20-91c6-21805628469d',
      );
    }

    final initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      windows: initializationSettingsWindows,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) async {
        if (kDebugMode) {
          print('🔔 Toco notificación. Payload: ${response.payload}');
        }
        // TODO: Aquí puedes añadir lógica de navegación (ej. ir al detalle del producto)
      },
    );

    // ------------------------------------
    // 4. Configurar Streams para Foreground
    // ------------------------------------
    _setupForegroundMessageHandling();

    // ------------------------------------
    // 5. Suscripción a Tópico (CON TRY-CATCH MEJORADO)
    // ------------------------------------
    try {
      if (_firebaseMessaging != null) {
        // En Web, a veces suscribirse tarda mucho, le ponemos un timeout de 3 segundos
        // para no bloquear nada si Firebase está lento.
        await _firebaseMessaging!
            .subscribeToTopic('low_stock')
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                if (kDebugMode)
                  print(
                    "⚠️ Timeout al suscribirse al tópico (Web es lento a veces)",
                  );
                return; // Retornamos void
              },
            );
        if (kDebugMode) print("✅ Suscrito al tópico 'low_stock'");
      } else {
        if (kDebugMode) print("⚠️ FCM no disponible en esta plataforma (Skip)");
      }
    } catch (e) {
      // Es muy común que falle en Windows o Web Localhost, no pasa nada.
      debugPrint("⚠️ Aviso: No se pudo suscribir a FCM (Normal en Dev): $e");
    }

    // ------------------------------------
    // 6. Configurar el Listener y Polling
    // ------------------------------------
    _isReady = true;

    // Iniciamos el polling aunque las notificaciones fallaran
    _startProviderPolling();
  }

  void _startProviderPolling() {
    // Inmediatamente pedimos datos frescos
    ref.refresh(productsProvider);

    // Repite cada 60 segundos
    _scheduleNextRefresh();
  }

  void _scheduleNextRefresh() {
    Future.delayed(const Duration(seconds: 60), () {
      if (kDebugMode) print("🔄 Polling: Refrescando lista de productos...");
      ref.invalidate(productsProvider); // Esto dispara una nueva recarga de red
      _scheduleNextRefresh();
    });
  }

  // Variable para evitar notificar lo mismo repetidamente en corto tiempo
  final Set<int> _notifiedProducts = {};

  // Ahora recibe la lista del Provider (REACTIVO), no la busca él mismo.
  void _checkLowStock(List<ProductModel> products) {
    try {
      if (kDebugMode)
        print("🔍 Analizando stock de ${products.length} productos...");

      final lowStockProducts = products
          .where((p) => p.totalStock <= p.minStock && p.totalStock > 0)
          .toList();

      for (var product in lowStockProducts) {
        if (!_notifiedProducts.contains(product.id)) {
          // Disparamos notificación local
          _showLocalNotification(
            RemoteMessage(
              notification: RemoteNotification(
                title: "⚠️ Stock Bajo: ${product.name}",
                body:
                    "Quedan ${product.totalStock} unidades. Mínimo: ${product.minStock}",
              ),
              data: {'productId': product.id},
            ),
          );

          // Agregamos al sistema de notificaciones de la app (campanita)
          final appNotif = AppNotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: "Stock Bajo: ${product.name}",
            body:
                "El producto ha alcanzado su nivel mínimo de inventario (${product.totalStock}).",
            timestamp: DateTime.now(),
            isRead: false,
            data: {'productId': product.id},
          );
          ref.read(notificationProvider.notifier).addNotification(appNotif);

          _notifiedProducts.add(product.id);
        }
      }

      // Limpieza simple
      final currentLowStockIds = lowStockProducts.map((p) => p.id).toSet();
      _notifiedProducts.removeWhere((id) => !currentLowStockIds.contains(id));
    } catch (e) {
      debugPrint("Error analizando stock: $e");
    }
  }

  void _setupForegroundMessageHandling() {
    if (_firebaseMessaging == null) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Mensaje en Foreground: ${message.data}');
      }

      // 1. Actualizar Estado (Campanita)
      final newNotification = AppNotificationModel.fromRemoteMessage(message);
      ref.read(notificationProvider.notifier).addNotification(newNotification);

      // 2. Mostrar Banner Flotante (Heads-up)
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  // ------------------------------------
  // Helper para mostrar notificaciones (Banner/Sonido/Vibración)
  // ------------------------------------
  void _showLocalNotification(RemoteMessage message) async {
    // 🔥 CONFIGURACIÓN ANDROID PARA BANNER FLOTANTE (HEADS-UP)
    const androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
      'high_importance_channel_v2', // ID Nuevo para forzar actualización
      'Alertas Críticas de Stock', // Nombre del canal
      channelDescription: 'Muestra banners flotantes cuando el stock es bajo.',
      importance: fln.Importance.max, // 🚨 CRUCIAL: Max hace que baje el banner
      priority: fln.Priority.high, // 🚨 CRUCIAL: Alta prioridad
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      styleInformation: fln.BigTextStyleInformation(
        '',
      ), // Permite texto largo expandible
    );

    // 🔥 CONFIGURACIÓN IOS PARA BANNER
    const darwinPlatformChannelSpecifics = fln.DarwinNotificationDetails(
      presentAlert: true, // Mostrar banner
      presentSound: true, // Sonido
      presentBanner: true, // Banner (iOS 14+)
    );

    // Detalles generales
    const platformChannelSpecifics = fln.NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
      windows:
          fln.WindowsNotificationDetails(), // Windows usa la config por defecto del sistema
    );

    // Mostrar la notificación
    await _localNotifications.show(
      message.hashCode, // ID único
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['productId']?.toString(),
    );
  }
}
