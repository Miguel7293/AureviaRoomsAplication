// review_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/data/models/review_model.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';

class ReviewRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  ReviewRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<Review> createReview(Review review) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('reviews').insert(review.toJson()).select().single(),
    );

    final newReview = Review.fromJson(response);
    await _cacheReview(newReview);
    return newReview;
  }

Future<Review> updateReview(Review review) async {
  if (!await _connectionProvider.isConnected) {
    throw Exception('No hay conexión a internet');
  }

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
  await _cacheReview(updatedReview);
  return updatedReview;
}


  Future<void> deleteReview(int reviewId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('reviews').delete().eq('review_id', reviewId),
    );

    await _removeCachedReview(reviewId);
  }

  Future<Review> getReviewById(int reviewId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedReview(reviewId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('reviews').select().eq('review_id', reviewId).single(),
      );

      final review = Review.fromJson(response);
      await _cacheReview(review);
      return review;
    } catch (e) {
      debugPrint('❌ Error obteniendo reseña: $e');
      return _getCachedReview(reviewId);
    }
  }

  Future<List<Review>> getReviewsByStay(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedStayReviews(stayId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('reviews').select().eq('stay_id', stayId),
      );

      final reviews = (response as List).map((json) => Review.fromJson(json)).toList();
      await _cacheStayReviews(stayId, reviews);
      return reviews;
    } catch (e) {
      debugPrint('❌ Error obteniendo reseñas de alojamiento: $e');
      return _getCachedStayReviews(stayId);
    }
  }

  Future<List<Review>> getReviewsByUser(String userId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedUserReviews(userId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('reviews').select().eq('user_id', userId),
      );

      final reviews = (response as List).map((json) => Review.fromJson(json)).toList();
      await _cacheUserReviews(userId, reviews);
      return reviews;
    } catch (e) {
      debugPrint('❌ Error obteniendo reseñas de usuario: $e');
      return _getCachedUserReviews(userId);
    }
  }

  // Caché methods
  Future<void> _cacheReview(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final reviews = await _getCachedReviews();
    final index = reviews.indexWhere((r) => r.reviewId == review.reviewId);
    
    if (index != -1) {
      reviews[index] = review;
    } else {
      reviews.add(review);
    }
    
    await prefs.setString('cached_reviews', jsonEncode(reviews.map((r) => r.toJson()).toList()));
  }

  Future<void> _removeCachedReview(int reviewId) async {
    final prefs = await SharedPreferences.getInstance();
    final reviews = await _getCachedReviews();
    reviews.removeWhere((r) => r.reviewId == reviewId);
    await prefs.setString('cached_reviews', jsonEncode(reviews.map((r) => r.toJson()).toList()));
  }

  Future<List<Review>> _getCachedReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_reviews');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de reseñas: $e');
      return [];
    }
  }

  Future<Review> _getCachedReview(int reviewId) async {
    final reviews = await _getCachedReviews();
    return reviews.firstWhere((r) => r.reviewId == reviewId, orElse: () => throw Exception('Reseña no encontrada en caché'));
  }

  Future<void> _cacheStayReviews(int stayId, List<Review> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stay_reviews_$stayId', jsonEncode(reviews.map((r) => r.toJson()).toList()));
  }

  Future<List<Review>> _getCachedStayReviews(int stayId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('stay_reviews_$stayId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de reseñas de alojamiento: $e');
      return [];
    }
  }

  Future<void> _cacheUserReviews(String userId, List<Review> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_reviews_$userId', jsonEncode(reviews.map((r) => r.toJson()).toList()));
  }

  Future<List<Review>> _getCachedUserReviews(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_reviews_$userId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de reseñas de usuario: $e');
      return [];
    }
  }
}