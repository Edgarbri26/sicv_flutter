import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart'; // Tu tema
import 'package:sicv_flutter/providers/notificacion_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos la lista completa de notificaciones
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botón para marcar todo como leído rápidamente
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Marcar todo como leído',
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  // Permite deslizar para eliminar (opcional, si añades delete al provider)
                  key: Key(notification.id),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    // Aquí llamarías a un método delete si lo tuvieras
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    // Si no está leída, ponemos un fondo sutil
                    tileColor: notification.isRead
                        ? null
                        : AppColors.primary.withOpacity(0.05),
                    leading: CircleAvatar(
                      backgroundColor: notification.isRead
                          ? Colors.grey.shade300
                          : AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: notification.isRead
                            ? Colors.grey
                            : AppColors.primary,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          // Formato de fecha simple (puedes usar intl aquí)
                          "${notification.timestamp.day}/${notification.timestamp.month} - ${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    trailing: !notification.isRead
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      // Al tocar, marcamos como leída
                      ref
                          .read(notificationProvider.notifier)
                          .markAsRead(notification.id);

                      // Opcional: Mostrar diálogo con detalles completos si es necesario
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Sin notificaciones nuevas",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
