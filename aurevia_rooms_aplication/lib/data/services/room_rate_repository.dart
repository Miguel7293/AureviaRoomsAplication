// room_rate_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/data/models/room_rate_model.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';

class RoomRateRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  RoomRateRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<RoomRate> createRoomRate(RoomRate rate) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('room_rates').insert(rate.toJson()).select().single(),
    );

    final newRate = RoomRate.fromJson(response);
    await _cacheRate(newRate);
    return newRate;
  }

Future<RoomRate> updateRoomRate(RoomRate rate) async {
  if (!await _connectionProvider.isConnected) {
    throw Exception('No hay conexión a internet');
  }

  if (rate.id == null) {
    throw Exception('El id de RoomRate no puede ser null para actualizar.');
  }

  final response = await _retryOptions.retry(
    () => _client
        .from('room_rates')
        .update(rate.toJson())
        .eq('id', rate.id!)
        .select()
        .single(),
  );

  final updatedRate = RoomRate.fromJson(response);
  await _cacheRate(updatedRate);
  return updatedRate;
}


  Future<void> deleteRoomRate(int rateId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('room_rates').delete().eq('id', rateId),
    );

    await _removeCachedRate(rateId);
  }

  Future<RoomRate> getRateById(int rateId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedRate(rateId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('room_rates').select().eq('id', rateId).single(),
      );

      final rate = RoomRate.fromJson(response);
      await _cacheRate(rate);
      return rate;
    } catch (e) {
      debugPrint('❌ Error obteniendo tarifa: $e');
      return _getCachedRate(rateId);
    }
  }

  Future<List<RoomRate>> getRatesByRoom(int roomId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedRoomRates(roomId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('room_rates').select().eq('room_id', roomId),
      );

      final rates = (response as List).map((json) => RoomRate.fromJson(json)).toList();
      await _cacheRoomRates(roomId, rates);
      return rates;
    } catch (e) {
      debugPrint('❌ Error obteniendo tarifas de habitación: $e');
      return _getCachedRoomRates(roomId);
    }
  }

Future<List<RoomRate>> getActiveRatesByRoom(int roomId) async {
  if (!await _connectionProvider.isConnected) {
    return _getCachedActiveRates(roomId);
  }

  try {
    final response = await _retryOptions.retry(
      () => _client
          .from('room_rates')
          .select()
          .eq('room_id', roomId)
          .filter('promotion_id', 'is', null),
    );

    final rates = (response as List).map((json) => RoomRate.fromJson(json)).toList();
    await _cacheActiveRates(roomId, rates);
    return rates;
  } catch (e) {
    debugPrint('❌ Error obteniendo tarifas activas: $e');
    return _getCachedActiveRates(roomId);
  }
}


  // Caché methods
  Future<void> _cacheRate(RoomRate rate) async {
    final prefs = await SharedPreferences.getInstance();
    final rates = await _getCachedRates();
    final index = rates.indexWhere((r) => r.id == rate.id);
    
    if (index != -1) {
      rates[index] = rate;
    } else {
      rates.add(rate);
    }
    
    await prefs.setString('cached_rates', jsonEncode(rates.map((r) => r.toJson()).toList()));
  }

  Future<void> _removeCachedRate(int rateId) async {
    final prefs = await SharedPreferences.getInstance();
    final rates = await _getCachedRates();
    rates.removeWhere((r) => r.id == rateId);
    await prefs.setString('cached_rates', jsonEncode(rates.map((r) => r.toJson()).toList()));
  }

  Future<List<RoomRate>> _getCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_rates');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => RoomRate.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de tarifas: $e');
      return [];
    }
  }

  Future<RoomRate> _getCachedRate(int rateId) async {
    final rates = await _getCachedRates();
    return rates.firstWhere((r) => r.id == rateId, orElse: () => throw Exception('Tarifa no encontrada en caché'));
  }

  Future<void> _cacheRoomRates(int roomId, List<RoomRate> rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('room_rates_$roomId', jsonEncode(rates.map((r) => r.toJson()).toList()));
  }

  Future<List<RoomRate>> _getCachedRoomRates(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('room_rates_$roomId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => RoomRate.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de tarifas de habitación: $e');
      return [];
    }
  }

  Future<void> _cacheActiveRates(int roomId, List<RoomRate> rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_rates_$roomId', jsonEncode(rates.map((r) => r.toJson()).toList()));
  }

  Future<List<RoomRate>> _getCachedActiveRates(int roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('active_rates_$roomId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => RoomRate.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de tarifas activas: $e');
      return [];
    }
  }
}