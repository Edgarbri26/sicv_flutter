import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? item;
  const AddEditInventoryScreen({this.item});

  @override
  _AddEditInventoryScreenState createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _quantityController.text = widget.item!.quantity.toString();
      _priceController.text = widget.item!.price.toString();
      _categoryController.text = widget.item!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.item == null ? 'Agregar Item' : 'Editar Item'),
        backgroundColor: Color(0xFF128C7E),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _saveItem)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            _buildTextField(controller: _nameController, label: 'Nombre', icon: Icons.shopping_bag),
            SizedBox(height: 16),
            _buildTextField(controller: _descriptionController, label: 'Descripción', icon: Icons.description, maxLines: 3),
            SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextField(controller: _quantityController, label: 'Cantidad', icon: Icons.numbers, keyboardType: TextInputType.number)),
              SizedBox(width: 16),
              Expanded(child: _buildTextField(controller: _priceController, label: 'Precio', icon: Icons.attach_money, keyboardType: TextInputType.number)),
            ]),
            SizedBox(height: 16),
            _buildTextField(controller: _categoryController, label: 'Categoría', icon: Icons.category),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF128C7E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Este campo es requerido';
        return null;
      },
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = InventoryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        lastUpdated: DateTime.now(),
      );
      Navigator.pop(context, newItem);
    }
  }
}