import 'package:aureviarooms/presentation/screens/sign/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/data/models/user_model.dart';
import 'package:aureviarooms/provider/theme_provider.dart';

class ProfileOwnerScreen extends StatefulWidget {
  const ProfileOwnerScreen({super.key});

  @override
  State<ProfileOwnerScreen> createState() => _ProfileOwnerScreenState();
}

class _ProfileOwnerScreenState extends State<ProfileOwnerScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? currentUser = authProvider.appUser;

    _usernameController = TextEditingController(text: currentUser?.username ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _phoneController = TextEditingController(text: currentUser?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).hintColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color dividerColor = Theme.of(context).dividerColor; // Defined here

    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final UserModel? currentUser = authProvider.appUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/Logo_Nombre.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
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
            errorBuilder: (context, error, stackTrace) => Text(
              'AureviaRooms',
              style: TextStyle(color: textColor),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(currentUser, primaryColor, onPrimaryColor),
            const SizedBox(height: 24),
            _buildEditableProfileSection(
              context,
              authProvider,
              primaryColor,
              textColor,
              dividerColor, // Passed dividerColor
            ),
            const SizedBox(height: 20),
            _buildAppConfigSection(
              context,
              themeProvider,
              primaryColor,
              textColor,
              dividerColor, // Passed dividerColor
              accentColor,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: accentColor),
                label: Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, color: accentColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.1),
                  foregroundColor: accentColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await authProvider.logout();
                  if (!context.mounted) return; // Guard against async gap
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
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, Color primaryColor, Color onPrimaryColor) {
    final String profileImageUrl = user.profileImageUrl ??
        'https://via.placeholder.com/150/0000FF/FFFFFF?text=AU';

    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: primaryColor,
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
                  // TODO: Implementar la lógica para cambiar la imagen de perfil
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de cambiar imagen de perfil (TODO)')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: onPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: onPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              color: onPrimaryColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileSection(
    BuildContext context,
    AuthProvider authProvider,
    Color primaryColor,
    Color textColor,
    Color dividerColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildProfileCard(
        context,
        title: 'Información Personal',
        options: [
          _buildEditableProfileField(
            context,
            icon: Icons.person_outline,
            label: 'Nombre de Usuario',
            controller: _usernameController,
            primaryColor: primaryColor,
            textColor: textColor,
            dividerColor: dividerColor, // Pass dividerColor
          ),
          // Email field is usually not editable via app, but displayed
          _buildEditableProfileField(
            context,
            icon: Icons.email_outlined,
            label: 'Email',
            controller: _emailController,
            primaryColor: primaryColor,
            textColor: textColor,
            dividerColor: dividerColor, // Pass dividerColor
            keyboardType: TextInputType.emailAddress,
            readOnly: true, // Make email read-only as it's often managed by auth provider
          ),
          _buildEditableProfileField(
            context,
            icon: Icons.phone_outlined,
            label: 'Número de Teléfono',
            controller: _phoneController,
            primaryColor: primaryColor,
            textColor: textColor,
            dividerColor: dividerColor, // Pass dividerColor
            keyboardType: TextInputType.phone,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!mounted) return; // Guard against async gap

                  final currentUser = authProvider.appUser;
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: No se encontró la información del usuario.')),
                    );
                    return;
                  }

                  // Create a new UserModel with updated data, using existing non-editable fields
                  final updatedUser = UserModel(
                    authUserId: currentUser.authUserId,
                    username: _usernameController.text,
                    email: currentUser.email, // Use current email, as it's read-only
                    userType: currentUser.userType, // Use current userType
                    createdAt: currentUser.createdAt,
                    profileImageUrl: currentUser.profileImageUrl,
                    phoneNumber: _phoneController.text,
                  );

                  try {
                    // Use authProvider.setUser to update the profile
                    await authProvider.setUser(updatedUser);
                    if (!mounted) return; // Guard against async gap
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil actualizado exitosamente!')),
                    );
                  } catch (e) {
                    if (!mounted) return; // Guard against async gap
                    debugPrint('Error al actualizar perfil: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar perfil: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Guardar Cambios'),
              ),
            ),
          ),
        ],
        primaryColor: primaryColor,
        textColor: textColor,
        dividerColor: dividerColor,
      ),
    );
  }

  Widget _buildEditableProfileField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color primaryColor,
    required Color textColor,
    required Color dividerColor, // dividerColor is now correctly passed
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false, // Added a readOnly parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        readOnly: readOnly, // Apply readOnly property
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: dividerColor),
          ),
          // If readOnly, make it look less like an input field
          filled: readOnly,
          fillColor: readOnly ? Theme.of(context).disabledColor.withOpacity(0.1) : null,
        ),
      ),
    );
  }

  Widget _buildAppConfigSection(
    BuildContext context,
    ThemeProvider themeProvider,
    Color primaryColor,
    Color textColor,
    Color dividerColor,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildProfileCard(
        context,
        title: 'Configuración de la Aplicación',
        options: [
          _buildProfileOption(
            context: context,
            icon: Icons.language_outlined,
            title: 'Idioma',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cambio de idioma (TODO)')),
              );
            },
            trailing: Text('Español', style: TextStyle(color: textColor.withOpacity(0.7))),
          ),
          _buildProfileOption(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: 'Modo Oscuro',
            onTap: () {
              themeProvider.toggleTheme();
            },
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (val) {
                themeProvider.toggleTheme();
              },
              activeColor: accentColor,
            ),
          ),
        ],
        primaryColor: primaryColor,
        textColor: textColor,
        dividerColor: dividerColor,
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required List<Widget> options,
    required Color primaryColor,
    required Color textColor,
    required Color dividerColor,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
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
                      color: primaryColor,
                    ),
              ),
            ),
            Divider(height: 1, color: dividerColor),
            ...options,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: Theme.of(context).iconTheme.color),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      onTap: onTap,
    );
  }
}