import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';

// Para usar el DropDownApp con opciones simples de String
class DropdownItem {
  final String value;
  final String label;
  final IconData? icon;

  DropdownItem({required this.value, required this.label, this.icon});
}

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _backupActivo = false;
  DropdownItem _frecuencia = DropdownItem(
    value: 'diario',
    label: 'Diariamente',
  );
  DropdownItem _destino = DropdownItem(value: 'drive', label: 'Google Drive');
  bool _isLoading = false;

  final List<DropdownItem> _frecuencias = [
    DropdownItem(value: 'diario', label: 'Diariamente', icon: Icons.schedule),
    DropdownItem(
      value: 'semanal',
      label: 'Semanalmente',
      icon: Icons.calendar_month,
    ),
    DropdownItem(
      value: 'mensual',
      label: 'Mensualmente',
      icon: Icons.calendar_today,
    ),
  ];

  final List<DropdownItem> _destinos = [
    DropdownItem(value: 'drive', label: 'Google Drive', icon: Icons.cloud),
    DropdownItem(value: 'dropbox', label: 'Dropbox', icon: Icons.storage),
    DropdownItem(value: 'email', label: 'Enviar por Email', icon: Icons.email),
  ];

  void _iniciarBackup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    print('Backup manual iniciado - Destino: ${_destino.label}');
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respaldo en segundo plano...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Backup Automático',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
          DropDownApp<DropdownItem>(
            labelText: 'Frecuencia de Respaldo',
            prefixIcon: Icons.schedule,
            initialValue: _frecuencias.firstWhere(
              (item) => item.value == _frecuencia.value,
              orElse: () => _frecuencias.first,
            ),
            items: _frecuencias,
            itemToString: (item) => item.label,
            onChanged: _backupActivo
                ? (value) {
                    setState(() => _frecuencia = value!);
                  }
                : null,
          ),
          const SizedBox(height: 16),
          DropDownApp<DropdownItem>(
            labelText: 'Destino de Almacenamiento',
            prefixIcon: Icons.storage,
            initialValue: _destinos.firstWhere(
              (item) => item.value == _destino.value,
              orElse: () => _destinos.first,
            ),
            items: _destinos,
            itemToString: (item) => item.label,
            onChanged: _backupActivo
                ? (value) {
                    setState(() => _destino = value!);
                  }
                : null,
          ),
          const SizedBox(height: 24),
          PrimaryButtonApp(
            text: 'Realizar Respaldo Ahora',
            icon: Icons.cloud_upload_outlined,
            onPressed: _iniciarBackup,
            isLoading: _isLoading,
            maxWidth: 400,
          ),
        ],
      ),
    );
  }
}
