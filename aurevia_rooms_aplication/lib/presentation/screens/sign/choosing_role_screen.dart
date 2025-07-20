import 'package:flutter/material.dart';

class ChoosingRoleScreen extends StatelessWidget {
  const ChoosingRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Aquí el usuario elegirá su rol (Dueño o Huésped)'),
      ),
    );
  }
}