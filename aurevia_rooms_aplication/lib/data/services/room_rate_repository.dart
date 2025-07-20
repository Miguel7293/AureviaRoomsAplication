// lib/data/services/room_rate_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/room_rate_model.dart';

class RoomRateRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;

  static const _cacheKey = 'all_room_rates_cache';

  RoomRateRepository(this._connectionProvider)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<RoomRate> createRoomRate(RoomRate rate) async {
    await _guardConnection();
    final response = await _retryOptions.retry(() => _client.from('room_rates').insert(rate.toJson()).select().single());
    final newRate = RoomRate.fromJson(response);
    await _addOrUpdateCache([newRate]);
    return newRate;
  }

    Future<List<RoomRate>> getActiveRatesByRoom(int roomId) async {
    // Filtro para tarifas sin promoción
    bool isRateActive(RoomRate r) => r.roomId == roomId && r.promotionId == null;

    final cachedRates = await _getRatesFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedRates.values.where(isRateActive).toList();
    }

    try {
      final response = await _retryOptions.retry(
        () => _client
            .from('room_rates')
            .select()
            .eq('room_id', roomId)
            // USANDO .filter() QUE ES COMPATIBLE CON TU VERSIÓN
            .filter('promotion_id', 'is', null),
      );
      final rates = (response as List).map((json) => RoomRate.fromJson(json)).toList();
      await _addOrUpdateCache(rates);
      return rates;
    } catch (e) {
      debugPrint('❌ Error obteniendo tarifas activas, filtrando desde caché: $e');
      return cachedRates.values.where(isRateActive).toList();
    }
  }

  Future<RoomRate> updateRoomRate(RoomRate rate) async {
    await _guardConnection();
    if (rate.id == null) throw Exception('El id de RoomRate es requerido para actualizar.');
    
    final response = await _retryOptions.retry(() => _client.from('room_rates').update(rate.toJson()).eq('id', rate.id!).select().single());
    final updatedRate = RoomRate.fromJson(response);
    await _addOrUpdateCache([updatedRate]);
    return updatedRate;
  }

  Future<void> deleteRoomRate(int rateId) async {
    await _guardConnection();
    await _retryOptions.retry(() => _client.from('room_rates').delete().eq('id', rateId));
    await _removeRateFromCache(rateId);
  }

  Future<List<RoomRate>> getRatesByRoom(int roomId) async {
    final cachedRates = await _getRatesFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedRates.values.where((r) => r.roomId == roomId).toList();
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('room_rates').select().eq('room_id', roomId));
      final rates = (response as List).map((json) => RoomRate.fromJson(json)).toList();
      await _addOrUpdateCache(rates);
      return rates;
    } catch (e) {
      debugPrint('❌ Error obteniendo tarifas, filtrando desde caché: $e');
      return cachedRates.values.where((r) => r.roomId == roomId).toList();
    }
  }



  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) throw Exception('No hay conexión a internet.');
  }

  Future<Map<int, RoomRate>> _getRatesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};
      final list = (jsonDecode(data) as List).map((json) => RoomRate.fromJson(json));
      return {for (var rate in list) rate.id!: rate};
    } catch (e) {
      debugPrint('⚠️ Error al leer caché de tarifas: $e');
      return {};
    }
  }

  Future<void> _addOrUpdateCache(List<RoomRate> rates) async {
    final cachedMap = await _getRatesFromCache();
    for (var rate in rates) {
      if (rate.id != null) cachedMap[rate.id!] = rate;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cachedMap.values.map((r) => r.toJson()).toList()));
  }

  Future<void> _removeRateFromCache(int rateId) async {
    final cachedMap = await _getRatesFromCache();
    cachedMap.remove(rateId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cachedMap.values.map((r) => r.toJson()).toList()));
  }
}