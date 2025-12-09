import 'package:flutter/material.dart';

/// Represents a data model for a menu item in the application navigation.
class MenuItemData {
  /// The main icon displayed for the menu item.
  final IconData icon;

  /// The active state icon for the menu item (optional).
  final IconData? iconActive;

  /// The text label of the menu item.
  final String label;

  /// The index position of the menu item (used for navigation logic).
  final int index;

  /// Creates a new [MenuItemData].
  MenuItemData({
    required this.icon,
    this.iconActive,
    required this.label,
    required this.index,
  });
}
