import 'package:flutter/material.dart';

class ColorStock {
    Color getColor(int stock, int minStock) {
    if (stock == 0) {
      return Colors.red.shade900;
    } else if (stock <= minStock) {
      return Colors.orange.shade900;
    } else {
      return Colors.green.shade800;
    }
  }
}