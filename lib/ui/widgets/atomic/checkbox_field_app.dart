import 'package:flutter/material.dart';
// Asegúrate de que esta ruta sea correcta para tu proyecto
import 'package:sicv_flutter/core/theme/app_colors.dart'; 

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
        ? AppColors.textSecondary
        : AppColors.textSecondary.withOpacity(0.5);
        
    final Color borderColor = enabled 
        ? AppColors.border 
        : AppColors.border.withOpacity(0.5);

    // Usamos InkWell para que todo el campo sea tappable
    return InkWell(
      // --- 1. Comportamiento de Tap ---
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // --- 2. Padding (idéntico a TextFieldApp) ---
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        // --- 3. Decoración (idéntica a TextFieldApp) ---
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 3.0,
            color: borderColor,
          ),
        ),
        // --- 4. Contenido (Título y Checkbox) ---
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- 5. Título (estilo de label de TextFieldApp) ---
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                color: textColor,
              ),
            ),
            
            // --- 6. El Checkbox ---
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              
              // Estilos para que combine
              activeColor: AppColors.textSecondary, // Color cuando está marcado
              checkColor: AppColors.secondary,     // Color del "check" (palomita)
              
              // Color del fondo del checkbox
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.border.withOpacity(0.3);
                }
                if (states.contains(WidgetState.selected)) {
                  return AppColors.textSecondary; // Marcado
                }
                return AppColors.border; // No marcado
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