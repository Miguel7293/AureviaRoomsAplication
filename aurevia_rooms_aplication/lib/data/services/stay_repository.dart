// lib/data/services/stay_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/stay_model.dart';

class StayRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;

  static const _cacheKey = 'all_stays_cache';

  StayRepository(this._connectionProvider)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));
  
  // --- MÉTODOS PÚBLICOS ---

  Future<Stay> createStay(Stay stay) async {
    await _guardConnection();
    final response = await _retryOptions.retry(
      () => _client.from('stays').insert(stay.toJson()).select().single(),
    );
    final newStay = Stay.fromJson(response);
    await _addOrUpdateCache([newStay]);
    return newStay;
  }

  Future<Stay> updateStay(Stay stay) async {
    await _guardConnection();
    if (stay.stayId == null) throw Exception('El stayId es requerido para actualizar.');
    
    final response = await _retryOptions.retry(
      () => _client.from('stays').update(stay.toJson()).eq('stay_id', stay.stayId!).select().single(),
    );
    final updatedStay = Stay.fromJson(response);
    await _addOrUpdateCache([updatedStay]);
    return updatedStay;
  }

  Future<void> deleteStay(int stayId) async {
    await _guardConnection();
    await _retryOptions.retry(
      () => _client.from('stays').delete().eq('stay_id', stayId),
    );
    await _removeStayFromCache(stayId);
  }

  Future<Stay> getStayById(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      final cachedStays = await _getStaysFromCache();
      final stay = cachedStays[stayId];
      if (stay == null) throw Exception('Alojamiento no encontrado en caché.');
      return stay;
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('stays').select().eq('stay_id', stayId).single());
      final stay = Stay.fromJson(response);
      await _addOrUpdateCache([stay]);
      return stay;
    } catch (e) {
      debugPrint('❌ Error obteniendo alojamiento por ID, intentando desde caché: $e');
      final cachedStays = await _getStaysFromCache();
      final stay = cachedStays[stayId];
      if (stay == null) throw Exception('Alojamiento no encontrado en API ni caché.');
      return stay;
    }
  }

  Future<List<Stay>> searchStays(String query) async {
    final cachedStays = await _getStaysFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedStays.values
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    try {
      final response = await _retryOptions.retry(
        () => _client.from('stays').select().ilike('name', '%$query%'),
      );
      final stays = (response as List).map((json) => Stay.fromJson(json)).toList();
      await _addOrUpdateCache(stays);
      return stays;
    } catch (e) {
      debugPrint('❌ Error buscando alojamientos, filtrando desde caché: $e');
      return cachedStays.values
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
  

  Future<List<Stay>> getAllPublishedStays() async {
    final cachedStays = await _getStaysFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedStays.values.where((s) => s.status == 'published').toList();
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('stays').select().eq('status', 'published'));
      final stays = (response as List).map((json) => Stay.fromJson(json)).toList();
      await _addOrUpdateCache(stays);
      return stays;
    } catch (e) {
      debugPrint('❌ Error obteniendo alojamientos publicados, filtrando desde caché: $e');
      return cachedStays.values.where((s) => s.status == 'published').toList();
    }
  }

  Future<List<Stay>> getStaysByOwner(String ownerId) async {
    final cachedStays = await _getStaysFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedStays.values.where((s) => s.ownerId == ownerId).toList();
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('stays').select().eq('owner_id', ownerId));
      final stays = (response as List).map((json) => Stay.fromJson(json)).toList();
      await _addOrUpdateCache(stays);
      return stays;
    } catch (e) {
      debugPrint('❌ Error obteniendo alojamientos del propietario, filtrando desde caché: $e');
      return cachedStays.values.where((s) => s.ownerId == ownerId).toList();
    }
  }

  // --- MÉTODOS PRIVADOS ---

  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet.');
    }
  }

  Future<Map<int, Stay>> _getStaysFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};
      final list = (jsonDecode(data) as List).map((json) => Stay.fromJson(json));
      return {for (var stay in list) stay.stayId!: stay};
    } catch (e) {
      debugPrint('⚠️ Error al leer caché de alojamientos: $e');
      return {};
    }
  }
  
  Future<void> _saveStaysToCache(Map<int, Stay> stays) async {
    final prefs = await SharedPreferences.getInstance();
    final listToStore = stays.values.map((s) => s.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(listToStore));
  }

  Future<void> _addOrUpdateCache(List<Stay> stays) async {
    final cachedMap = await _getStaysFromCache();
    for (var stay in stays) {
      if (stay.stayId != null) {
        cachedMap[stay.stayId!] = stay;
      }
    }
    await _saveStaysToCache(cachedMap);
  }

  Future<void> _removeStayFromCache(int stayId) async {
    final cachedMap = await _getStaysFromCache();
    cachedMap.remove(stayId);
    await _saveStaysToCache(cachedMap);
  }
}