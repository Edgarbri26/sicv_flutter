import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';
import 'package:sicv_flutter/models/client_model.dart';
import 'package:sicv_flutter/services/client_service.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class EditClientForm extends StatefulWidget {
  final ClientModel client; // Usa ClientModel
  final ClientService clientService;
  const EditClientForm({
    required this.client,
    required this.clientService,
    super.key,
  });

  @override
  EditClientFormState createState() => EditClientFormState();
}

class EditClientFormState extends State<EditClientForm> {
  late TextEditingController _ciController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late bool _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _ciController = TextEditingController(text: client.clientCi);
    _nameController = TextEditingController(text: client.name);
    _phoneController = TextEditingController(text: client.phone);
    _addressController = TextEditingController(text: client.address);
    _currentStatus = client.status;
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
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos marcados con *'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.clientService.update(
        widget.client.clientCi,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        status: _currentStatus,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
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
      decoration: const BoxDecoration(
        color: Colors.white,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.edit_note, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'Editar Cliente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFieldApp(
              controller: _ciController,
              labelText: 'CI / RUC',
              prefixIcon: Icons.badge,
              enabled: false,
            ),
            const SizedBox(height: 16),
            TextFieldApp(
              controller: _nameController,
              labelText: 'Nombre Completo *',
              prefixIcon: Icons.person,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFieldApp(
              controller: _phoneController,
              labelText: 'Teléfono *',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFieldApp(
              controller: _addressController,
              labelText: 'Dirección (Opcional)',
              prefixIcon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonApp(
                    text: 'Actualizar',
                    icon: Icons.save,
                    isLoading: _isLoading,
                    onPressed: _submitForm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
