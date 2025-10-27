import 'package:flutter/material.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _backupActivo = false;
  String _frecuencia = 'diario';
  String _destino = 'drive';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Automático')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Activar respaldos automáticos'),
            secondary: const Icon(Icons.cloud_upload),
            value: _backupActivo,
            onChanged: (value) {
              setState(() => _backupActivo = value);
            },
          ),
          const Divider(),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Frecuencia de Respaldo',
              icon: Icon(Icons.schedule),
            ),
            initialValue: _frecuencia,
            items: const [
              DropdownMenuItem(value: 'diario', child: Text('Diariamente')),
              DropdownMenuItem(value: 'semanal', child: Text('Semanalmente')),
              DropdownMenuItem(value: 'mensual', child: Text('Mensualmente')),
            ],
            onChanged: _backupActivo
                ? (value) {
                    setState(() => _frecuencia = value!);
                  }
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Destino de Almacenamiento',
              icon: Icon(Icons.storage),
            ),
            initialValue: _destino,
            items: const [
              DropdownMenuItem(value: 'drive', child: Text('Google Drive')),
              DropdownMenuItem(value: 'dropbox', child: Text('Dropbox')),
              DropdownMenuItem(value: 'email', child: Text('Enviar por Email')),
            ],
            onChanged: _backupActivo
                ? (value) {
                    setState(() => _destino = value!);
                  }
                : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Realizar Respaldo Ahora'),
            onPressed: () {
              print('TODO: Iniciar backup manual');
            },
          ),
        ],
      ),
    );
  }
}
