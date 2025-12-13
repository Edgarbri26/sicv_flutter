import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';

// Para usar el DropDownApp con opciones simples de String
class _DropdownItem {
  final String value;
  final String label;
  final IconData? icon;

  _DropdownItem({required this.value, required this.label, this.icon});
}

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _backupActivo = false;
  _DropdownItem _frecuencia = _DropdownItem(
    value: 'diario',
    label: 'Diariamente',
  );
  _DropdownItem _destino = _DropdownItem(value: 'drive', label: 'Google Drive');
  bool _isLoading = false;

  final List<_DropdownItem> _frecuencias = [
    _DropdownItem(value: 'diario', label: 'Diariamente', icon: Icons.schedule),
    _DropdownItem(
      value: 'semanal',
      label: 'Semanalmente',
      icon: Icons.calendar_month,
    ),
    _DropdownItem(
      value: 'mensual',
      label: 'Mensualmente',
      icon: Icons.calendar_today,
    ),
  ];

  final List<_DropdownItem> _destinos = [
    _DropdownItem(value: 'drive', label: 'Google Drive', icon: Icons.cloud),
    _DropdownItem(value: 'dropbox', label: 'Dropbox', icon: Icons.storage),
    _DropdownItem(value: 'email', label: 'Enviar por Email', icon: Icons.email),
  ];

  void _iniciarBackup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Backup manual iniciado - Destino: ${_destino.label}');
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
      appBar: AppBarApp(
        title: 'Backup Automático',
        iconColor: AppColors.textPrimary,
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
          DropDownApp<_DropdownItem>(
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
          DropDownApp<_DropdownItem>(
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
          ButtonApp(
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
