import 'package:flutter/material.dart';

// Definición mínima de AppColors para que los widgets compilen
class AppColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color secondary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF616161);
  static const Color border = Color(0xFFBDBDBD);
}

// Para usar el DropDownApp con opciones simples de String
class DropdownItem {
  final String value;
  final String label;
  final IconData? icon;

  DropdownItem({required this.value, required this.label, this.icon});
}

// (Plantilla 1)
class PrimaryButtonApp extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final double maxWidth;

  const PrimaryButtonApp({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.maxWidth = 250,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ElevatedButton.icon(
          icon: isLoading
              ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 3,
                  ),
                )
              : Icon(icon ?? Icons.save),
          label: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(64, 50),
          ),
          onPressed: isLoading ? null : onPressed,
        ),
      ),
    );
  }
}

// (Plantilla 2)
class DropDownApp<ItemType> extends StatelessWidget {
  final ItemType? initialValue;
  final List<ItemType> items;
  final ValueChanged<ItemType?>? onChanged;
  final String Function(ItemType item) itemToString;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;

  const DropDownApp({
    super.key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    required this.itemToString,
    required this.labelText,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ItemType>(
      dropdownColor: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconSize: 24,
      menuMaxHeight: 500.0,
      isExpanded: true,
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 3.0,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
      ),
      initialValue: initialValue,
      items: items.map((ItemType item) {
        return DropdownMenuItem<ItemType>(
          value: item,
          child: Text(
            itemToString(item),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
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
