// stay_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';

class StayRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  StayRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<Stay> createStay(Stay stay) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('stays').insert(stay.toJson()).select().single(),
    );

    final newStay = Stay.fromJson(response);
    await _cacheStay(newStay);
    return newStay;
  }

Future<Stay> updateStay(Stay stay) async {
  if (!await _connectionProvider.isConnected) {
    throw Exception('No hay conexión a internet');
  }

  if (stay.stayId == null) {
    throw Exception('El stayId no puede ser null para una actualización.');
  }

  final response = await _retryOptions.retry(
    () => _client
        .from('stays')
        .update(stay.toJson())
        .eq('stay_id', stay.stayId!)
        .select()
        .single(),
  );

  final updatedStay = Stay.fromJson(response);
  await _cacheStay(updatedStay);
  return updatedStay;
}


  Future<void> deleteStay(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('stays').delete().eq('stay_id', stayId),
    );

    await _removeCachedStay(stayId);
  }

  Future<Stay> getStayById(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedStay(stayId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('stays').select().eq('stay_id', stayId).single(),
      );

      final stay = Stay.fromJson(response);
      await _cacheStay(stay);
      return stay;
    } catch (e) {
      debugPrint('❌ Error obteniendo alojamiento: $e');
      return _getCachedStay(stayId);
    }
  }

  Future<List<Stay>> getStaysByOwner(String ownerId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedOwnerStays(ownerId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('stays').select().eq('owner_id', ownerId),
      );

      final stays = (response as List).map((json) => Stay.fromJson(json)).toList();
      await _cacheOwnerStays(ownerId, stays);
      return stays;
    } catch (e) {
      debugPrint('❌ Error obteniendo alojamientos de propietario: $e');
      return _getCachedOwnerStays(ownerId);
    }
  }

  Future<List<Stay>> searchStays(String query) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedSearchResults(query);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('stays').select().ilike('name', '%$query%'),
      );

      final stays = (response as List).map((json) => Stay.fromJson(json)).toList();
      await _cacheSearchResults(query, stays);
      return stays;
    } catch (e) {
      debugPrint('❌ Error buscando alojamientos: $e');
      return _getCachedSearchResults(query);
    }
  }

  // Caché methods
  Future<void> _cacheStay(Stay stay) async {
    final prefs = await SharedPreferences.getInstance();
    final stays = await _getCachedStays();
    final index = stays.indexWhere((s) => s.stayId == stay.stayId);
    
    if (index != -1) {
      stays[index] = stay;
    } else {
      stays.add(stay);
    }
    
    await prefs.setString('cached_stays', jsonEncode(stays.map((s) => s.toJson()).toList()));
  }

  Future<void> _removeCachedStay(int stayId) async {
    final prefs = await SharedPreferences.getInstance();
    final stays = await _getCachedStays();
    stays.removeWhere((s) => s.stayId == stayId);
    await prefs.setString('cached_stays', jsonEncode(stays.map((s) => s.toJson()).toList()));
  }

  Future<List<Stay>> _getCachedStays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_stays');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Stay.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de alojamientos: $e');
      return [];
    }
  }

  Future<Stay> _getCachedStay(int stayId) async {
    final stays = await _getCachedStays();
    return stays.firstWhere((s) => s.stayId == stayId, orElse: () => throw Exception('Alojamiento no encontrado en caché'));
  }

  Future<void> _cacheOwnerStays(String ownerId, List<Stay> stays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('owner_stays_$ownerId', jsonEncode(stays.map((s) => s.toJson()).toList()));
  }

  Future<List<Stay>> _getCachedOwnerStays(String ownerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('owner_stays_$ownerId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Stay.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de alojamientos de propietario: $e');
      return [];
    }
  }

  Future<void> _cacheSearchResults(String query, List<Stay> stays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('search_stays_${query.toLowerCase()}', jsonEncode(stays.map((s) => s.toJson()).toList()));
  }

  Future<List<Stay>> _getCachedSearchResults(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('search_stays_${query.toLowerCase()}');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Stay.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de búsqueda: $e');
      return [];
    }
  }
}