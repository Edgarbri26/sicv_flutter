import 'package:flutter/material.dart';

class AttributesScreen extends StatelessWidget {
  const AttributesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Atributos y Campos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Atributos (Variantes)', icon: Icon(Icons.style)),
              Tab(text: 'Campos Personalizados', icon: Icon(Icons.text_fields)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GestionListaWidget(
              tipo: 'Atributo',
              items: ['Talla', 'Color', 'Material'],
              icono: Icons.style,
            ),

            GestionListaWidget(
              tipo: 'Campo Personalizado',
              items: ['N° de Serie', 'Fecha de Vencimiento'],
              icono: Icons.text_fields,
            ),
          ],
        ),
      ),
    );
  }
}

class GestionListaWidget extends StatelessWidget {
  final String tipo;
  final List<String> items;
  final IconData icono;

  const GestionListaWidget({
    Key? key,
    required this.tipo,
    required this.items,
    required this.icono,
  }) : super(key: key);

  void _agregarItem(BuildContext context) {
    print('TODO: Agregar $tipo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(icono),
            title: Text(items[index]),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _agregarItem(context),
        child: const Icon(Icons.add),
        tooltip: 'Agregar $tipo',
      ),
    );
  }
}
