import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF795548),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F3ED),
    );
  }
}
