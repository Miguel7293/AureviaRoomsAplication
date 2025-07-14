import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/hotel.dart';
import 'package:aureviarooms/data/services/hotel_service.dart';
import 'package:aureviarooms/provider/auth_provider.dart'; // Importar AuthProvider
import 'package:aureviarooms/data/models/user_model.dart'; // Importar UserModel

class ProfileScreen extends StatefulWidget { // Cambiado a StatefulWidget
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final HotelService _hotelService = HotelService();

  // Colores de la marca (azul oscuro y dorado)
  static const Color primaryBlue = Color(0xFF2A3A5B); // Azul oscuro del logo
  static const Color accentGold = Color(0xFFD4AF37); // Dorado/Mostaza del logo
  static const Color textColorLight = Colors.white; // Texto blanco para contraste

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? currentUser = authProvider.appUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/Logo_Nombre.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/Logo_Nombre.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
              'AureviaRooms',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(currentUser),
            const SizedBox(height: 16),
            _buildFavoritesSection(context),
            const SizedBox(height: 24),
            _buildProfileSection(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final String profileImageUrl = user.profileImageUrl ??
        'https://via.placeholder.com/150/0000FF/FFFFFF?text=AU';

    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImageUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading profile image: $exception');
                },
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: textColorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColorLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(BuildContext context) {
    return FutureBuilder<List<Hotel>>(
      future: _hotelService.getFeaturedHotels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('Error al cargar favoritos: ${snapshot.error}')),
          );
        }

        final hotels = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoteles Favoritos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    return _buildHotelCard(hotels[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProfileCard(
            context,
            title: 'Configuración de Cuenta',
            options: [
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Información Personal',
                onTap: () {
                  // TODO: Implementar navegación a edición de perfil
                },
              ),
              _buildProfileOption(
                icon: Icons.lock_outline,
                title: 'Contraseña y Seguridad',
                onTap: () {
                  // TODO: Implementar navegación a seguridad
                },
              ),
              _buildProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                onTap: () {
                  // TODO: Implementar navegación a notificaciones
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCard(
            context,
            title: 'Configuración de la Aplicación',
            options: [
              _buildProfileOption(
                icon: Icons.language_outlined,
                title: 'Idioma',
                onTap: () {},
                trailing: const Text('Español'),
              ),
              _buildProfileOption(
                icon: Icons.dark_mode_outlined,
                title: 'Modo Oscuro',
                onTap: () {
                  // TODO: Implementar lógica de cambio de tema
                },
                trailing: Switch(
                  value: false,
                  onChanged: (val) {
                    // TODO: Implementar cambio de modo oscuro
                  },
                  activeColor: accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCard(
            context,
            title: 'Soporte',
            options: [
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Centro de Ayuda',
                onTap: () {
                  // TODO: Implementar navegación a centro de ayuda
                },
              ),
              _buildProfileOption(
                icon: Icons.info_outline,
                title: 'Acerca de la Aplicación',
                onTap: () {
                  // TODO: Implementar navegación a información de la app
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGold.withOpacity(0.1),
                foregroundColor: accentGold,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await authProvider.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              hotel.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotel.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '\$${hotel.pricePerNight.toStringAsFixed(0)}/night',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required List<Widget> options,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
              ),
            ),
            const Divider(height: 1),
            ...options,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: primaryBlue),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: onTap,
    );
  }
}