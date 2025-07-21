import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/supabase/supabase_config.dart';
import '../data/models/user_model.dart';
import '../data/services/user_model_repository.dart';
import 'connection_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  User? _currentUser;
  UserModel? _appUser;
  bool _isInitializingAuth = true;
  final SupabaseClient _client = SupabaseConfig.client;
  late ConnectionProvider _connectionProvider;
  final UserModelRepository _userModelRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider(this._connectionProvider, this._userModelRepository) {
    _initializeAuth();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  User? get currentUser => _currentUser;
  UserModel? get appUser => _appUser;
  bool get isInitializingAuth => _isInitializingAuth;

  String? get userType {
    if (_isAuthenticated && _appUser == null) {
      return 'needs_selection'; 
    }
    return _appUser?.userType;
  }

  void updateConnection(ConnectionProvider newConnection) {
    _connectionProvider = newConnection;
  }

  Future<void> _initializeAuth() async {
    // El listener ahora es más simple, solo delega al método centralizado.
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      _updateSessionAndProfile(data.session);
    });

    // Comprobación inicial al arrancar la app.
    await _updateSessionAndProfile(_client.auth.currentSession, isInitializing: true);
  }

  // ANOTACIÓN: Este nuevo método centraliza la lógica de actualización.
  Future<void> _updateSessionAndProfile(Session? session, {bool isInitializing = false}) async {
    if (isInitializing) {
      _isInitializingAuth = true;
      notifyListeners();
    }
    
    _currentUser = session?.user;
    _userId = _currentUser?.id;
    _isAuthenticated = _currentUser != null;

    if (_isAuthenticated) {
      await _loadAppUser();
    } else {
      _appUser = null;
    }

    if (isInitializing) {
      _isInitializingAuth = false;
    }
    // Solo notifica al final para evitar reconstrucciones innecesarias.
    notifyListeners();
  }

  Future<void> setUser(UserModel updatedUser) async {
    try {
      _appUser = await _userModelRepository.updateUser(updatedUser);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error actualizando el perfil de usuario: $e');
      rethrow;
    }
  }

  Future<void> _loadAppUser() async {
    if (_userId == null) {
      _appUser = null;
      return;
    }
    try {
      _appUser = await _userModelRepository.getUserById(_userId!);
      debugPrint('AuthProvider: Perfil de usuario cargado.');
    } catch (e) {
      debugPrint('AuthProvider: Perfil de usuario no encontrado. Esperando selección de rol.');
      _appUser = null;
    }
  }

  Future<bool> createUserProfile(String role) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return false;
    try {
      final newUser = UserModel(
        authUserId: authUser.id,
        username: authUser.userMetadata?['full_name'] as String? ?? authUser.email!.split('@').first,
        email: authUser.email!,
        userType: role,
        createdAt: DateTime.now(),
        profileImageUrl: authUser.userMetadata?['avatar_url'] as String?,
        phoneNumber: authUser.phone,
      );
      _appUser = await _userModelRepository.createUser(newUser);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error creando el perfil de usuario: $e');
      return false;
    }
  }

  // ANOTACIÓN: Este es el método corregido que soluciona el problema.
  Future<void> loginWithGoogle() async {
    try {
      if (!_connectionProvider.isConnected) {
        throw Exception('No hay conexión a internet');
      }

      const webClientId = '546959425861-4dkijnept6pgua31kpqtch2kiva3jgo5.apps.googleusercontent.com';
      final googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null || idToken == null) throw 'No se encontró el token de Google';

      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Este es el paso clave: después de autenticar, llamamos a nuestro método
      // centralizado que actualiza el perfil y notifica a la UI. El método
      // no termina hasta que este paso se completa.
      if (authResponse.session != null) {
        await _updateSessionAndProfile(authResponse.session);
      }
    } catch (e) {
      debugPrint('Error Google SignIn: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}