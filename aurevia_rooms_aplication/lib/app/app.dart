// archivo: app.dart
// ignore_for_file: cast_from_null_always_fails

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/core/theme/app_theme.dart'; // Tu archivo de temas existente
import 'package:aureviarooms/presentation/navigation/owner_nav_bar.dart';
import 'package:aureviarooms/presentation/navigation/user_nav_bar.dart';
import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/presentation/screens/splash_screen.dart';
import 'package:aureviarooms/presentation/screens/sign/choosing_role_screen.dart';
import 'package:aureviarooms/presentation/screens/sign/waiting_approval_screen.dart';
import 'package:aureviarooms/provider/theme_provider.dart'; // ¡Importa el ThemeProvider!


class UserTypeGate extends StatelessWidget {
  const UserTypeGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Muestra SplashScreen mientras se verifica la sesión
    if (authProvider.isInitializingAuth) {
      return const SplashScreen();
    }

    // Si el usuario está autenticado, decide a dónde va
    if (authProvider.isAuthenticated) {
      switch (authProvider.userType) {
        case 'admin':
          return const OwnerNavBar(); // Para administradores
        case 'guest':
          return const UserNavBar(); // Para usuarios/huéspedes
        case 'NotSpecified':
          return const ChoosingRoleScreen(); // Para elegir rol
        case 'isWaiting':
          return const WaitingApprovalScreen(); // Para usuarios en espera
        case 'needs_selection':
          return const ChoosingRoleScreen(); 
        default:
          // Si el tipo es nulo o desconocido, podría ser un error.
          // Enviar al login es una opción segura.
          debugPrint('Usuario autenticado pero con rol desconocido/nulo: ${authProvider.userType}');
          return const LoginScreen();
      }
    } else {
      // Si no está autenticado, siempre va al login
      return const LoginScreen();
    }
  }
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Accede al ThemeProvider para obtener el modo de tema actual
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AureviaRooms',
      // Usa tus temas definidos en AppTheme y controla el modo
      theme: AppTheme.lightTheme, // Tema claro
      darkTheme: AppTheme.darkTheme, // ¡Necesitas definir esto en app_theme.dart!
      themeMode: themeProvider.themeMode, // Controla el modo del tema (claro/oscuro)
      home: const UserTypeGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/owner-home': (context) => const OwnerNavBar(),
        '/user-home': (context) => const UserNavBar(),
        '/choosing-role': (context) => const ChoosingRoleScreen(),
        '/waiting-approval': (context) => const WaitingApprovalScreen(),
      },
    );
  }
}