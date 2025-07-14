// archivo: auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/supabase/supabase_config.dart';
import '../data/models/user_model.dart'; // <--- Importa tu modelo de usuario
import '../data/services/user_model_repository.dart'; // <--- Importa tu repositorio de usuario
import 'connection_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  User? _currentUser;
  UserModel? _appUser; // <--- Almacenará el UserModel completo
  final SupabaseClient _client = SupabaseConfig.client;
  late ConnectionProvider _connectionProvider;
  final UserModelRepository _userModelRepository; // <--- Inyecta el repositorio

  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider(this._connectionProvider, this._userModelRepository) { // <--- Recibe el repositorio
    _setupAuthListener();
    _loadAppUser(); // <--- Cargar el UserModel al inicializar
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  User? get currentUser => _currentUser;
  UserModel? get appUser => _appUser; // <--- Getter para el UserModel completo
  String? get userType => _appUser?.userType; // <--- Getter para el userType del UserModel

  void updateConnection(ConnectionProvider newConnection) {
    _connectionProvider = newConnection;
  }

  void _setupAuthListener() {
    _authSubscription = _client.auth.onAuthStateChange.listen((data) async { // <--- Hazlo async
      _currentUser = data.session?.user;
      _userId = _currentUser?.id;
      _isAuthenticated = _currentUser != null;

      if (_isAuthenticated) {
        await _loadAppUser(); // <--- Cargar el UserModel cuando el estado de auth cambia a logueado
      } else {
        _appUser = null; // Limpiar el UserModel si no está autenticado
      }
      notifyListeners();
    });
  }

  // Método para cargar el UserModel completo
  Future<void> _loadAppUser() async {
    if (_userId != null) {
      try {
        _appUser = await _userModelRepository.getUserById(_userId!);
        debugPrint('AuthProvider: App User loaded: ${_appUser?.username}, Type: ${_appUser?.userType}');
      } catch (e) {
        debugPrint('AuthProvider: Error loading App User: $e');
        _appUser = null; // Asegurarse de que el usuario sea nulo si hay un error
      }
    } else {
      _appUser = null;
    }
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    try {
      if (!_connectionProvider.isConnected) {
        throw Exception('No hay conexión a internet');
      }

      const webClientId = '546959425861-4dkijnept6pgua31kpqtch2kiva3jgo5.apps.googleusercontent.com'; // Asegúrate que este Client ID sea correcto

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      await Future.delayed(const Duration(milliseconds: 300)); // Pequeña espera

      _currentUser = _client.auth.currentUser;
      _userId = _currentUser?.id;
      _isAuthenticated = _currentUser != null;

      if (_currentUser != null) {
        // Después de un login exitoso, verifica si el UserModel existe.
        // Si no existe, créalo con un tipo de usuario predeterminado ('guest').
        try {
          _appUser = await _userModelRepository.getUserById(_currentUser!.id);
        } catch (e) {
          // Si el usuario no existe en tu tabla 'user_model', créalo.
          debugPrint('UserModel not found, creating new user record...');
          _appUser = UserModel(
            authUserId: _currentUser!.id,
            username: _currentUser!.userMetadata?['full_name'] as String? ?? 'Usuario',
            email: _currentUser!.email!,
            userType: 'guest', // <--- Asigna un tipo de usuario predeterminado
            createdAt: DateTime.now(),
            profileImageUrl: _currentUser!.userMetadata?['avatar_url'] as String?,
          );
          await _userModelRepository.createUser(_appUser!);
        }

        debugPrint('Usuario conectado:');
        debugPrint('ID: ${_currentUser!.id}');
        debugPrint('Email: ${_currentUser!.email}');
        debugPrint('Nombre completo: ${_currentUser!.userMetadata?["full_name"]}');
        debugPrint('Foto de perfil: ${_currentUser!.userMetadata?["avatar_url"]}');
        debugPrint('Tipo de usuario: ${_appUser?.userType}'); // Mostrar el tipo de usuario de tu modelo
      } else {
        debugPrint('No se obtuvo usuario después de login');
      }
    } catch (e) {
      debugPrint('Error Google SignIn: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userId = null;
      _currentUser = null;
      _appUser = null; // Limpiar el UserModel al hacer logout
      notifyListeners();

      if (!_connectionProvider.isConnected) {
        debugPrint('Logout offline. Sincronización pendiente');
        return;
      }

      await _performNetworkLogout();
    } catch (e) {
      debugPrint('Error en logout: $e');
      _ensureCleanState();
    }
  }

  Future<void> _performNetworkLogout() async {
    final googleSignIn = GoogleSignIn();

    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
    } catch (e) {
      debugPrint('Error al desconectar Google: $e');
    }

    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('Error Supabase: ${e.message}');
    }
  }

  void _ensureCleanState() {
    if (_isAuthenticated) {
      _isAuthenticated = false;
      _userId = null;
      _currentUser = null;
      _appUser = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}