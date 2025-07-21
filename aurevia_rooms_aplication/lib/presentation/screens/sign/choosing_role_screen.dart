// lib/presentation/screens/sign/choosing_role_screen.dart

import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChoosingRoleScreen extends StatefulWidget {
  const ChoosingRoleScreen({super.key});

  @override
  State<ChoosingRoleScreen> createState() => _ChoosingRoleScreenState();
}

class _ChoosingRoleScreenState extends State<ChoosingRoleScreen> {
  bool _isLoading = false;

  // ANOTACIÓN: Esta función ahora llama a createUserProfile, que es la lógica correcta
  // para un usuario que inicia sesión por primera vez.
  Future<void> _selectAndCreateRole(String role) async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.createUserProfile(role);
    
    // Si el perfil se crea con éxito, el UserTypeGate nos redirigirá automáticamente.
    // Solo necesitamos manejar el caso de error.
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar tu selección.'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2A3A5B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator(color: primaryBlue)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logo_Nombre.png',
                      height: 150,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      '¿Cómo usarás la aplicación?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Elige un rol para personalizar tu experiencia.',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryBlue.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildRoleButton(
                      context,
                      icon: Icons.hotel_rounded,
                      title: 'Soy Cliente',
                      subtitle: 'Quiero buscar y reservar alojamientos.',
                      onTap: () => _selectAndCreateRole('guest'), // Rol para clientes
                    ),
                    const SizedBox(height: 16),
                    _buildRoleButton(
                      context,
                      icon: Icons.business_center_rounded,
                      title: 'Soy Dueño',
                      subtitle: 'Quiero registrar y gestionar mis propiedades.',
                      onTap: () => _selectAndCreateRole('admin'), // Rol para dueños
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    const Color primaryBlue = Color(0xFF2A3A5B);
    const Color accentGold = Color(0xFFD4AF37);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: accentGold),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: primaryBlue.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}