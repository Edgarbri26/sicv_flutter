import 'package:flutter/material.dart';

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
      style: TextStyle(
        fontSize: 15.0,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        labelText: labelText, // Usa el parámetro
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 20), // Usa el parámetro
        labelStyle: TextStyle(
          fontSize: 14.0,
          color:
              Theme.of(context).inputDecorationTheme.labelStyle?.color ??
              Theme.of(context).hintColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 3.0,
            color:
                Theme.of(
                  context,
                ).inputDecorationTheme.enabledBorder?.borderSide.color ??
                Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 3.0,
            color:
                Theme.of(
                  context,
                ).inputDecorationTheme.focusedBorder?.borderSide.color ??
                Theme.of(context).primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 3.0,
            color:
                Theme.of(
                  context,
                ).inputDecorationTheme.errorBorder?.borderSide.color ??
                Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 3.0,
            color:
                Theme.of(
                  context,
                ).inputDecorationTheme.errorBorder?.borderSide.color ??
                Theme.of(context).colorScheme.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      // 1. Simplemente notifica al padre del cambio
      onChanged: onChanged,
    );
  }
}
