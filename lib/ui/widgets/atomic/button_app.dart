import 'package:flutter/material.dart';

class PrimaryButtonApp extends StatelessWidget {
  
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final double maxWidth;

  const PrimaryButtonApp({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.maxWidth = 250,
  });

  @override
  Widget build(BuildContext context) {
    // Determina el tamaño del ícono para que el spinner lo iguale
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ElevatedButton.icon(
          
          // --- AQUÍ ESTÁ EL CAMBIO ---
          icon: isLoading 
            ? SizedBox( // 1. El spinner AHORA es el ícono
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                  strokeWidth: 3,
                ),
              )
            : Icon(icon ?? Icons.save), // 2. El ícono normal

          label: Text( // 3. El texto SIEMPRE se muestra
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          // --- FIN DEL CAMBIO ---
            
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(64, 50), 
          ),
          
          onPressed: isLoading ? null : onPressed, 
        ),
      ),
    );
  }
}