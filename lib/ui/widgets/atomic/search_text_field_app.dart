import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart'; // Asumo esta ruta

class SearchTextFieldApp extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final Function(String)? onSubmitted;
  final String labelText;
  final String? hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? Function(String?)? validator;

  const SearchTextFieldApp({
    super.key,
    this.onChanged,
    this.onSubmitted,
    required this.labelText,
    this.hintText,
    this.prefixIcon = Icons.search, // Icono de búsqueda por defecto
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      style: const TextStyle(fontSize: 15.0, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondary,
        labelText: labelText, // Usa el parámetro
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 20), // Usa el parámetro
        labelStyle: const TextStyle(
          fontSize: 14.0,
          color: AppColors.textSecondary,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 3.0, color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      // 1. Simplemente notifica al padre del cambio
      onChanged: onChanged,
    );
  }
}
