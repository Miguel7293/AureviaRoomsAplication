import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Colores de la marca (definidos aquí para esta pantalla específica)
  static const Color primaryBlue = Color(0xFF2A3A5B); // Azul oscuro del logo
  static const Color accentGold = Color(0xFFD4AF37); // Dorado/Mostaza del logo

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      // NUEVO: Duración de 1.5 segundos para una animación más rápida pero controlada
      duration: const Duration(milliseconds: 1500), 
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        // NUEVO: Curves.easeInOut para un fundido más suave (empieza lento, acelera, termina lento)
        curve: Curves.easeInOut, 
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        // NUEVO: Curves.easeOutBack para un efecto de escala con un ligero "pop" sin rebote excesivo
        curve: Curves.easeOutBack, 
      ),
    );

    _animationController.forward(); // Inicia la animación al cargar la pantalla
  }

  @override
  void dispose() {
    _animationController.dispose(); // Libera recursos del controlador de animación
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/Logo_Nombre.png', 
                  height: 200, 
                ),
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentGold),
              strokeWidth: 4,
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando tu experiencia...',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}