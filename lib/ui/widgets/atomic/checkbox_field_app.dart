import 'package:flutter/material.dart';

class CheckboxFieldApp extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool enabled;

  const CheckboxFieldApp({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // --- Define los colores basados en el estado 'enabled' ---
    final Color textColor = enabled
        ? Theme.of(context).inputDecorationTheme.labelStyle?.color ??
              Theme.of(context).textTheme.bodyMedium!.color!
        : Theme.of(context).disabledColor;

    final Color borderColor = enabled
        ? Theme.of(context).inputDecorationTheme.enabledBorder!.borderSide.color
        : Theme.of(context).disabledColor.withValues(alpha: 0.5);

    // Usamos InkWell para que todo el campo sea tappable
    return InkWell(
      // --- 1. Comportamiento de Tap ---
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // --- 2. Padding (idéntico a TextFieldApp) ---
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        // --- 3. Decoración (idéntica a TextFieldApp) ---
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 3.0, color: borderColor),
        ),
        // --- 4. Contenido (Título y Checkbox) ---
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- 5. Título (estilo de label de TextFieldApp) ---
            Text(title, style: TextStyle(fontSize: 16.0, color: textColor)),

            // --- 6. El Checkbox ---
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,

              // Estilos para que combine
              activeColor: Theme.of(
                context,
              ).colorScheme.primary, // Color cuando está marcado
              checkColor: Theme.of(
                context,
              ).colorScheme.onPrimary, // Color del "check"
              // Color del fondo del checkbox
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Theme.of(context).disabledColor.withValues(alpha: 0.3);
                }
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary; // Marcado
                }
                return Theme.of(context).unselectedWidgetColor; // No marcado
              }),
              // Ocultamos el borde por defecto del checkbox
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }
}
