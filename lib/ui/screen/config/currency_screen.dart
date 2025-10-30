import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/drop_down_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

// Para usar el DropDownApp con opciones simples de String
class DropdownItem {
  final String value;
  final String label;
  final IconData? icon;

  DropdownItem({required this.value, required this.label, this.icon});
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
      appBar: AppBarApp(title: 'Configuración de Moneda', iconColor: AppColors.textPrimary,),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
          ),
          child: ListView(
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
              const SizedBox(height: 50),
              PrimaryButtonApp(
                text: 'Guardar',
                icon: Icons.save,
                onPressed: _guardarConfiguracion,
                isLoading: _isLoading,
                maxWidth: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
