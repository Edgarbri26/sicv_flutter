// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
//   final notifier = ThemeNotifier();
//   notifier.loadTheme();
//   return notifier;
// });

// class ThemeNotifier extends StateNotifier<ThemeMode> {
//   static const _themeKey = 'theme_mode';

//   ThemeNotifier() : super(ThemeMode.system);

//   Future<void> loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     // if (!mounted) return; // Removed as it causes issues and is less critical here
//     final themeString = prefs.getString(_themeKey);
//     if (themeString == 'dark') {
//       state = ThemeMode.dark;
//     } else if (themeString == 'light') {
//       state = ThemeMode.light;
//     } else {
//       state = ThemeMode.system;
//     }
//   }

//   Future<void> toggleTheme(bool isDark) async {
//     state = isDark ? ThemeMode.dark : ThemeMode.light;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
//   }
// }
