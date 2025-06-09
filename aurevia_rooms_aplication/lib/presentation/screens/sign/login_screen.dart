// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

    return Scaffold(
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, loading, _) {
            return loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar sesión con Google'),
                    onPressed: () async {
                      isLoading.value = true;
                      try {
                        await authProvider.loginWithGoogle();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        isLoading.value = false;
                      }
                    },
                  );
          },
        ),
      ),
    );
  }
}
