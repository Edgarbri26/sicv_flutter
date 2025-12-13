import 'package:flutter/material.dart';
import 'package:sicv_flutter/ui/widgets/atomic/app_bar_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/button_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/search_text_field_app.dart';
import 'package:sicv_flutter/ui/widgets/atomic/text_field_app.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  _UnitsScreenState createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  final List<String> _unidades = ['Pieza', 'Kg', 'Litro', 'Metro', 'Caja'];
  final List<String> _unidadesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _abreviaturaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  bool _mostrarResultadosBusqueda = false;

  @override
  void initState() {
    super.initState();
    _unidadesFiltradas.addAll(_unidades);
  }

  void _filtrarUnidades(String query) {
    setState(() {
      _mostrarResultadosBusqueda = query.isNotEmpty;
      _unidadesFiltradas.clear();
      if (query.isEmpty) {
        _unidadesFiltradas.addAll(_unidades);
      } else {
        _unidadesFiltradas.addAll(
          _unidades.where(
            (unidad) => unidad.toLowerCase().contains(query.toLowerCase()),
          ),
        );
      }
    });
  }

  void _mostrarModalAgregarUnidad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModalAgregarUnidad(),
    );
  }

  Widget _buildModalAgregarUnidad() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
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
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Agregar Unidad de Medida',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Completa los datos de la nueva unidad de medida',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextFieldApp(
              controller: _nombreController,
              labelText: 'Nombre de la unidad *',
              prefixIcon: Icons.straighten,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFieldApp(
              controller: _abreviaturaController,
              labelText: 'Abreviatura *',
              prefixIcon: Icons.short_text,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextFieldApp(
              controller: _descripcionController,
              labelText: 'Descripción (opcional)',
              prefixIcon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _limpiarFormulario();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ButtonApp(
                    text: 'Guardar',
                    icon: Icons.save,
                    onPressed: _guardarUnidad,
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

  void _guardarUnidad() {
    final nombre = _nombreController.text.trim();
    final abreviatura = _abreviaturaController.text.trim();

    if (nombre.isEmpty || abreviatura.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, completa los campos obligatorios'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _unidades.add(nombre);
      if (!_mostrarResultadosBusqueda) {
        _unidadesFiltradas.add(nombre);
      }
    });

    Navigator.of(context).pop();
    _limpiarFormulario();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unidad "$nombre" agregada correctamente'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _abreviaturaController.clear();
    _descripcionController.clear();
  }

  void _editarUnidad(int index) {
    final unidad = _mostrarResultadosBusqueda
        ? _unidadesFiltradas[index]
        : _unidades[index];
    debugPrint('TODO: Editar $unidad');
  }

  void _eliminarUnidad(int index) {
    final unidad = _mostrarResultadosBusqueda
        ? _unidadesFiltradas[index]
        : _unidades[index];
    debugPrint('TODO: Eliminar $unidad');
  }

  @override
  Widget build(BuildContext context) {
    final listaMostrar = _mostrarResultadosBusqueda
        ? _unidadesFiltradas
        : _unidades;

    return Scaffold(
      appBar: const AppBarApp(
        title: 'Unidades de Medida',
        iconColor: Colors.black,
        toolbarHeight: 64.0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchTextFieldApp(
              controller: _searchController,
              labelText: 'Buscar unidad...',
              hintText: 'Escribe el nombre de la unidad',
              prefixIcon: Icons.search,
              onChanged: _filtrarUnidades,
            ),
          ),

          if (_mostrarResultadosBusqueda)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_unidadesFiltradas.length} resultado${_unidadesFiltradas.length != 1 ? 's' : ''} encontrado${_unidadesFiltradas.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _filtrarUnidades('');
                    },
                    child: const Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: listaMostrar.length,
              itemBuilder: (context, index) {
                final unidad = listaMostrar[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.straighten,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      unidad,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          onPressed: () => _editarUnidad(index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _eliminarUnidad(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarModalAgregarUnidad,
        tooltip: 'Agregar Unidad',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
