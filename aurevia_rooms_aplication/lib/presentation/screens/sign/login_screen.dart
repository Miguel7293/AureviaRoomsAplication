import 'package:aureviarooms/app/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color buttonTextColor = Colors.white;
  static const Color googleIconColor = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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

              Text(
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
                  ? CircularProgressIndicator(color: primaryBlue)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // 1. Mostrar el indicador de carga INMEDIATAMENTE
                          setState(() { // <--- Aquí, esto es seguro porque la pantalla aún está montada
                            _isLoading = true;
                          });

                          try {
                            await authProvider.loginWithGoogle();

                            // 2. Después de la operación asíncrona, verifica si la pantalla sigue montada
                            if (!context.mounted) {
                              // Si ya no está montada, no intentes actualizar el estado
                              // Ni navegues, ni muestres SnackBar, simplemente sal.
                              return;
                            }

                            if (authProvider.isAuthenticated) {

                                Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const UserTypeGate()), // Vuelve al UserTypeGate
                                (route) => false, // Elimina todas las rutas anteriores
                              );
                            }
                          } catch (e) {
                            // 4. Si hay un error, también verifica si la pantalla sigue montada
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al iniciar sesión: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            // 5. En el bloque finally, SIEMPRE verifica si la pantalla sigue montada
                            // antes de intentar ocultar el indicador de carga.
                            if (context.mounted) { // <--- ¡Añade esta verificación aquí!
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: buttonTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        icon: FaIcon(
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
