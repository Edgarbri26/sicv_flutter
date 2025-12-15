// 📝 Archivo: state/notification_state.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sicv_flutter/models/app_noficacion_model.dart';

// ----------------------------------------------------------------
// 1. StateNotifier para la Lógica de Negocio
// ----------------------------------------------------------------
class NotificationNotifier extends StateNotifier<List<AppNotificationModel>> {
  // Inicializamos el estado con una lista vacía (o podrías cargar desde persistencia aquí)
  NotificationNotifier() : super([]);

  // Añade una nueva notificación al inicio de la lista
  void addNotification(AppNotificationModel newNotification) {
    // Cuando el estado (state) es modificado, Riverpod notifica a todos los oyentes (widgets)
    state = [newNotification, ...state];
  }

  // Marca una notificación específica como leída
  void markAsRead(String notificationId) {
    // Usamos el map para buscar y el copyWith para recrear la instancia de forma inmutable
    state = [
      for (final notif in state)
        if (notif.id == notificationId) notif.copyWith(isRead: true) else notif,
    ];
  }

  // Marca todas las notificaciones como leídas (al abrir la lista, por ejemplo)
  void markAllAsRead() {
    state = [for (final notif in state) notif.copyWith(isRead: true)];
  }

  // Getter CLAVE: Calcula el contador de no leídas para el badge de la campanita
  int get unreadCount => state.where((n) => !n.isRead).length;
}

// ----------------------------------------------------------------
// 2. El Provider Global (para que el UI acceda a la lista y la lógica)
// ----------------------------------------------------------------
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotificationModel>>((
      ref,
    ) {
      // Aquí se crea y se gestiona la única instancia de NotificationNotifier
      return NotificationNotifier();
    });

// ----------------------------------------------------------------
// 3. Provider Derivado (para el contador, más eficiente)
// ----------------------------------------------------------------
final unreadCountProvider = Provider<int>((ref) {
  // Este provider observa el Notifier y solo redibuja el badge si el número de no leídas cambia.
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
