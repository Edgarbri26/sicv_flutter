// 📝 Archivo: models/notification_model.dart

import 'package:firebase_messaging/firebase_messaging.dart';

/// Represents a notification within the application.
///
/// This model holds the data related to a notification, including its
/// content, timestamp, and read status. It supports creation from
/// Firebase [RemoteMessage] and provides utility for immutability.
class AppNotificationModel {
  /// Unique identifier for the notification.
  final String id;

  /// The title of the notification.
  final String title;

  /// The body text of the notification.
  final String body;

  /// The date and time when the notification was sent or received.
  final DateTime timestamp;

  /// Additional payload data associated with the notification.
  final Map<String, dynamic> data;

  /// Indicates whether the notification has been read by the user.
  final bool isRead;

  /// Creates a new [AppNotificationModel].
  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.data,
    this.isRead = false,
  });

  // Método simple para crear una notificación desde el payload de Firebase
  /// Factory constructor to create an [AppNotificationModel] from a Firebase [RemoteMessage].
  ///
  /// Extracts the title, body, and data from the remote message.
  /// If [message.messageId] is null, a fallback ID based on the current timestamp is used.
  factory AppNotificationModel.fromRemoteMessage(RemoteMessage message) {
    return AppNotificationModel(
      // Usamos el messageId o un timestamp único como fallback si el id no está disponible
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Alerta de Stock',
      body:
          message.notification?.body ??
          'Revisa el inventario para más detalles.',
      timestamp: message.sentTime ?? DateTime.now(),
      data: message.data,
    );
  }

  // 💡 CLAVE: Método copyWith para mantener la inmutabilidad de los estados en Riverpod.
  // Permite crear una nueva instancia con un campo modificado (ej: cambiar solo isRead).
  /// Creates a copy of this [AppNotificationModel] with the given fields replaced with the new values.
  ///
  /// This is useful for maintaining immutability in state management (e.g., Riverpod).
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
