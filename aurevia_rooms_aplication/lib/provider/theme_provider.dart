import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // El tema inicial es claro

  ThemeMode get themeMode => _themeMode; // Getter para obtener el modo actual

  bool get isDarkMode => _themeMode == ThemeMode.dark; // Comprueba si el modo actual es oscuro

  // Método para alternar entre modo claro y oscuro
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifica a los oyentes (widgets) que el tema ha cambiado
  }
}

// Clase que define los temas de tu aplicación
class AppThemes {
  // Define tus colores principales una sola vez
  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  // Tema Claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light, // Indicador de brillo para el tema
    primaryColor: primaryBlue, // Color principal (azul oscuro)
    hintColor: accentGold, // Color de acento (dorado)
    scaffoldBackgroundColor: Colors.grey[100], // Color de fondo del Scaffold
    cardColor: Colors.white, // Color de las tarjetas
    dividerColor: Colors.grey[300], // Color de los divisores
    shadowColor: Colors.grey, // Color para las sombras (ajustado para que sea visible pero no intrusivo)

    // Configuración para la AppBar en modo claro
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // Fondo blanco para AppBar
      foregroundColor: primaryBlue, // Color del texto/iconos en AppBar (azul oscuro)
      elevation: 0, // Sin sombra en AppBar
    ),

    // Configuración para los estilos de texto en modo claro
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87), // Texto general oscuro
      bodyMedium: TextStyle(color: Colors.black87), // Texto general oscuro
      titleMedium: TextStyle(color: primaryBlue), // Títulos y subtítulos con color principal
      titleLarge: TextStyle(color: Colors.black), // Títulos grandes con color negro
      bodySmall: TextStyle(color: Colors.grey), // Texto pequeño o secundario
    ),

    // Configuración para las tarjetas
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Configuración para los ListTile
    listTileTheme: ListTileThemeData(
      iconColor: primaryBlue, // Color de los iconos en ListTile
      textColor: Colors.black87, // Color del texto en ListTile
    ),

    // Configuración para los botones elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Color del texto del botón (blanco)
        backgroundColor: primaryBlue, // Color de fondo del botón (azul oscuro)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Configuración para el Switch (interruptor)
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentGold; // Dorado cuando está activo
        }
        return Colors.grey; // Gris cuando está inactivo
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentGold.withOpacity(0.5); // Pista dorada con opacidad cuando está activo
        }
        return Colors.grey.withOpacity(0.5); // Pista gris con opacidad cuando está inactivo
      }),
    ),
  );

  // Tema Oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // Indicador de brillo para el tema
    primaryColor: primaryBlue, // Mantener el mismo azul principal o ajustar si es necesario
    hintColor: accentGold, // Color de acento (dorado)
    scaffoldBackgroundColor: const Color(0xFF1A2A4A), // Fondo azul muy oscuro para Scaffold
    cardColor: const Color(0xFF2A3A5B), // Color de las tarjetas en modo oscuro (azul oscuro)
    dividerColor: Colors.blueGrey[700], // Color de los divisores en modo oscuro
    shadowColor: Colors.black, // Color para las sombras en modo oscuro

    // Configuración para la AppBar en modo oscuro
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2A3A5B), // Fondo azul oscuro para AppBar
      foregroundColor: Colors.white, // Color del texto/iconos en AppBar (blanco)
      elevation: 0,
    ),

    // Configuración para los estilos de texto en modo oscuro
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70), // Texto general claro
      bodyMedium: TextStyle(color: Colors.white70), // Texto general claro
      titleMedium: TextStyle(color: Colors.white), // Títulos y subtítulos con color blanco
      titleLarge: TextStyle(color: Colors.white), // Títulos grandes con color blanco
      bodySmall: TextStyle(color: Colors.grey), // Texto pequeño o secundario
    ),

    // Configuración para las tarjetas en modo oscuro
    cardTheme: CardThemeData(
      color: const Color(0xFF2A3A5B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Configuración para los ListTile en modo oscuro
    listTileTheme: ListTileThemeData(
      iconColor: accentGold, // Iconos en dorado para contraste
      textColor: Colors.white70, // Texto claro en ListTile
    ),

    // Configuración para los botones elevados en modo oscuro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, // Color del texto del botón (negro)
        backgroundColor: accentGold, // Color de fondo del botón (dorado)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Configuración para el Switch (interruptor) en modo oscuro
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentGold; // Dorado cuando está activo
        }
        return Colors.grey[700]; // Gris oscuro cuando está inactivo
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accentGold.withOpacity(0.5); // Pista dorada con opacidad cuando está activo
        }
        return Colors.grey[700]?.withOpacity(0.5); // Pista gris oscuro con opacidad cuando está inactivo
      }),
    ),
  );
}