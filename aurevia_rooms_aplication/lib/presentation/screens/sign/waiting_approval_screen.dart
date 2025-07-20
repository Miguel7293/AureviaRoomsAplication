import 'package:flutter/material.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tu solicitud está siendo revisada. Te notificaremos pronto.'),
      ),
    );
  }
}