// lib/screens/add_product_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // IMPORTACIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sicv_flutter/services/product_api_service.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  XFile? _imageFile;
  Uint8List? _imageBytes; // Variable para guardar los bytes de la imagen en web
  final ImagePicker _picker = ImagePicker();
  final ProductApiService _apiService = ProductApiService();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = pickedFile;
      
      // Lógica condicional para la vista previa
      if (kIsWeb) {
        // En web, leemos los bytes para Image.memory
        _imageBytes = await pickedFile.readAsBytes();
      }
      
      setState(() {}); // Redibuja el widget para mostrar la vista previa
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile == null) {
      return const Center(child: Text('Ninguna imagen seleccionada.'));
    }

    // MANEJO PARA WEB Y MÓVIL
    if (kIsWeb) {
      // En web, usa Image.memory porque File() no está disponible
      return Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity);
    } else {
      // En móvil, usa Image.file
      return Image.file(File(_imageFile!.path), fit: BoxFit.cover, width: double.infinity);
    }
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos y selecciona una imagen.')),
      );
      return;
    }

    // Muestra un indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _apiService.createProduct(
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      imageFile: _imageFile!,
    );
    
    Navigator.of(context).pop(); // Cierra el indicador de carga

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Producto enviado!')),
    );
  }

  String? _nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'El usuario no puede estar vacío';
    if (v.trim().length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña no puede estar vacía';
    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue.shade700;
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Producto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Producto')),
            TextFormField(
                        controller: _nameController,
                        validator: _nameValidator,
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person, color: primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
            const SizedBox(height: 10),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 10),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _buildImagePreview(),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Seleccionar Imagen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Guardar Producto'),
            ),
          ],
        ),
      ),
    );
  }
}