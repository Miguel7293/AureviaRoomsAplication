// promotion_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/data/models/promotion_model.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';

class PromotionRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  PromotionRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<Promotion> createPromotion(Promotion promotion) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('promotions').insert(promotion.toJson()).select().single(),
    );

    final newPromotion = Promotion.fromJson(response);
    await _cachePromotion(newPromotion);
    return newPromotion;
  }

  Future<Promotion> updatePromotion(Promotion promotion) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('promotions')
          .update(promotion.toJson())
          .eq('promotion_id', promotion.promotionId)
          .select()
          .single(),
    );

    final updatedPromotion = Promotion.fromJson(response);
    await _cachePromotion(updatedPromotion);
    return updatedPromotion;
  }

  Future<void> deletePromotion(String promotionId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('promotions').delete().eq('promotion_id', promotionId),
    );

    await _removeCachedPromotion(promotionId);
  }

  Future<Promotion> getPromotionById(String promotionId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedPromotion(promotionId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('promotions').select().eq('promotion_id', promotionId).single(),
      );

      final promotion = Promotion.fromJson(response);
      await _cachePromotion(promotion);
      return promotion;
    } catch (e) {
      debugPrint('❌ Error obteniendo promoción: $e');
      return _getCachedPromotion(promotionId);
    }
  }

  Future<List<Promotion>> getActivePromotionsByStay(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedStayPromotions(stayId);
    }

    try {
      final now = DateTime.now().toIso8601String();
      final response = await _retryOptions.retry(
        () => _client.from('promotions')
          .select()
          .eq('stay_id', stayId)
          .gte('end_date', now)
          .lte('start_date', now)
          .eq('state', 'Active'),
      );

      final promotions = (response as List).map((json) => Promotion.fromJson(json)).toList();
      await _cacheStayPromotions(stayId, promotions);
      return promotions;
    } catch (e) {
      debugPrint('❌ Error obteniendo promociones activas: $e');
      return _getCachedStayPromotions(stayId);
    }
  }

  // Caché methods
  Future<void> _cachePromotion(Promotion promotion) async {
    final prefs = await SharedPreferences.getInstance();
    final promotions = await _getCachedPromotions();
    final index = promotions.indexWhere((p) => p.promotionId == promotion.promotionId);
    
    if (index != -1) {
      promotions[index] = promotion;
    } else {
      promotions.add(promotion);
    }
    
    await prefs.setString('cached_promotions', jsonEncode(promotions.map((p) => p.toJson()).toList()));
  }

  Future<void> _removeCachedPromotion(String promotionId) async {
    final prefs = await SharedPreferences.getInstance();
    final promotions = await _getCachedPromotions();
    promotions.removeWhere((p) => p.promotionId == promotionId);
    await prefs.setString('cached_promotions', jsonEncode(promotions.map((p) => p.toJson()).toList()));
  }

  Future<List<Promotion>> _getCachedPromotions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_promotions');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Promotion.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de promociones: $e');
      return [];
    }
  }

  Future<Promotion> _getCachedPromotion(String promotionId) async {
    final promotions = await _getCachedPromotions();
    return promotions.firstWhere((p) => p.promotionId == promotionId, orElse: () => throw Exception('Promoción no encontrada en caché'));
  }

  Future<void> _cacheStayPromotions(int stayId, List<Promotion> promotions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stay_promotions_$stayId', jsonEncode(promotions.map((p) => p.toJson()).toList()));
  }

  Future<List<Promotion>> _getCachedStayPromotions(int stayId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('stay_promotions_$stayId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Promotion.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de promociones de alojamiento: $e');
      return [];
    }
  }
}