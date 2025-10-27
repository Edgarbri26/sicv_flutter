import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sicv_flutter/services/product_api_service.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  final ProductApiService _apiService = ProductApiService();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = pickedFile;
      if (kIsWeb) {
        _imageBytes = await pickedFile.readAsBytes();
      }
      setState(() {});
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile == null) {
      return const Center(child: Text('Ninguna imagen seleccionada.'));
    }
    if (kIsWeb) {
      return Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity);
    } else {
      return Image.file(File(_imageFile!.path), fit: BoxFit.cover, width: double.infinity);
    }
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _stockController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos y selecciona una imagen.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // parse stock
    int stock;
    try {
      stock = int.parse(_stockController.text);
      if (stock < 0) throw FormatException('stock negativo');
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser un número entero válido.')),
      );
      return;
    }

    // actual call
    await _apiService.createProduct(
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      stock: stock,
      imageFile: _imageFile!,
    );

    Navigator.of(context).pop(); // close loader

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Producto enviado!')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre del Producto')),
          const SizedBox(height: 8),
          TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
          const SizedBox(height: 8),
          TextField(controller: _stockController, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.hardEdge,
            child: _buildImagePreview(),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Seleccionar Imagen'),
            style: ElevatedButton.styleFrom(backgroundColor: primary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Guardar Producto'),
          ),
        ],
      ),
    );
  }
}
