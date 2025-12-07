// 📝 Archivo: models/notification_model.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.data,
    this.isRead = false,
  });

  // Método simple para crear una notificación desde el payload de Firebase
  factory AppNotificationModel.fromRemoteMessage(RemoteMessage message) {
    return AppNotificationModel(
      // Usamos el messageId o un timestamp único como fallback si el id no está disponible
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Alerta de Stock',
      body: message.notification?.body ?? 'Revisa el inventario para más detalles.',
      timestamp: message.sentTime ?? DateTime.now(),
      data: message.data,
    );
  }

  // 💡 CLAVE: Método copyWith para mantener la inmutabilidad de los estados en Riverpod.
  // Permite crear una nueva instancia con un campo modificado (ej: cambiar solo isRead).
  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }
}