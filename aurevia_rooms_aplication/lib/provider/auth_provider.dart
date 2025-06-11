// archivo: auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/supabase/supabase_config.dart';
import 'connection_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  User? _currentUser;
  final SupabaseClient _client = SupabaseConfig.client;
  late ConnectionProvider _connectionProvider;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider(this._connectionProvider) {
    _setupAuthListener();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  User? get currentUser => _currentUser;

  void updateConnection(ConnectionProvider newConnection) {
    _connectionProvider = newConnection;
  }

  void _setupAuthListener() {
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      _userId = _currentUser?.id;
      _isAuthenticated = _currentUser != null;
      notifyListeners();
    });
  }

  Future<void> loginWithGoogle() async {
    try {
      if (!_connectionProvider.isConnected) {
        throw Exception('No hay conexión a internet');
      }

      const webClientId = '546959425861-4dkijnept6pgua31kpqtch2kiva3jgo5.apps.googleusercontent.com';

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

      await Future.delayed(const Duration(milliseconds: 300));

      final user = _client.auth.currentUser;

      if (user != null) {
        debugPrint('Usuario conectado:');
        debugPrint('ID: ${user.id}');
        debugPrint('Email: ${user.email}');
        debugPrint('Nombre completo: ${user.userMetadata?["full_name"]}');
        debugPrint('Foto de perfil: ${user.userMetadata?["avatar_url"]}');
      } else {
        debugPrint('No se obtuvo usuario después de login');
      }
    } catch (e) {
      debugPrint('Error Google SignIn: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userId = null;
      _currentUser = null;
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
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
