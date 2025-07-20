// lib/data/services/review_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;

  // Clave única para el caché centralizado de reseñas.
  static const _cacheKey = 'all_reviews_cache';

  ReviewRepository(this._connectionProvider)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));
  
  // --- MÉTODOS PÚBLICOS (API del Repositorio) ---

  Future<Review> createReview(Review review) async {
    await _guardConnection(); // 3ra mejora: Guard clause
    
    // El modelo freezed genera el toJson(), no necesitas el parámetro includeId
    final response = await _retryOptions.retry(
      () => _client.from('reviews').insert(review.toJson()).select().single(),
    );
    
    final newReview = Review.fromJson(response);
    await _addOrUpdateCache([newReview]); // Actualiza el caché central
    return newReview;
  }

  Future<Review> updateReview(Review review) async {
    await _guardConnection();
    
    if (review.reviewId == null) {
      throw Exception('El reviewId no puede ser null para una actualización.');
    }

    final response = await _retryOptions.retry(
      () => _client
          .from('reviews')
          .update(review.toJson())
          .eq('review_id', review.reviewId!)
          .select()
          .single(),
    );

    final updatedReview = Review.fromJson(response);
    await _addOrUpdateCache([updatedReview]); // Actualiza el caché central
    return updatedReview;
  }

  Future<void> deleteReview(int reviewId) async {
    await _guardConnection();

    await _retryOptions.retry(
      () => _client.from('reviews').delete().eq('review_id', reviewId),
    );

    await _removeReviewFromCache(reviewId); // Elimina del caché central
  }

  Future<Review> getReviewById(int reviewId) async {
    // Si no hay conexión, intenta obtener del caché.
    if (!await _connectionProvider.isConnected) {
      final cachedReviews = await _getReviewsFromCache();
      final review = cachedReviews[reviewId];
      if (review == null) throw Exception('Reseña no encontrada en caché');
      return review;
    }

    // Si hay conexión, obtiene de Supabase y actualiza el caché.
    try {
      final response = await _retryOptions.retry(
        () => _client.from('reviews').select().eq('review_id', reviewId).single(),
      );
      final review = Review.fromJson(response);
      await _addOrUpdateCache([review]); // Actualiza el caché central
      return review;
    } catch (e) {
      debugPrint('❌ Error obteniendo reseña de la API, intentando desde caché: $e');
      final cachedReviews = await _getReviewsFromCache();
      final review = cachedReviews[reviewId];
      if (review == null) throw Exception('Reseña no encontrada en API ni en caché');
      return review;
    }
  }

  Future<List<Review>> getReviewsByStay(int stayId) async {
    final cachedReviews = await _getReviewsFromCache();

    // Si no hay conexión, filtra desde el caché.
    if (!await _connectionProvider.isConnected) {
      return cachedReviews.values.where((r) => r.stayId == stayId).toList();
    }
    
    // Si hay conexión, obtiene de Supabase, actualiza el caché y luego filtra.
    try {
      final response = await _retryOptions.retry(
        () => _client.from('reviews').select().eq('stay_id', stayId),
      );
      final reviews = (response as List).map((json) => Review.fromJson(json)).toList();
      await _addOrUpdateCache(reviews); // Actualiza el caché central
      return reviews;
    } catch (e) {
      debugPrint('❌ Error obteniendo reseñas de estancia, filtrando desde caché: $e');
      return cachedReviews.values.where((r) => r.stayId == stayId).toList();
    }
  }

  Future<List<Review>> getReviewsByUser(String userId) async {
    final cachedReviews = await _getReviewsFromCache();

    if (!await _connectionProvider.isConnected) {
      return cachedReviews.values.where((r) => r.userId == userId).toList();
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('reviews').select().eq('user_id', userId),
      );
      final reviews = (response as List).map((json) => Review.fromJson(json)).toList();
      await _addOrUpdateCache(reviews);
      return reviews;
    } catch (e) {
      debugPrint('❌ Error obteniendo reseñas de usuario, filtrando desde caché: $e');
      return cachedReviews.values.where((r) => r.userId == userId).toList();
    }
  }

  // --- MÉTODOS PRIVADOS (Lógica Interna) ---

  /// 3ra mejora: Cláusula de guarda para verificar la conexión y evitar repetir código.
  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet. La operación no puede continuar.');
    }
  }

  /// Lee el caché central y lo devuelve como un Mapa para acceso rápido.
  Future<Map<int, Review>> _getReviewsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};

      final list = (jsonDecode(data) as List).map((json) => Review.fromJson(json));
      return {for (var review in list) review.reviewId!: review};
    } catch (e) {
      debugPrint('⚠️ Error recuperando el caché de reseñas: $e');
      return {}; // Devuelve un mapa vacío en caso de error.
    }
  }
  
  /// Escribe un mapa de reseñas en el caché central.
  Future<void> _saveReviewsToCache(Map<int, Review> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    final listToStore = reviews.values.map((r) => r.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(listToStore));
  }

  /// Agrega o actualiza una lista de reseñas en el caché central.
  Future<void> _addOrUpdateCache(List<Review> reviews) async {
    final cachedMap = await _getReviewsFromCache();
    for (var review in reviews) {
      if (review.reviewId != null) {
        cachedMap[review.reviewId!] = review;
      }
    }
    await _saveReviewsToCache(cachedMap);
  }

  /// Elimina una reseña del caché central por su ID.
  Future<void> _removeReviewFromCache(int reviewId) async {
    final cachedMap = await _getReviewsFromCache();
    cachedMap.remove(reviewId);
    await _saveReviewsToCache(cachedMap);
  }
}