// user_model_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/auth/connection_provider.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../models/user_model.dart';

class UserModelRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  UserModelRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<UserModel> createUser(UserModel user) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('user_model').insert(user.toJson()).select().single(),
    );

    final newUser = UserModel.fromJson(response);
    await _cacheUser(newUser);
    return newUser;
  }

  Future<UserModel> updateUser(UserModel user) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('user_model')
          .update(user.toJson())
          .eq('auth_user_id', user.authUserId)
          .select()
          .single(),
    );

    final updatedUser = UserModel.fromJson(response);
    await _cacheUser(updatedUser);
    return updatedUser;
  }

  Future<void> deleteUser(String authUserId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('user_model').delete().eq('auth_user_id', authUserId),
    );

    await _removeCachedUser(authUserId);
  }

  Future<UserModel> getUserById(String authUserId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedUser(authUserId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('user_model').select().eq('auth_user_id', authUserId).single(),
      );

      final user = UserModel.fromJson(response);
      await _cacheUser(user);
      return user;
    } catch (e) {
      debugPrint('❌ Error obteniendo usuario: $e');
      return _getCachedUser(authUserId);
    }
  }

  Future<UserModel> getAuthenticatedUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('Usuario no autenticado');
    return getUserById(authUser.id);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedUserSearch(query);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('user_model').select().or('username.ilike.%$query%,email.ilike.%$query%'),
      );

      final users = (response as List).map((json) => UserModel.fromJson(json)).toList();
      await _cacheUserSearch(query, users);
      return users;
    } catch (e) {
      debugPrint('❌ Error buscando usuarios: $e');
      return _getCachedUserSearch(query);
    }
  }

  // Caché methods
  Future<void> _cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getCachedUsers();
    final index = users.indexWhere((u) => u.authUserId == user.authUserId);
    
    if (index != -1) {
      users[index] = user;
    } else {
      users.add(user);
    }
    
    await prefs.setString('cached_users', jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<void> _removeCachedUser(String authUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getCachedUsers();
    users.removeWhere((u) => u.authUserId == authUserId);
    await prefs.setString('cached_users', jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<List<UserModel>> _getCachedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_users');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de usuarios: $e');
      return [];
    }
  }

  Future<UserModel> _getCachedUser(String authUserId) async {
    final users = await _getCachedUsers();
    return users.firstWhere((u) => u.authUserId == authUserId, orElse: () => throw Exception('Usuario no encontrado en caché'));
  }

  Future<void> _cacheUserSearch(String query, List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_search_${query.toLowerCase()}', jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<List<UserModel>> _getCachedUserSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_search_${query.toLowerCase()}');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de búsqueda de usuarios: $e');
      return [];
    }
  }
}