import 'package:flutter/material.dart';
import 'package:aureviarooms/presentation/screens/owner/main_owner_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/profile_owner_screen.dart';

class UserNavBar extends StatefulWidget {
  const UserNavBar({super.key});

  @override
  State<UserNavBar> createState() => _UserNavBarState();
}

class _UserNavBarState extends State<UserNavBar> {
  int _currentIndex = 0; // Empezar en pantalla principal (Inicio)

  final List<Widget> _screens = [
    const MainOwnerScreen(),  // Índice 0, Inicio
    ProfileOwnerScreen(),   // Índice 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
