import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  User? get currentUser => _currentUser;
  UserModel? get appUser => _appUser;
  String? get userType => _appUser?.userType;
  bool get isInitializingAuth => _isInitializingAuth;

  Future<void> setUser(UserModel updatedUser) async {
    try {
      await _userModelRepository.updateUser(updatedUser);
      _appUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw e;
    }
  }

  void updateConnection(ConnectionProvider newConnection) {
    _connectionProvider = newConnection;
  }

  Future<void> _initializeAuth() async {
    _isInitializingAuth = true;
    notifyListeners();

    _authSubscription = _client.auth.onAuthStateChange.listen((data) async {
      final oldUserId = _userId;
      _currentUser = data.session?.user;
      _userId = _currentUser?.id;
      _isAuthenticated = _currentUser != null;

      if (_isAuthenticated) {
        if (_userId != oldUserId || _appUser == null) {
          await _loadAppUser();
        }
      } else {
        _appUser = null;
      }

      if (_isInitializingAuth) {
        _isInitializingAuth = false;
      }
      notifyListeners();
    });

    if (_client.auth.currentUser != null) {
      _currentUser = _client.auth.currentUser;
      _userId = _currentUser?.id;
      _isAuthenticated = true;
      if (_userId != null) {
        await _loadAppUser();
      }
    } else {
      _isInitializingAuth = false;
      notifyListeners();
    }
  }

  Future<void> _loadAppUser() async {
    if (_userId == null) {
      _appUser = null;
      return;
    }
    try {
      _appUser = await _userModelRepository.getUserById(_userId!);
      debugPrint('AuthProvider: App User loaded: ${_appUser?.username}, Type: ${_appUser?.userType}');
    } catch (e) {
      debugPrint('AuthProvider: Error getting App User by ID: $e');
      if (e.toString().contains('Usuario no encontrado en caché') || e.toString().contains('PostgrestException')) {
        debugPrint('UserModel not found, attempting to create new record...');
        try {
          _appUser = UserModel(
            authUserId: _currentUser!.id,
            username: _currentUser!.userMetadata?['full_name'] as String? ?? _currentUser!.email?.split('@').first ?? 'Usuario',
            email: _currentUser!.email!,
            userType: 'guest',
            createdAt: DateTime.now(),
            profileImageUrl: _currentUser!.userMetadata?['avatar_url'] as String?,
            phoneNumber: _currentUser!.phone,
          );
          await _userModelRepository.createUser(_appUser!);
          debugPrint('UserModel created successfully.');
        } catch (createError) {
          debugPrint('Error creating UserModel: $createError');
          _appUser = null;
        }
      } else {
        _appUser = null;
      }
    }
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
    } catch (e) {
      debugPrint('Error Google SignIn: $e');
      if (e is PlatformException && e.code == 'channel-error') {
        throw Exception('Error al conectar con Google. Por favor, inténtalo de nuevo.');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    debugPrint('Starting logout process...');
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
        debugPrint('Google Sign In disconnected.');
      } else {
        debugPrint('Google Sign In was not signed in.');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (_connectionProvider.isConnected) {
        await _client.auth.signOut();
        debugPrint('Supabase session signed out.');
      } else {
        debugPrint('Logout offline. Supabase sync pending.');
      }

      _isAuthenticated = false;
      _userId = null;
      _currentUser = null;
      _appUser = null;
      debugPrint('AuthProvider state cleared.');
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      notifyListeners();
      debugPrint('Logout process finished.');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

