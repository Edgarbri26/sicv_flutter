import 'package:flutter/material.dart';

// (Asegúrate de tener las pantallas de ejemplo: ChatsScreen, StatusScreen, CallsScreen)

class WhatsappHome extends StatefulWidget {
  const WhatsappHome({Key? key}) : super(key: key);

  @override
  _WhatsappHomeState createState() => _WhatsappHomeState();
}

// Ya NO necesitamos 'SingleTickerProviderStateMixin'
class _WhatsappHomeState extends State<WhatsappHome> {
  
  // Reemplazamos TabController por PageController
  late PageController _pageController;
  int _currentIndex = 0;

  // Las pantallas que vamos a mostrar
  final List<Widget> _screens = [
    ChatsScreen(),
    StatusScreen(),
    CallsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Inicializamos el PageController
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // Liberamos el PageController
    _pageController.dispose();
    super.dispose();
  }

  /// Callback para cuando el usuario TOCA un ítem de la barra inferior
  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Animamos el PageView para que coincida con el toque
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Callback para cuando el usuario DESLIZA el PageView
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WhatsApp',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF075E54),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
        // Ya no tenemos el 'bottom' (TabBar)
      ),
      
      // El 'body' ahora es un PageView
      body: PageView(
        controller: _pageController,
        // Este callback se dispara cuando el deslizamiento se completa
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      
      // Añadimos la barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        // Le decimos qué ítem está activo
        currentIndex: _currentIndex,
        // Callback para cuando se toca un ítem
        onTap: _onBottomNavTapped,
        // Estilo de la barra (colores de WhatsApp)
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF075E54),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed, // Muestra todos los labels
        
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),

      // La lógica del FAB sigue intacta y funciona perfectamente
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Este método no necesita cambios, ya que depende de _currentIndex.
  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Pestaña CHATS
        return FloatingActionButton(
          onPressed: () { /* Lógica para nuevo chat */ },
          backgroundColor: Color(0xFF25D366),
          child: Icon(Icons.chat, color: Colors.white),
        );
      case 1: // Pestaña STATUS
        return FloatingActionButton(
          onPressed: () { /* Lógica para nuevo estado */ },
          backgroundColor: Color(0xFF25D366),
          child: Icon(Icons.camera_alt, color: Colors.white),
        );
      case 2: // Pestaña CALLS
        return FloatingActionButton(
          onPressed: () { /* Lógica para nueva llamada */ },
          backgroundColor: Color(0xFF25D366),
          child: Icon(Icons.add_ic_call, color: Colors.white),
        );
      default:
        return null;
    }
  }
}

// --- Pantallas Modulares (Widgets de ejemplo) ---

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Lista de Chats',
        style: TextStyle(fontSize: 24, color: Colors.grey[600]),
      ),
    );
  }
}

class StatusScreen extends StatelessWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Lista de Estados',
        style: TextStyle(fontSize: 24, color: Colors.grey[600]),
      ),
    );
  }
}

class CallsScreen extends StatelessWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Lista de Llamadas',
        style: TextStyle(fontSize: 24, color: Colors.grey[600]),
      ),
    );
  }
}