// 📝 Archivo: expiration_date_notifier_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importamos local_notifications con el prefijo 'fln'
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:sicv_flutter/core/theme/app_colors.dart';

// Importa tus modelos y providers
import 'package:sicv_flutter/models/app_noficacion_model.dart';
import 'package:sicv_flutter/models/product/product_model.dart';
import 'package:sicv_flutter/providers/notificacion_provider.dart';
import 'package:sicv_flutter/providers/product_provider.dart';

// ----------------------------------------------------------------------
// 1. Manejador de Notificaciones en Background (Top-Level Function)
// ----------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("🔔 Background Handler: ${message.messageId}");
  }
}

final expirationDateNotifierProvider = Provider<ExpirationDateNotifierService>((
  ref,
) {
  return ExpirationDateNotifierService(ref);
});

class ExpirationDateNotifierService {
  final Ref ref;
  FirebaseMessaging? _firebaseMessaging;
  final _localNotifications = fln.FlutterLocalNotificationsPlugin();

  ExpirationDateNotifierService(this.ref) {
    // 👂 Listener REACTIVO
    ref.listen<AsyncValue<List<ProductModel>>>(productsProvider, (
      previous,
      next,
    ) {
      next.whenData((products) {
        if (_isReady) _checkExpiration(products);
      });
    });
  }

  bool _isReady = false;

  Future<void> initialize() async {
    // ------------------------------------
    // 1. Request de Permisos
    // ------------------------------------
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.windows &&
            defaultTargetPlatform != TargetPlatform.linux)) {
      _firebaseMessaging = FirebaseMessaging.instance;
    }

    if (_firebaseMessaging != null) {
      await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
      );
    }

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
    // 2. Setup Background Handler
    // ------------------------------------
    if (_firebaseMessaging != null) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    // ------------------------------------
    // 3. Inicialización Local
    // ------------------------------------
    const initializationSettingsAndroid = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettingsIOS = fln.DarwinInitializationSettings();

    fln.WindowsInitializationSettings? initializationSettingsWindows;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      initializationSettingsWindows = fln.WindowsInitializationSettings(
        appName: 'Inventario App',
        appUserModelId: 'com.sicv.inventario_app',
        guid: 'expiration_notifier_guid',
      );
    }

    final initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      windows: initializationSettingsWindows,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (fln.NotificationResponse response) async {
            if (kDebugMode) {
              print(
                '🔔 Toco notificación expiración. Payload: ${response.payload}',
              );
            }
          },
    );

    // ------------------------------------
    // 4. Foreground Handler
    // ------------------------------------
    _setupForegroundMessageHandling();

    // ------------------------------------
    // 5. Subscribe Topic
    // ------------------------------------
    try {
      if (_firebaseMessaging != null) {
        await _firebaseMessaging!
            .subscribeToTopic('expiration_alert')
            .timeout(const Duration(seconds: 3), onTimeout: () => {});
      }
    } catch (e) {
      debugPrint("⚠️ No se pudo suscribir a topic: $e");
    }

    _isReady = true;
    _startProviderPolling();
  }

  void _startProviderPolling() {
    ref.refresh(productsProvider);
    _scheduleNextRefresh();
  }

  void _scheduleNextRefresh() {
    Future.delayed(const Duration(hours: 4), () {
      // Revisamos cada 4 horas (menos frecuente que stock)
      if (kDebugMode) print("🔄 Polling Expiración...");
      ref.invalidate(productsProvider);
      _scheduleNextRefresh();
    });
  }

  // Set de IDs de lotes ya notificados hoy para no spamear
  // En una app real, esto debería persistirse o resetearse cada día
  final Set<int> _notifiedLots = {};

  void _checkExpiration(List<ProductModel> products) {
    try {
      final now = DateTime.now();
      // Umbral de alerta: 30 días para anticipar
      final warningThreshold = now.add(const Duration(days: 30));

      for (var product in products) {
        if (!product.perishable) continue;

        for (var lot in product.stockLots) {
          if (lot.amount <= 0 || !lot.status) continue;
          if (_notifiedLots.contains(lot.stockLotId)) continue;

          final daysLeft = lot.expirationDate.difference(now).inDays;

          bool shouldNotify = false;
          String title = "";
          String body = "";

          // 1. Ya Vencido
          if (lot.expirationDate.isBefore(now)) {
            shouldNotify = true;
            title = "❌ PRODUCTO VENCIDO: ${product.name}";
            body =
                "El lote ${lot.stockLotId} venció el ${lot.expirationDate.toLocal().toString().split(' ')[0]}. Stock: ${lot.amount}";
          }
          // 2. Por Vencer (dentro del umbral)
          else if (lot.expirationDate.isBefore(warningThreshold)) {
            shouldNotify = true;
            title = "⚠️ Próximo a Vencer: ${product.name}";
            body =
                "Lote ${lot.stockLotId} vence en $daysLeft días (${lot.expirationDate.toLocal().toString().split(' ')[0]}). Stock: ${lot.amount}";
          }

          if (shouldNotify) {
            // Notificación Local
            _showLocalNotification(title, body, {
              'productId': product.id,
              'lotId': lot.stockLotId,
            });

            // Notificación In-App
            final appNotif = AppNotificationModel(
              id: "exp_${lot.stockLotId}_${now.millisecondsSinceEpoch}",
              title: title,
              body: body,
              timestamp: now,
              isRead: false,
              data: {'productId': product.id, 'lotId': lot.stockLotId},
            );
            ref.read(notificationProvider.notifier).addNotification(appNotif);

            _notifiedLots.add(lot.stockLotId);
          }
        }
      }
    } catch (e) {
      debugPrint("Error analizando expiración: $e");
    }
  }

  void _setupForegroundMessageHandling() {
    if (_firebaseMessaging == null) return;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Manejo genérico si enviamos push manual desde servidor con data
      // ...
    });
  }

  void _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = fln.AndroidNotificationDetails(
      'expiration_channel',
      'Alertas de Vencimiento',
      channelDescription: 'Notifica productos próximos a vencer o vencidos.',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      color: AppColors.danger, // Rojo
    );

    const iosDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBanner: true,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const fln.NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
        windows: fln.WindowsNotificationDetails(),
      ),
      payload: data['productId']?.toString(),
    );
  }
}
