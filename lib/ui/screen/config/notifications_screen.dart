import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _alertasEmail = true;
  bool _notificacionesPush = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Alertas por Email'),
            subtitle: const Text(
              'Recibir resúmenes y alertas de stock bajo por correo',
            ),
            secondary: const Icon(Icons.email),
            value: _alertasEmail,
            onChanged: (value) {
              setState(() => _alertasEmail = value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notificaciones Push'),
            subtitle: const Text(
              'Recibir alertas instantáneas en este dispositivo',
            ),
            secondary: const Icon(Icons.phone_android),
            value: _notificacionesPush,
            onChanged: (value) {
              setState(() => _notificacionesPush = value);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
