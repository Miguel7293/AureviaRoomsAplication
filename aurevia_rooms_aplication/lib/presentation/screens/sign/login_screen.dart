import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // --- NUEVO MÉTODO PARA MANEJAR EL LOGIN ---
Future<void> _handleGoogleLogin() async {
  if (_isLoading) return;

  setState(() => _isLoading = true);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  try {
    // Simplemente intenta iniciar sesión.
    // El UserTypeGate se encargará de la redirección automáticamente.
    await authProvider.loginWithGoogle();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: ${e is AuthException ? e.message : e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      // Ocultamos el loading, pero no navegamos.
      setState(() => _isLoading = false);
    }
  }
}



  @override
  Widget build(BuildContext context) {
    // El resto de tu UI se mantiene, solo cambiamos el `onPressed` del botón
    const Color primaryBlue = Color(0xFF2A3A5B);
    const Color accentGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Logo_Nombre.png',
                height: 180,
              ),
              const SizedBox(height: 40),
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 28,
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Descubre y reserva tu estancia perfecta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: primaryBlue.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 60),

              _isLoading
                  ? const CircularProgressIndicator(color: primaryBlue)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // --- AQUÍ CONECTAMOS EL NUEVO MÉTODO ---
                        onPressed: _handleGoogleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: accentGold,
                        ),
                        label: const Text(
                          'Continuar con Google',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}