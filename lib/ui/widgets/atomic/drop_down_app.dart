import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

// 1. 'T' fue reemplazado por 'ItemType' para más claridad
class DropDownApp<ItemType> extends StatelessWidget {
  // 2. Usamos 'ItemType' para el valor, la lista y el onChanged
  final ItemType? initialValue;
  final List<ItemType> items;
  final ValueChanged<ItemType?>? onChanged;
  final FocusNode? focusNode;

  // 3. Esta función recibe un 'ItemType' y devuelve el String a mostrar
  final String Function(ItemType item) itemToString;

  final String labelText;
  final String? hintText;
  final String? Function(ItemType? item)? validator;
  final IconData? prefixIcon;

  const DropDownApp({
    super.key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    required this.itemToString,
    required this.labelText,
    this.focusNode,
    this.prefixIcon,
    this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // 4. El Dropdown es de tipo 'ItemType'
    return DropdownButtonFormField<ItemType>(
      focusNode: focusNode,
      dropdownColor: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(Icons.keyboard_arrow_down_rounded),
      iconSize: 24,
      menuMaxHeight: 500.0,
      isExpanded: true,
      decoration: InputDecoration(
        labelStyle: const TextStyle(
          fontSize: 16.0,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 3.0,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
      ),

      initialValue: initialValue,

      // 5. Mapeamos la lista de 'ItemType'
      items: items.map((ItemType item) {
        // 6. El DropdownMenuItem también es de tipo 'ItemType'
        return DropdownMenuItem<ItemType>(
          value: item,
          child: Text(
            // 7. Usamos la función para convertir el 'ItemType' a String
            itemToString(item),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),

      onChanged: onChanged,
      validator: validator,
    );
  }
}
