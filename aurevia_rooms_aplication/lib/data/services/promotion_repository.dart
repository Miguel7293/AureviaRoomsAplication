// lib/data/services/promotion_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/promotion_model.dart';

class PromotionRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;

  static const _cacheKey = 'all_promotions_cache';

  PromotionRepository(this._connectionProvider)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));
  
  Future<Promotion> createPromotion(Promotion promotion) async {
    await _guardConnection();
    final response = await _retryOptions.retry(
      () => _client.from('promotions').insert(promotion.toJson()).select().single(),
    );
    final newPromotion = Promotion.fromJson(response);
    await _addOrUpdateCache([newPromotion]);
    return newPromotion;
  }

  Future<Promotion> updatePromotion(Promotion promotion) async {
    await _guardConnection();
    if (promotion.promotionId == null) throw Exception('El promotionId es requerido.');
    
    final response = await _retryOptions.retry(
      () => _client.from('promotions').update(promotion.toJson()).eq('promotion_id', promotion.promotionId!).select().single(),
    );
    final updatedPromotion = Promotion.fromJson(response);
    await _addOrUpdateCache([updatedPromotion]);
    return updatedPromotion;
  }

  Future<void> deletePromotion(String promotionId) async {
    await _guardConnection();
    await _retryOptions.retry(
      () => _client.from('promotions').delete().eq('promotion_id', promotionId),
    );
    await _removePromotionFromCache(promotionId);
  }

  Future<List<Promotion>> getActivePromotionsByStay(int stayId) async {
    final now = DateTime.now();

    bool isPromotionActive(Promotion p) {
      return p.stayId == stayId &&
             p.state == 'active' &&
             (p.startDate.isBefore(now) || p.startDate.isAtSameMomentAs(now)) &&
             (p.endDate.isAfter(now) || p.endDate.isAtSameMomentAs(now));
    }

    final cachedPromotions = await _getPromotionsFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedPromotions.values.where(isPromotionActive).toList();
    }

    try {
      final response = await _retryOptions.retry(() => _client.from('promotions')
          .select()
          .eq('stay_id', stayId)
          .eq('state', 'active')
          .lte('start_date', now.toIso8601String())
          .gte('end_date', now.toIso8601String()));
      final promotions = (response as List).map((json) => Promotion.fromJson(json)).toList();
      await _addOrUpdateCache(promotions);
      return promotions;
    } catch (e) {
      debugPrint('❌ Error obteniendo promociones, filtrando desde caché: $e');
      return cachedPromotions.values.where(isPromotionActive).toList();
    }
  }

  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) throw Exception('No hay conexión a internet.');
  }

  Future<Map<String, Promotion>> _getPromotionsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};
      final list = (jsonDecode(data) as List).map((json) => Promotion.fromJson(json));
      return {for (var promo in list) promo.promotionId!: promo};
    } catch (e) {
      debugPrint('⚠️ Error al leer caché de promociones: $e');
      return {};
    }
  }

  Future<void> _addOrUpdateCache(List<Promotion> promotions) async {
    final cachedMap = await _getPromotionsFromCache();
    for (var promo in promotions) {
      if (promo.promotionId != null) {
        cachedMap[promo.promotionId!] = promo;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final listToStore = cachedMap.values.map((p) => p.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(listToStore));
  }

  Future<void> _removePromotionFromCache(String promotionId) async {
    final cachedMap = await _getPromotionsFromCache();
    cachedMap.remove(promotionId);
    final prefs = await SharedPreferences.getInstance();
    final listToStore = cachedMap.values.map((p) => p.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(listToStore));
  }
}