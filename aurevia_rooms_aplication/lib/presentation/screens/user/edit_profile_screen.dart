import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/user_model.dart';
import 'package:aureviarooms/data/services/user_model_repository.dart';
import 'package:aureviarooms/provider/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('Validación fallida en el formulario');
      return;
    }

    // Ocultar el teclado antes de iniciar la operación
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.appUser;
      if (user == null) {
        debugPrint('Error: No se encontró el usuario en AuthProvider');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: No se pudo cargar la información del usuario. Intenta de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error, // Color de error del tema
          ),
        );
        return;
      }

      debugPrint('Intentando actualizar usuario con authUserId: ${user.authUserId}');
      debugPrint('Nuevo username: ${_usernameController.text.trim()}');
      debugPrint('Nuevo phoneNumber: ${_phoneController.text.trim()}');

      // Crear un UserModel temporal con los datos actualizados
      final updatedUser = UserModel(
        authUserId: user.authUserId,
        username: _usernameController.text.trim(),
        email: user.email,
        userType: user.userType,
        createdAt: user.createdAt,
        phoneNumber: _phoneController.text.trim(),
        profileImageUrl: user.profileImageUrl,
      );

      // Actualizar en Supabase usando UserModelRepository
      final userRepository = Provider.of<UserModelRepository>(context, listen: false);
      debugPrint('Llamando a updateUser en UserModelRepository');
      final newUser = await userRepository.updateUser(updatedUser);
      debugPrint('Usuario actualizado con éxito: ${newUser.username}');

      // Actualizar el estado en AuthProvider
      authProvider.setUser(newUser);
      debugPrint('Estado de AuthProvider actualizado con: ${newUser.username}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: Theme.of(context).colorScheme.secondary, // Un color de acento para éxito
        ),
      );
      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      debugPrint('Error al actualizar el perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el perfil: ${e.toString().contains("SocketException") ? "Problema de conexión. Verifica tu internet." : "Ocurrió un error inesperado."}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        // Usa los colores del tema para que se adapte al modo oscuro
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: const OutlineInputBorder(),
                  // Colores de borde y etiqueta según el tema
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Color del texto de entrada
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Número de teléfono',
                  border: const OutlineInputBorder(),
                  // Colores de borde y etiqueta según el tema
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Color del texto de entrada
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                      return 'Por favor, ingresa un número de teléfono válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  // Usa los colores definidos en el tema para ElevatedButtonTheme
                  backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({MaterialState.pressed}),
                  foregroundColor: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({MaterialState.pressed}),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({MaterialState.pressed}))
                    : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}