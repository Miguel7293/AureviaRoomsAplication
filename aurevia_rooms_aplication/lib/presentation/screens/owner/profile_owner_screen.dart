import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar Provider
import 'package:aureviarooms/data/models/hotel.dart'; // Asumo que Hotel y HotelService siguen siendo relevantes aquí
import 'package:aureviarooms/data/services/hotel_service.dart';
import 'package:aureviarooms/provider/auth_provider.dart'; // Importar AuthProvider
import 'package:aureviarooms/data/models/user_model.dart'; // Importar UserModel si lo necesitas para tipos

class ProfileOwnerScreen extends StatefulWidget {
  const ProfileOwnerScreen({super.key}); // Cambiado a const

  @override
  State<ProfileOwnerScreen> createState() => _ProfileOwnerScreenState();
}

class _ProfileOwnerScreenState extends State<ProfileOwnerScreen> {
  final HotelService _hotelService = HotelService(); // Tu servicio de hoteles
  // Colores de la marca (azul oscuro y dorado)
  static const Color primaryBlue = Color(0xFF2A3A5B); // Azul oscuro del logo
  static const Color accentGold = Color(0xFFD4AF37); // Dorado/Mostaza del logo
  static const Color textColorLight = Colors.white; // Texto blanco para contraste

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? currentUser = authProvider.appUser; // Obtener el UserModel del AuthProvider

    // Si el usuario no está cargado, puedes mostrar un spinner o mensaje
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
            color: Colors.white, // Color de fondo del AppBar
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(currentUser), // Pasar el currentUser
            const SizedBox(height: 16),
            _buildFavoritesSection(context),
            const SizedBox(height: 24),
            _buildProfileSection(context, authProvider), // Pasar authProvider para logout
          ],
        ),
      ),
    );
  }

  // Ahora _buildProfileHeader recibe el UserModel
  Widget _buildProfileHeader(UserModel user) {
    // Usar la imagen de perfil del usuario si está disponible, de lo contrario un placeholder
    final String profileImageUrl = user.profileImageUrl ??
        'https://via.placeholder.com/150/0000FF/FFFFFF?text=AU'; // Placeholder si no hay URL

    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: primaryBlue, // Usar el azul oscuro de tu marca
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
                backgroundImage: NetworkImage(profileImageUrl), // Usar URL de imagen real
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback para errores de carga de imagen
                  debugPrint('Error loading profile image: $exception');
                },
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: textColorLight, // Fondo blanco para el icono de edición
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: primaryBlue, // Icono de edición en azul oscuro
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.username, // Mostrar el nombre de usuario real
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColorLight, // Texto en blanco
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email, // Mostrar el email real
            style: const TextStyle(
              color: Colors.white70, // Texto en blanco con opacidad
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // --- EL RESTO DE TUS MÉTODOS DE SECCIÓN NO CAMBIAN MUCHO, EXCEPTO EL LOGOUT ---

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
                'Hoteles Favoritos', // Traducido
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue, // Usar el color de tu marca
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

  // _buildProfileSection ahora recibe authProvider para el logout
  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProfileCard(
            context,
            title: 'Configuración de Cuenta', // Traducido
            options: [
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Información Personal', // Traducido
                onTap: () {
                  // TODO: Implementar navegación a edición de perfil
                },
              ),
              _buildProfileOption(
                icon: Icons.lock_outline,
                title: 'Contraseña y Seguridad', // Traducido
                onTap: () {
                  // TODO: Implementar navegación a seguridad
                },
              ),
              _buildProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones', // Traducido
                onTap: () {
                  // TODO: Implementar navegación a notificaciones
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCard(
            context,
            title: 'Configuración de la Aplicación', // Traducido
            options: [
              _buildProfileOption(
                icon: Icons.language_outlined,
                title: 'Idioma', // Traducido
                onTap: () {},
                trailing: const Text('Español'), // Mostrar idioma actual
              ),
              _buildProfileOption(
                icon: Icons.dark_mode_outlined,
                title: 'Modo Oscuro', // Traducido
                onTap: () {
                  // TODO: Implementar lógica de cambio de tema
                },
                trailing: Switch(
                  value: false, // Valor real del modo oscuro
                  onChanged: (val) {
                    // TODO: Implementar cambio de modo oscuro
                  },
                  activeColor: accentGold, // Color activo del switch en dorado
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCard(
            context,
            title: 'Soporte', // Traducido
            options: [
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Centro de Ayuda', // Traducido
                onTap: () {
                  // TODO: Implementar navegación a centro de ayuda
                },
              ),
              _buildProfileOption(
                icon: Icons.info_outline,
                title: 'Acerca de la Aplicación', // Traducido
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
                'Cerrar Sesión', // Traducido
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGold.withOpacity(0.1), // Fondo más suave con dorado
                foregroundColor: accentGold, // Texto en dorado
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                // Acción de logout
                await authProvider.logout();
                if (!context.mounted) return;
                // Después de logout, UserTypeGate redirigirá a LoginScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()), // O UserTypeGate si quieres que decida
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
    // Tu método _buildHotelCard sin cambios significativos en la lógica
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
                        color: primaryBlue, // Usar el azul de tu marca
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
                      color: primaryBlue, // Usar el azul de tu marca para títulos de sección
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
      leading: Icon(icon, color: primaryBlue), // Iconos de opción en azul oscuro
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: primaryBlue), // Flecha en azul oscuro
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: onTap,
    );
  }
}