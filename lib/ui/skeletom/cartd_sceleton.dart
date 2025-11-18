import 'package:flutter/material.dart';

// --- WIDGET PRINCIPAL DE ANIMACIÓN SHIMMER ---
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // 1. Inicializar el controlador para una animación repetitiva.
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(
        min: -0.5,
        max: 1.5,
        period: widget.duration,
      ); // Repetir el barrido
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // 2. Definir el degradado y cómo se mueve.
  LinearGradient get _shimmerGradient => const LinearGradient(
    colors: [
      Color(0xFFEBEBF4), // Color de base claro
      Color(0xFFF4F4F4), // Color de destello (blanco brillante)
      Color(0xFFEBEBF4), // Color de base claro
    ],
    stops: [
      0.1, // Punto inicial del destello
      0.3, // Punto central del destello
      0.4, // Punto final del destello
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  @override
  Widget build(BuildContext context) {
    // 3. AnimatedBuilder reconstruye el widget en cada tick de la animación.
    return AnimatedBuilder(
      animation: _shimmerController,
      child: widget.child,
      builder: (context, child) {
        // Mueve el degradado horizontalmente
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // El desplazamiento (offset) mueve el degradado.
            return _shimmerGradient.createShader(
              Rect.fromLTWH(
                _shimmerController.value *
                    bounds.width, // Controla el movimiento horizontal
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          child: child, // El esqueleto estático debajo del ShaderMask
        );
      },
    );
  }
}

// --- WIDGET DE ESQUELETO BASE (Modificado para usar el color de Shimmer) ---
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Usamos un color de fondo oscuro. El ShaderMask lo cubrirá con el Shimmer.
        color: Colors.grey.shade400,
        borderRadius: borderRadius,
      ),
    );
  }
}

// --- WIDGET QUE UNE LA ANIMACIÓN Y LA ESTRUCTURA ---
class CategoryLoadingSkeleton extends StatelessWidget {
  const CategoryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Envolvemos la estructura del esqueleto en el ShimmerEffect.
    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono/Avatar
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: SkeletonBox(
                width: 24.0,
                height: 24.0,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),

            const SizedBox(width: 12.0),

            // Contenido Principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Etiqueta
                  Row(
                    children: [
                      const SkeletonBox(width: 100.0, height: 16.0),
                      const SizedBox(width: 8.0),
                      const SkeletonBox(
                        width: 40.0,
                        height: 16.0,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),

                  // Descripción
                  const SkeletonBox(width: double.infinity, height: 12.0),
                  const SizedBox(height: 4.0),
                  const SkeletonBox(width: 250.0, height: 12.0),
                ],
              ),
            ),

            const SizedBox(width: 16.0),

            // Iconos de Acción
            Row(
              children: [
                const SkeletonBox(
                  width: 20.0,
                  height: 20.0,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                const SizedBox(width: 8.0),
                const SkeletonBox(
                  width: 20.0,
                  height: 20.0,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- EJEMPLO DE USO ---
class ShimmerExampleApp extends StatelessWidget {
  const ShimmerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Categoría Cargando (Shimmer)')),
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return const CategoryLoadingSkeleton();
          },
        ),
      ),
    );
  }
}

// Para ejecutar:
// void main() => runApp(const ShimmerExampleApp());

// import 'package:flutter/material.dart';

// // 1. Widget de Ayuda para simular la animación del esqueleto (Shimmer Effect)
// // En un proyecto real de Google, usaríamos un paquete como 'shimmer' o 
// // una implementación interna optimizada, pero para ser funcional y 
// // autocontenido, crearemos un contenedor con un color de fondo base.
// class SkeletonBox extends StatelessWidget {
//   final double width;
//   final double height;
//   final BorderRadiusGeometry borderRadius;

//   const SkeletonBox({
//     Key? key,
//     required this.width,
//     required this.height,
//     this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Usamos un color de fondo sutil que represente el estado "cargando".
//     // En una implementación avanzada, esto estaría dentro de un Widget 
//     // animado para un efecto de "barrido" o Shimmer.
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade300, // Color gris claro para el esqueleto
//         borderRadius: borderRadius,
//       ),
//     );
//   }
// }

// // 2. El Widget principal del Esqueleto que imita la estructura de la imagen
// class CategoryLoadingSkeleton extends StatelessWidget {
//   const CategoryLoadingSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Replicamos la estructura de un ListTile o un Row para mantener el layout.
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. Icono/Avatar del lado izquierdo
//           const Padding(
//             padding: EdgeInsets.only(top: 4.0),
//             child: SkeletonBox(
//               width: 24.0, // Tamaño similar al icono de la casa/carpeta
//               height: 24.0,
//               borderRadius: BorderRadius.all(Radius.circular(4.0)), // Forma cuadrada/rectangular
//             ),
//           ),
          
//           const SizedBox(width: 12.0),

//           // Contenido principal (Título y Descripción)
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Fila para el Título y la Etiqueta "Activo"
//                 Row(
//                   children: [
//                     // Título Principal ("Electrónicos")
//                     const SkeletonBox(width: 100.0, height: 16.0),
//                     const SizedBox(width: 8.0),
//                     // Etiqueta de Estado ("Activo")
//                     const SkeletonBox(
//                       width: 40.0, 
//                       height: 16.0,
//                       borderRadius: BorderRadius.all(Radius.circular(8.0)), // Forma de píldora
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 8.0),

//                 // Subtítulo/Descripción (Dos líneas simuladas)
//                 const SkeletonBox(width: double.infinity, height: 12.0), // Primera línea
//                 const SizedBox(height: 4.0),
//                 const SkeletonBox(width: 250.0, height: 12.0), // Segunda línea más corta
//               ],
//             ),
//           ),
          
//           const SizedBox(width: 16.0),

//           // Iconos de Acción del lado derecho
//           Row(
//             children: [
//               // Icono de Lápiz/Editar
//               const SkeletonBox(width: 20.0, height: 20.0, borderRadius: BorderRadius.all(Radius.circular(10.0))),
//               const SizedBox(width: 8.0),
//               // Icono de Prohibido/Eliminar
//               const SkeletonBox(width: 20.0, height: 20.0, borderRadius: BorderRadius.all(Radius.circular(10.0))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 3. Ejemplo de Uso para visualizar el Skeleton
// class SkeletonExample extends StatelessWidget {
//   const SkeletonExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Simulación de Carga')),
//       body: ListView.builder(
//         itemCount: 5, // Mostrar varios elementos de carga
//         itemBuilder: (context, index) {
//           // Aquí se usaría el widget de esqueleto
//           return const CategoryLoadingSkeleton();
//         },
//       ),
//     );
//   }
// }

// // NOTA IMPORTANTE: Para ver la animación "Shimmer" (el efecto de barrido de luz),
// // se necesita añadir un envoltorio animado a 'SkeletonBox'. 
// // Si estuviera en producción, recomendaría el paquete 'shimmer' para esto.