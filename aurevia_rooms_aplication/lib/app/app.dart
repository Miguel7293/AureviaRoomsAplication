import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/core/theme/app_theme.dart';
import 'package:aureviarooms/presentation/navigation/user_nav_bar.dart';
import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:aureviarooms/provider/auth_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AureviaRooms',
      theme: AppTheme.lightTheme,
      home: authProvider.isAuthenticated
          ? const UserNavBar()
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const UserNavBar(),
      },
    );
  }
}