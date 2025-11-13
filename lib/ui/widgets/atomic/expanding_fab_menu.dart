import 'package:flutter/material.dart';
import 'dart:math' as math; // Para la rotación del icono

/// Un widget de menú FAB expandible.
/// Muestra un FAB principal que, al tocarlo, revela
/// un conjunto de FABs secundarios más pequeños en una animación.
class ExpandingFabMenu extends StatefulWidget {
  final List<Widget> children;
  final double distance;
  final IconData mainIcon;

  const ExpandingFabMenu({
    Key? key,
    required this.children,
    this.distance = 100.0, // Distancia vertical entre botones
    this.mainIcon = Icons.add,
  }) : super(key: key);

  @override
  _ExpandingFabMenuState createState() => _ExpandingFabMenuState();
}

class _ExpandingFabMenuState extends State<ExpandingFabMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // Duración de la animación
    );

    // Usamos un CurvedAnimation para un efecto más suave
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Stack para apilar los botones uno encima del otro.
    // El último hijo en la lista del Stack es el que queda arriba.
    return Stack(
      alignment: Alignment.bottomRight,
      // clipBehavior.none permite que los hijos (los mini-FABs)
      // se dibujen fuera de los límites del Stack.
      clipBehavior: Clip.none,
      children: [
        // --- Los Mini-FABs ---
        // Mapeamos los widgets hijos y los इnimamos
        ..._buildExpandingActionButtons(),

        // --- El FAB Principal ---
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animation,
          ),
          // Versión alternativa con rotación:
          // child: RotationTransition(
          //   turns: Tween(begin: 0.0, end: 0.125).animate(_animation), // Rota 45 grados
          //   child: Icon(_isExpanded ? Icons.close : widget.mainIcon),
          // ),
        ),
      ],
    );
  }

  /// Construye la lista de mini-FABs animados
  List<Widget> _buildExpandingActionButtons() {
    final List<Widget> children = [];
    final count = widget.children.length;
    // Distancia vertical base para cada botón
    final double step = widget.distance / ((count - 1).isNegative ? 1 : count);

    for (int i = 0; i < count; i++) {
      // Calculamos la distancia vertical para este botón específico
      final double translation = (count - i) * step;

      children.add(
        // AnimatedBuilder es la forma eficiente de animar
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              // Animamos la posición vertical
              offset: Offset(0.0, -_animation.value * translation),
              child: child,
            );
          },
          child: FadeTransition(
            // Animamos la opacidad
            opacity: _animation,
            child: widget.children[i],
          ),
        ),
      );
    }
    return children;
  }
}
