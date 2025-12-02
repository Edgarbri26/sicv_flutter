import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart'; // Asumo esta ruta

class TextFieldApp extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final String labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // Añadido para más flexibilidad (ej. contraseñas)
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final VoidCallback? onTap;
  final bool? readOnly;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const TextFieldApp({
    this.onFieldSubmitted,
    super.key,
    required this.controller,
    this.textInputAction,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.obscureText = false, // Añadido para contraseñas
    this.enabled = true,
    this.validator,
    this.textCapitalization = TextCapitalization.sentences,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      onTap: onTap,
      readOnly: readOnly ?? false,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15.0,
        color: AppColors.textPrimary, // Estilo del texto que escribes
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
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
    );
  }
}
