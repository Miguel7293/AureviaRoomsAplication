import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  static ThemeData get lightModernTheme => ThemeData(
        primaryColor: const Color(0xFF4FC3F7), // Light blue
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFFFFFF), // White
          elevation: 2,
          titleTextStyle: const TextStyle(
            color: Color(0xFF333333), // Dark gray
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: null, // Default font
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF), // White
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFF4FC3F7).withOpacity(0.3), width: 1),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF333333), // Dark gray
            fontFamily: null, // Default font
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF333333), // Dark gray
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: null, // Default font
          ),
          labelSmall: TextStyle(
            color: Color(0xFF4FC3F7), // Light blue
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: null, // Default font
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFF4FC3F7).withOpacity(0.2)),
            foregroundColor: WidgetStateProperty.all(const Color(0xFF333333)),
            overlayColor: WidgetStateProperty.all(const Color(0xFF4FC3F7).withOpacity(0.3)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF4FC3F7), // Light blue
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF333333), // Dark gray
          size: 48,
        ),
      );
}