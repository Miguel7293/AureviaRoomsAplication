import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/supabase_config.dart';
import 'connection_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  User? _currentUser;
  final ConnectionProvider _connectionProvider;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  User? get currentUser => _currentUser;

  AuthProvider(this._connectionProvider) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
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

    const webClientId = '289612604342-qrrp5g2iv2hdisbpfb25uasm7vglt4lp.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    await SupabaseConfig.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken!,
    );

    // Esperamos brevemente para que se actualice el _currentUser desde el listener
    await Future.delayed(const Duration(milliseconds: 300));

    final user = SupabaseConfig.client.auth.currentUser;

    if (user != null) {
      debugPrint('🟢 Usuario conectado:');
      debugPrint('ID: ${user.id}');
      debugPrint('Email: ${user.email}');
      debugPrint('Nombre completo: ${user.userMetadata?["full_name"]}');
      debugPrint('Foto de perfil: ${user.userMetadata?["avatar_url"]}');
    } else {
      debugPrint('⚠️ No se obtuvo usuario después de login');
    }
  } catch (e) {
    print('Error Google SignIn: $e');
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
        print('Logout offline. Sincronización pendiente');
        return;
      }

      await _performNetworkLogout();
    } catch (e) {
      print('Error en logout: $e');
      _ensureCleanState();
    }
  }

  Future<void> _performNetworkLogout() async {
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print('Error al desconectar Google: $e');
    }

    try {
      await SupabaseConfig.client.auth.signOut();
    } on AuthException catch (e) {
      print('Error Supabase: ${e.message}');
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
}
