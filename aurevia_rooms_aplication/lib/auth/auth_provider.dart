import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/supabase/supabase_config.dart';
import '../auth/connection_provider.dart';

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
    SupabaseConfig.client.auth.onAuthStateChange.listen((AuthState data) {
      _currentUser = data.session?.user;
      _userId = _currentUser?.id;
      _isAuthenticated = _currentUser != null;
      notifyListeners();
    });
  }

  Future<void> loginWithGoogle() async {
    try {
      // Verificar si hay conexión
      if (!_connectionProvider.isConnected) {
        throw Exception('No hay conexión a internet');
      }

      const webClientId =
          '546959425861-d4hlntkep2079qu2t5vjbdv8fklthndd.apps.googleusercontent.com';
      //const iosClientId = 'TU_CLIENT_ID_IOS'; // Opcional para iOS
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        //clientId: iosClientId,
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;

      await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );
    } catch (e) {
      print('Error Google SignIn: $e');
      rethrow;
    }
  }


Future<void> logout() async {
  try {
    // Limpiar estado local primero
    _isAuthenticated = false;
    _userId = null;
    _currentUser = null;
    notifyListeners();

    if (!_connectionProvider.isConnected) {
      // No relanzar excepción, solo registrar
      print('Logout offline. Sincronización pendiente');
      return; // Salir silenciosamente
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
