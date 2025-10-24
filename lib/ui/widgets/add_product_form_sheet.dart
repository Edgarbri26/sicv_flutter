// lib/ui/widgets/add_product_form_sheet.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:sicv_flutter/services/product_api_service.dart';
// import 'package:sicv_flutter/models/category.dart';

class AddProductFormSheet extends StatefulWidget {
  // --- 1. ACEPTA EL SCROLL CONTROLLER ---
  final ScrollController scrollController;

  const AddProductFormSheet({
    Key? key,
    required this.scrollController,
    // required this.categories
  }) : super(key: key);

  @override
  _AddProductFormSheetState createState() => _AddProductFormSheetState();
}

class _AddProductFormSheetState extends State<AddProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  // ... (otros controladores) ...

  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // (Aquí van tus funciones _pickImage, _submitData, etc.)
  // ... (Asegúrate de copiar _pickImage, _buildImagePreview y _submitData
  // de la versión anterior que te di) ...

  @override
  Widget build(BuildContext context) {
    // --- 2. EL CONTENEDOR AHORA REDONDEA SUS BORDES Y TIENE COLOR ---
    // (Esto antes lo hacía el showModalBottomSheet)
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor, // Color de fondo (ej. Colors.white)
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
          // --- 3. CONECTA EL SCROLL CONTROLLER ---
          child: SingleChildScrollView(
            controller: widget.scrollController, // <-- ¡CONECTADO!
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 4. AÑADE EL "AGARRADOR" Y TÍTULO ---
                // (Como en tu plantilla)
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // (Usa tu AppColors.border si prefieres)
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'Añadir Nuevo Producto',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),

                // --- 5. EL RESTO DE TU FORMULARIO ---
                // (Pega aquí el resto de tu formulario:
                // InkWell(_buildImagePreview), TextFormField, Row, ElevatedButton, etc.)
                
                // Ejemplo:
                InkWell(
                  onTap: _pickImage,
                  child: _buildImagePreview(), // (Asegúrate de tener esta función)
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                ),
                SizedBox(height: 10),
                // ... (etc.) ...
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitData, // (Asegúrate de tener _submitData)
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Producto'),
                ),
                SizedBox(height: 20), // Espacio al final para que no quede pegado
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // *** NO OLVIDES PEGAR TUS FUNCIONES DE AYUDA AQUÍ ***
  // (Ej. _pickImage, _buildImagePreview, _submitData)
  
  // (Función de ejemplo, ¡asegúrate de tener la tuya!)
  Future<void> _pickImage() async { /* ... */ }
  Widget _buildImagePreview() { /* ... */ return Container(); }
  Future<void> _submitData() async { /* ... */ }
}