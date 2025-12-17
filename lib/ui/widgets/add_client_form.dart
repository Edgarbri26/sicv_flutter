import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sicv_flutter/services/client_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart'
    show ButtonApp, ButtonType;
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart'
    show TextFieldApp;

class AddClientForm extends StatefulWidget {
  const AddClientForm({super.key});

  @override
  AddClientFormState createState() => AddClientFormState();
}

class AddClientFormState extends State<AddClientForm> {
  final ClientService clientService = ClientService();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added GlobalKey
  late TextEditingController _ciController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ciController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _ciController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Standard Type Form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await clientService.create(
        ci: _ciController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey, // Assigned key
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Registrar Nuevo Cliente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Completa los datos del nuevo cliente',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFieldApp(
                autoFocus: true,
                controller: _ciController,
                labelText: 'CI *',
                prefixIcon: Icons.badge,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    // Added trim()
                    return 'Por favor, ingresa el CI';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFieldApp(
                controller: _nameController,
                labelText: 'Nombre Completo o Razón Social *',
                prefixIcon: Icons.person,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    // Added trim()
                    return 'Por favor, ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFieldApp(
                controller: _phoneController,
                labelText: 'Teléfono *',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    // Added trim()
                    return 'Por favor, ingresa el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFieldApp(
                controller: _addressController,
                labelText: 'Dirección (Opcional)',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                // Validation for address is generally optional or specific, leaving prompt's implementation
                validator: (value) {
                  // User had this validation, keeping it but adding trim
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa la dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ButtonApp(
                      text: 'Cancelar',
                      onPressed: _isLoading
                          ? () {}
                          : () => Navigator.of(context).pop(false),
                      type: ButtonType.secondary,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonApp(
                      text: 'Guardar',
                      icon: Icons.save,
                      isLoading: _isLoading,
                      onPressed: _submitForm,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
