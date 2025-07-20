// archivo: app.dart
// ignore_for_file: cast_from_null_always_fails

import 'package:aureviarooms/trash/checking_booking_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/core/theme/app_theme.dart';
import 'package:aureviarooms/presentation/navigation/owner_nav_bar.dart';
import 'package:aureviarooms/presentation/navigation/user_nav_bar.dart';
import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/presentation/screens/splash_screen.dart'; // <--- Importa tu nuevo SplashScreen


// Wrapper para la lógica de selección de navegación
class UserTypeGate extends StatelessWidget {
  const UserTypeGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Si todavía estamos inicializando (comprobando la sesión y cargando el UserModel)
    if (authProvider.isInitializingAuth) {
      return const SplashScreen(); // <--- Muestra tu SplashScreen con animación
    }

    // Una vez que la inicialización ha terminado:
    // Si no está autenticado, siempre va a la pantalla de login
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Si está autenticado pero el userType aún es null (indicando un posible error
    // en la carga del UserModel a pesar de la inicialización),
    // podrías mostrar un error o redirigir al login.
    if (authProvider.userType == null) {
      debugPrint('Error: Usuario autenticado pero tipo de usuario es nulo. Redirigiendo al login.');
      return const LoginScreen(); // O una pantalla de error más descriptiva
    }

    // Si está autenticado y el tipo de usuario está disponible
    switch (authProvider.userType) {
      case 'admin':
        return const OwnerNavBar();
      case 'guest':
        return const UserNavBar();
      default:
        debugPrint('Tipo de usuario desconocido: ${authProvider.userType}. Redirigiendo al login.');
        return const LoginScreen();
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
      home: const UserTypeGate(),
      routes: {
        '/booking-tests': (context) => const BookingTestScreen(), // Asumo que sigue siendo necesaria
        '/login': (context) => const LoginScreen(),
        '/owner-home': (context) => const OwnerNavBar(),
        '/user-home': (context) => const UserNavBar(),
      },
    );
  }
}