import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart'; // Asumo esta ruta

class SearchTextFieldApp extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;

  const SearchTextFieldApp({
    super.key,
    this.onChanged,
    required this.labelText,
    this.hintText,
    this.prefixIcon = Icons.search, // Icono de búsqueda por defecto
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 15.0, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText, // Usa el parámetro
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 20), // Usa el parámetro
        labelStyle: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 3.0, color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 3.0, color: AppColors.textSecondary),
        ),
        // Tu padding original era 'vertical: 0'
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      // 1. Simplemente notifica al padre del cambio
      onChanged: onChanged,
    );
  }
}
