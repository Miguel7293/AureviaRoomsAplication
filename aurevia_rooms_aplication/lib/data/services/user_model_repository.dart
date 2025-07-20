// lib/data/services/user_model_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/user_model.dart';

class UserModelRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;

  static const _cacheKey = 'all_users_cache';

  UserModelRepository(this._connectionProvider)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  // --- CREATE ---
  Future<UserModel> createUser(UserModel user) async {
    await _guardConnection();
    final response = await _retryOptions.retry(() => _client.from('users').insert(user.toJson()).select().single());
    final newUser = UserModel.fromJson(response);
    await _addOrUpdateCache([newUser]);
    return newUser;
  }

  // --- UPDATE ---
  Future<UserModel> updateUser(UserModel user) async {
    await _guardConnection();
    final response = await _retryOptions.retry(() => _client.from('users').update(user.toJson()).eq('auth_user_id', user.authUserId).select().single());
    final updatedUser = UserModel.fromJson(response);
    await _addOrUpdateCache([updatedUser]);
    return updatedUser;
  }

  // --- DELETE ---
  Future<void> deleteUser(String authUserId) async {
    await _guardConnection();
    await _retryOptions.retry(() => _client.from('users').delete().eq('auth_user_id', authUserId));
    await _removeUserFromCache(authUserId);
  }

  // --- GETTERS ---
  Future<UserModel> getUserById(String authUserId) async {
    final cachedUsers = await _getUsersFromCache();
    if (!await _connectionProvider.isConnected) {
      if (cachedUsers.containsKey(authUserId)) return cachedUsers[authUserId]!;
      throw Exception('Usuario no encontrado en caché.');
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('users').select().eq('auth_user_id', authUserId).single());
      final user = UserModel.fromJson(response);
      await _addOrUpdateCache([user]);
      return user;
    } catch (e) {
      debugPrint('❌ Error obteniendo usuario por ID, intentando desde caché: $e');
      if (cachedUsers.containsKey(authUserId)) return cachedUsers[authUserId]!;
      throw Exception('Usuario no encontrado en API ni en caché.');
    }
  }

  Future<UserModel> getAuthenticatedUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('Usuario no autenticado');
    return getUserById(authUser.id);
  }

  // --- SEARCH ---
  Future<List<UserModel>> searchUsers(String query) async {
    final lowerCaseQuery = query.toLowerCase();
    final cachedUsers = await _getUsersFromCache();
    
    bool searchFilter(UserModel u) =>
        u.username.toLowerCase().contains(lowerCaseQuery) ||
        u.email.toLowerCase().contains(lowerCaseQuery);

    if (!await _connectionProvider.isConnected) {
      return cachedUsers.values.where(searchFilter).toList();
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('users').select().or('username.ilike.%$query%,email.ilike.%$query%'),
      );
      final users = (response as List).map((json) => UserModel.fromJson(json)).toList();
      await _addOrUpdateCache(users);
      return users;
    } catch (e) {
      debugPrint('❌ Error buscando usuarios, filtrando desde caché: $e');
      return cachedUsers.values.where(searchFilter).toList();
    }
  }

  // --- MÉTODOS PRIVADOS ---
  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) throw Exception('No hay conexión a internet.');
  }

  Future<Map<String, UserModel>> _getUsersFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};
      final list = (jsonDecode(data) as List).map((json) => UserModel.fromJson(json));
      return {for (var user in list) user.authUserId: user};
    } catch (e) {
      debugPrint('⚠️ Error al leer caché de usuarios: $e');
      return {};
    }
  }

  Future<void> _addOrUpdateCache(List<UserModel> users) async {
    final cachedMap = await _getUsersFromCache();
    for (var user in users) {
      cachedMap[user.authUserId] = user;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cachedMap.values.map((u) => u.toJson()).toList()));
  }

  Future<void> _removeUserFromCache(String authUserId) async {
    final cachedMap = await _getUsersFromCache();
    cachedMap.remove(authUserId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cachedMap.values.map((u) => u.toJson()).toList()));
  }
}