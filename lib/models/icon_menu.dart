import 'package:flutter/material.dart';

class MenuItemData {
  final IconData icon;
  final IconData? iconActive;
  final String label;
  final int index;
  
  MenuItemData({
    required this.icon,
    this.iconActive,
    required this.label,
    required this.index,
  });
}
