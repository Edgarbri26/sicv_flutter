import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Definición mínima de AppColors para que los widgets compilen
class AppColors {
  static const Color background = Color(0xFFF5F5F5);
  static const Color secondary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF616161);
  static const Color border = Color(0xFFBDBDBD);
  static const Color textPrimary = Colors.black87;
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

// (Plantilla 4)
class TextFieldApp extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const TextFieldApp({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 15.0, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
        suffixIcon: suffixIcon,
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
    );
  }
}

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  DropdownItem _monedaSeleccionada = DropdownItem(
    value: 'USD',
    label: 'USD - Dólar Estadounidense',
  );
  final TextEditingController _simboloController = TextEditingController(
    text: '\$',
  );
  final TextEditingController _decimalesController = TextEditingController(
    text: '2',
  );
  bool _isLoading = false;

  final List<DropdownItem> _monedas = [
    DropdownItem(value: 'USD', label: 'USD - Dólar Estadounidense'),
    DropdownItem(value: 'EUR', label: 'EUR - Euro'),
    DropdownItem(value: 'MXN', label: 'MXN - Peso Mexicano'),
    DropdownItem(value: 'COP', label: 'COP - Peso Colombiano'),
    DropdownItem(value: 'ARS', label: 'ARS - Peso Argentino'),
  ];

  void _guardarConfiguracion() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    print(
      'Moneda: ${_monedaSeleccionada.value}, Símbolo: ${_simboloController.text}',
    );
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración de moneda guardada.')),
      );
    }
  }

  @override
  void dispose() {
    _simboloController.dispose();
    _decimalesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Configuración de Moneda',
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
          DropDownApp<DropdownItem>(
            labelText: 'Tipo de Moneda Principal',
            prefixIcon: Icons.monetization_on,
            initialValue: _monedas.firstWhere(
              (item) => item.value == _monedaSeleccionada.value,
              orElse: () => _monedas.first,
            ),
            items: _monedas,
            itemToString: (item) => item.label,
            onChanged: (value) {
              setState(() {
                _monedaSeleccionada = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFieldApp(
            controller: _simboloController,
            labelText: 'Símbolo Monetario',
            prefixIcon: Icons.attach_money,
            inputFormatters: [LengthLimitingTextInputFormatter(3)],
          ),
          const SizedBox(height: 16),
          TextFieldApp(
            controller: _decimalesController,
            labelText: 'Número de Decimales',
            prefixIcon: Icons.format_list_numbered,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButtonApp(
            text: 'Guardar',
            icon: Icons.save,
            onPressed: _guardarConfiguracion,
            isLoading: _isLoading,
            maxWidth: 400,
          ),
        ],
      ),
    );
  }
}
