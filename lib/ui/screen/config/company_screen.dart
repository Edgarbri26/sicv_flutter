import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(
    text: 'Mi Inventario S.A. de C.V.',
  );
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  bool _isLoading = false;

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      print('Datos guardados: ${_nameController.text}');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información de la empresa actualizada.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarApp(title: 'Información de la Empresa', iconColor: AppColors.textPrimary,),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
            ),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFieldApp(
                  controller: _nameController,
                  labelText: 'Nombre de la Empresa',
                  prefixIcon: Icons.business,

                ),
                const SizedBox(height: 16),
                TextFieldApp(
                  controller: _addressController,
                  labelText: 'Dirección',
                  prefixIcon: Icons.location_on,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFieldApp(
                  controller: _phoneController,
                  labelText: 'Teléfono',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFieldApp(
                  controller: _rfcController,
                  labelText: 'Datos Fiscales (RFC)',
                  prefixIcon: Icons.policy,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 50),
                PrimaryButtonApp(
                  text: 'Guardar Cambios',
                  icon: Icons.save,
                  onPressed: _guardarCambios,
                  isLoading: _isLoading,
                  maxWidth: 400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
