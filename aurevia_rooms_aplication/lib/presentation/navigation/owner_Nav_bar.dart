import 'package:aureviarooms/presentation/screens/owner/main_owner_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/profile_owner_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/notifications_owner_screen.dart';
import 'package:flutter/material.dart';

class OwnerNavBar extends StatefulWidget {
  const OwnerNavBar({super.key});

  @override
  State<OwnerNavBar> createState() => _OwnerNavBarState();
}

class _OwnerNavBarState extends State<OwnerNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainOwnerScreen(),        // 0 Inicio
    const NotificationsOwnerScreen(), // 1 Notificaciones
    const ProfileOwnerScreen(),     // 2 Perfil
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
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
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
