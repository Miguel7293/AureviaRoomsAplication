import 'package:flutter/material.dart';

class AppTheme {
  // Define tus colores de marca una sola vez aquí
  static const Color primaryBlue = Color(0xFF2A3A5B); // Azul oscuro del logo
  static const Color accentGold = Color(0xFFD4AF37); // Dorado/Mostaza del logo
  static const Color darkGray = Color(0xFF333333); // Gris oscuro
  static const Color lightBlue = Color(0xFF4FC3F7); // Azul claro de lightModernTheme

  // Tema Claro (Basado en tu lightModernTheme)
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light, // Indica que es un tema claro
        primaryColor: primaryBlue, // Usamos el azul oscuro como color principal
        hintColor: accentGold, // Usamos el dorado como color de acento
        scaffoldBackgroundColor: Colors.grey[100], // Un gris claro para el fondo del Scaffold
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Fondo blanco para AppBar
          foregroundColor: primaryBlue, // Texto e iconos en azul oscuro
          elevation: 2,
          titleTextStyle: TextStyle(
            color: darkGray, // Color del texto del título de la AppBar
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white, // Fondo blanco para las tarjetas
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: lightBlue.withOpacity(0.3), width: 1),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkGray), // Texto general oscuro
          bodyMedium: TextStyle(color: darkGray, fontSize: 16), // Texto general oscuro
          titleLarge: TextStyle(
            color: darkGray, // Títulos grandes oscuros
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          titleMedium: TextStyle(color: primaryBlue), // Títulos y subtítulos con color principal
          bodySmall: TextStyle(color: Colors.grey), // Texto pequeño o secundario
          labelSmall: TextStyle(
            color: lightBlue, // Etiquetas en azul claro
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(primaryBlue), // Botones con color principal
            foregroundColor: WidgetStateProperty.all(Colors.white), // Texto de botón blanco
            overlayColor: WidgetStateProperty.all(accentGold.withOpacity(0.3)), // Efecto de pulsación dorado
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accentGold, // Dorado para indicadores de progreso
        ),
        iconTheme: const IconThemeData(
          color: primaryBlue, // Iconos en color principal
          size: 24, // Tamaño de icono por defecto, ajusta según necesites
        ),
        listTileTheme: ListTileThemeData(
          iconColor: primaryBlue, // Iconos en ListTile con color principal
          textColor: darkGray, // Texto en ListTile con gris oscuro
        ),
        dividerColor: Colors.grey[300], // Color de los divisores
        shadowColor: Colors.grey, // Color para las sombras
        // Elimina scaffoldBackgroundColor: Colors.transparent, si no es estrictamente necesario,
        // ya que puede dificultar la visualización de fondos en temas.
        // Si lo necesitas, asegúrate de que tus widgets tengan un color de fondo explícito.
      );

  // Tema Oscuro (Copia y adapta el lightTheme)
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark, // Indica que es un tema oscuro
        primaryColor: primaryBlue, // Puede que quieras mantener el azul oscuro o cambiarlo a uno más claro para el modo oscuro
        hintColor: accentGold, // Mismo color de acento
        scaffoldBackgroundColor: const Color(0xFF1A2A4A), // Fondo azul muy oscuro
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A3A5B), // Un azul oscuro para la AppBar
          foregroundColor: Colors.white, // Texto e iconos blancos
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white, // Texto del título blanco
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A3A5B), // Un azul oscuro para las tarjetas
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.blueGrey[700]!.withOpacity(0.3), width: 1), // Borde más oscuro
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70), // Texto general más claro
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16), // Texto general más claro
          titleLarge: TextStyle(
            color: Colors.white, // Títulos grandes blancos
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          titleMedium: TextStyle(color: accentGold), // Títulos y subtítulos en dorado para contraste
          bodySmall: TextStyle(color: Colors.grey), // Texto pequeño o secundario
          labelSmall: TextStyle(
            color: accentGold, // Etiquetas en dorado
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(accentGold), // Botones con color de acento
            foregroundColor: WidgetStateProperty.all(Colors.black), // Texto de botón negro
            overlayColor: WidgetStateProperty.all(primaryBlue.withOpacity(0.3)), // Efecto de pulsación azul
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accentGold, // Dorado para indicadores de progreso
        ),
        iconTheme: const IconThemeData(
          color: accentGold, // Iconos en dorado para contraste
          size: 24,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: accentGold, // Iconos en ListTile con dorado
          textColor: Colors.white70, // Texto en ListTile más claro
        ),
        dividerColor: Colors.blueGrey[700], // Divisores más oscuros
        shadowColor: Colors.black, // Sombras más oscuras
      );
}