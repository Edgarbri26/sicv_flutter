import 'package:flutter/material.dart';

enum ButtonType { primary, secondary }

class ButtonApp extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final double maxWidth;
  final ButtonType type;
  final bool fullWidth;

  const ButtonApp({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.maxWidth = 250,
    this.type = ButtonType.primary,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determina el tamaño del ícono para que el spinner lo iguale
    final iconSize = Theme.of(context).iconTheme.size ?? 24.0;

    final button = ElevatedButton.icon(
      icon: isLoading
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 3,
              ),
            )
          : Icon(icon ?? Icons.save),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.8),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: type == ButtonType.primary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: type == ButtonType.primary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: type == ButtonType.secondary
            ? BorderSide(color: Theme.of(context).colorScheme.primary)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(64, 50),
      ),
      onPressed: isLoading ? null : onPressed,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: button,
      ),
    );
  }
}
