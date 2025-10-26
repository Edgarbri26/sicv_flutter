// lib/widgets/admin/add_user_form_sheet.dart

import 'package:flutter/material.dart';

class AddUserFormSheet extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> rolesDisponibles;

  const AddUserFormSheet({
    super.key,
    required this.scrollController,
    required this.rolesDisponibles,
  });

  @override
  _AddUserFormSheetState createState() => _AddUserFormSheetState();
}

class _AddUserFormSheetState extends State<AddUserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Selecciona el primer rol de la lista (ej. 'Admin')
    _selectedRole = widget.rolesDisponibles.isNotEmpty ? widget.rolesDisponibles[0] : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Formulario no válido
    }

    setState(() { _isLoading = true; });

    // --- Simulación de llamada a la API ---
    await Future.delayed(Duration(seconds: 2));
    print('Nombre: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Rol: $_selectedRole');
    // ------------------------------------

    setState(() { _isLoading = false; });

    if (!mounted) return;
    
    // Cierra el panel y devuelve 'true' (éxito)
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Estilos del panel (color y bordes)
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: widget.scrollController, // Conecta el scroll
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // "Agarrador" (handle)
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'Añadir Nuevo Usuario',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (!v.contains('@')) return 'Email no válido';
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rol del Usuario',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: widget.rolesDisponibles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
  
                  onChanged: (newValue) {
                    setState(() { _selectedRole = newValue; });
                  },
                  validator: (v) => (v == null) ? 'Selecciona un rol' : null,
                ),
                SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear Usuario'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}