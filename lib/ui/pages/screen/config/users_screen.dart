import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<Map<String, String>> _usuarios = [
    {
      'nombre': 'Admin User',
      'email': 'admin@email.com',
      'rol': 'Administrador',
    },
    {'nombre': 'Juan Vendedor', 'email': 'juan@email.com', 'rol': 'Vendedor'},
  ];

  void _agregarUsuario() {
    print('TODO: Abrir pantalla para agregar nuevo usuario');
  }

  void _editarUsuario(int index) {
    print('TODO: Editar usuario ${_usuarios[index]['email']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios del Sistema')),
      body: ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final user = _usuarios[index];
          return ListTile(
            leading: CircleAvatar(child: Text(user['nombre']![0])),
            title: Text(user['nombre']!),
            subtitle: Text('${user['email']} - ${user['rol']}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editarUsuario(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarUsuario,
        tooltip: 'Agregar Usuario',
        child: const Icon(Icons.add),
      ),
    );
  }
}
