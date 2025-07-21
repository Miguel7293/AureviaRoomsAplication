import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/hotel.dart';
import 'package:aureviarooms/data/services/hotel_service.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/data/models/user_model.dart';
import 'package:aureviarooms/presentation/screens/user/edit_profile_screen.dart';
import 'package:aureviarooms/provider/theme_provider.dart'; // ¡Importa el nuevo ThemeProvider!

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final HotelService _hotelService = HotelService();

  // Elimina las definiciones de colores estáticos aquí, ahora vienen del tema
  // static const Color primaryBlue = Color(0xFF2A3A5B);
  // static const Color accentGold = Color(0xFFD4AF37);
  // static const Color textColorLight = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Accede a ambos proveedores
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider
    final UserModel? currentUser = authProvider.appUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/Logo_Nombre.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          // Usa el color de fondo de la AppBar del tema
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Accede a los colores y estilos del tema a través de Theme.of(context)
    // Esto asegura que se usen los colores correctos según el tema activo (claro u oscuro)
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).hintColor;

    return Scaffold(
      // El color de fondo del Scaffold lo gestiona el tema
      appBar: AppBar(
        elevation: 0,
        // Usa el color de fondo de la AppBar del tema
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/Logo_Nombre.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              'AureviaRooms',
              // Usa el estilo de texto del tema para el título grande
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            // Usa el color de fondo de la AppBar del tema
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pasa los colores del tema a los widgets hijos
            _buildProfileHeader(currentUser, primaryColor),
            const SizedBox(height: 16),
            _buildFavoritesSection(context, primaryColor),
            const SizedBox(height: 24),
            // Pasa el themeProvider a la sección para que el Switch lo use
            _buildProfileSection(context, authProvider, themeProvider, primaryColor, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, Color primaryColor) {
    final String profileImageUrl = user.profileImageUrl ??
        'https://via.placeholder.com/150/0000FF/FFFFFF?text=AU';

    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: primaryColor, // Usa el color primario del tema
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    // Usa el color de fondo del Scaffold del tema para el icono de edición
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: primaryColor, // Usa el color primario del tema
                  ),
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
              color: Colors.white, // Color fijo blanco para el texto en el encabezado azul
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.white70, // Color fijo blanco con opacidad para el correo
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection(BuildContext context, Color primaryColor) {
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
                  color: primaryColor, // Usa el color primario del tema
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

  // Ahora acepta themeProvider, primaryColor y accentColor
  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider, ThemeProvider themeProvider, Color primaryColor, Color accentColor) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
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
                trailing: const Text('Español'), // El color de este texto se adaptará al tema
              ),
              _buildProfileOption(
                icon: Icons.dark_mode_outlined,
                title: 'Modo Oscuro',
                onTap: () {
                  themeProvider.toggleTheme(); // Llama al método para cambiar el tema
                },
                trailing: Switch(
                  value: themeProvider.isDarkMode, // El valor del switch depende del estado del tema
                  onChanged: (val) {
                    themeProvider.toggleTheme(); // Al cambiar el switch, cambia el tema
                  },
                  activeColor: accentColor, // Usa el color de acento del tema
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
                backgroundColor: accentColor.withOpacity(0.1), // Usa el color de acento del tema
                foregroundColor: accentColor, // Usa el color de acento del tema
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
        color: Theme.of(context).cardColor, // Usa el color de la tarjeta del tema
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // Usa el color de sombra del tema (se adapta a claro/oscuro)
            color: Theme.of(context).shadowColor.withOpacity(0.2),
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
                // Usa el color para widgets deshabilitados o de fondo genérico del tema
                color: Theme.of(context).disabledColor.withOpacity(0.3),
                child: Icon(Icons.hotel, size: 50, color: Theme.of(context).hintColor), // Usa el color de acento del tema
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
                  // Usa el estilo de texto predefinido en el tema
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Theme.of(context).iconTheme.color), // Usa el color de icono del tema
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotel.location,
                        // Usa el estilo de texto predefinido y ajusta la opacidad
                        style: Theme.of(context).textTheme.bodySmall,
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
                        const Icon(Icons.star, size: 16, color: Colors.amber), // El color de la estrella puede permanecer fijo
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toString(),
                          // Usa el estilo de texto predefinido y añade negrita
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '\$${hotel.pricePerNight.toStringAsFixed(0)}/night',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor, // Usa el color primario del tema
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
      color: Theme.of(context).cardColor, // Usa el color de la tarjeta del tema
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
                  color: Theme.of(context).primaryColor, // Usa el color primario del tema
                ),
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor), // Usa el color del divisor del tema
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
      leading: Icon(icon, color: Theme.of(context).iconTheme.color), // Usa el color de icono del tema
      title: Text(
        title,
        // Usa el color de texto del ListTile si está definido, si no, usa el bodyMedium del tema
        style: Theme.of(context).listTileTheme.textColor != null
            ? TextStyle(color: Theme.of(context).listTileTheme.textColor)
            : Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: Theme.of(context).iconTheme.color), // Usa el color de icono del tema
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: onTap,
    );
  }
}