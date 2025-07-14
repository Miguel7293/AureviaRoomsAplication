// archivo: app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/core/theme/app_theme.dart';
import 'package:aureviarooms/presentation/navigation/owner_nav_bar.dart';
import 'package:aureviarooms/presentation/navigation/user_nav_bar.dart';
import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:aureviarooms/provider/auth_provider.dart';

// Asume que BookingTestScreen sigue en 'trash' o es una pantalla temporal
import 'package:aureviarooms/trash/checking_booking_repository.dart';


// Wrapper para la lógica de selección de navegación
class UserTypeGate extends StatelessWidget {
  const UserTypeGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Escucha los cambios en AuthProvider

    // Si no está autenticado, siempre va a la pantalla de login
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Si está autenticado, verifica el userType
    // Muestra un indicador de carga mientras se carga el userType
    if (authProvider.userType == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // O un logo, o pantalla de splash
        ),
      );
    }

    switch (authProvider.userType) {
      case 'admin':
        return const MainOwnerScreen(); // Si es admin, muestra la barra de navegación del Owner
      case 'guest':
        return const UserNavBar(); // Si es guest, muestra la barra de navegación del User
      default:
        // Caso por defecto si userType es null, indefinido, o algo inesperado
        debugPrint('Tipo de usuario desconocido: ${authProvider.userType}. Redirigiendo al login.');
        return const LoginScreen(); // Redirige al login si el tipo no es reconocido
    }
  }
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AureviaRooms',
      theme: AppTheme.lightTheme,
      home: const UserTypeGate(), // Ahora el 'home' siempre será el UserTypeGate
      routes: {
        '/booking-tests': (context) => const BookingTestScreen(),
        '/login': (context) => const LoginScreen(),
        '/owner-home': (context) => const MainOwnerScreen(),
        '/user-home': (context) => const UserNavBar(),
      },
    );
  }
}