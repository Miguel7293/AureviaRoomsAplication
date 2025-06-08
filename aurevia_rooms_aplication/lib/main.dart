// lib/main.dart
import 'package:flutter/material.dart';
import 'package:aureviarooms/presentation/screens/user/main_user_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AureviaRooms',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainUserScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}