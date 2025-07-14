import 'package:aureviarooms/presentation/screens/owner/main_owner_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/profile_owner_screen.dart';
import 'package:flutter/material.dart';



class OwnerNavBar extends StatefulWidget {
  const OwnerNavBar({super.key});

  @override
  State<OwnerNavBar> createState() => _OwnerNavBarState();
}

class _OwnerNavBarState extends State<OwnerNavBar> {
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
