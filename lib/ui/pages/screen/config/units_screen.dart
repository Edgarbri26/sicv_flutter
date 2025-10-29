import 'package:flutter/material.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  _UnitsScreenState createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  final List<String> _unidades = ['Pieza', 'Kg', 'Litro', 'Metro', 'Caja'];

  void _agregarUnidad() {
    print('TODO: Mostrar diálogo para agregar unidad');
  }

  void _editarUnidad(int index) {
    print('TODO: Editar ${_unidades[index]}');
  }

  void _eliminarUnidad(int index) {
    print('TODO: Eliminar ${_unidades[index]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades de Medida')),
      body: ListView.builder(
        itemCount: _unidades.length,
        itemBuilder: (context, index) {
          final unidad = _unidades[index];
          return ListTile(
            title: Text(unidad),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarUnidad(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarUnidad(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarUnidad,
        tooltip: 'Agregar Unidad',
        child: const Icon(Icons.add),
      ),
    );
  }
}
