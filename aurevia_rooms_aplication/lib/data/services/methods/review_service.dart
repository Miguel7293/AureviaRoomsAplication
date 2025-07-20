// lib/data/services/usage/methods/review_service.dart

import 'package:aureviarooms/data/models/review_model.dart';
import 'package:aureviarooms/data/services/review_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';


class ReviewService {
  static Future<Review?> createReview({
    required BuildContext context,
    required int stayId,
    required int rating,
    String? comment,
  }) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      debugPrint('⚠️ Usuario no autenticado');
      return null;
    }
    final reviewRepo = context.read<ReviewRepository>();
    final review = Review(
      userId: userId,
      stayId: stayId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    try {
      return await reviewRepo.createReview(review);
    } catch (e) {
      debugPrint('❌ Error creando reseña: $e');
      return null;
    }
  }

  // --- MÉTODOS AÑADIDOS ---
  static Future<Review?> updateReview({
    required BuildContext context,
    required Review reviewToUpdate,
  }) async {
    try {
      return await context.read<ReviewRepository>().updateReview(reviewToUpdate);
    } catch (e) {
      debugPrint('❌ Error actualizando la reseña: $e');
      return null;
    }
  }

  static Future<bool> deleteReview({
    required BuildContext context,
    required int reviewId,
  }) async {
    try {
      await context.read<ReviewRepository>().deleteReview(reviewId);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando la reseña: $e');
      return false;
    }
  }

  static Future<Review?> getReviewById({
    required BuildContext context,
    required int reviewId,
  }) async {
    try {
      return await context.read<ReviewRepository>().getReviewById(reviewId);
    } catch (e) {
      debugPrint('❌ Error obteniendo reseña por ID: $e');
      return null;
    }
  }

  // --- MÉTODOS EXISTENTES ---
  static Future<List<Review>> getReviewsByStay({
    required BuildContext context,
    required int stayId,
  }) async {
    try {
      return await context.read<ReviewRepository>().getReviewsByStay(stayId);
    } catch (e) {
      debugPrint('❌ Error consultando reseñas del alojamiento: $e');
      return [];
    }
  }

  static Future<List<Review>> getReviewsByUser({
    required BuildContext context,
  }) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      debugPrint('⚠️ Usuario no autenticado');
      return [];
    }
    try {
      return await context.read<ReviewRepository>().getReviewsByUser(userId);
    } catch (e) {
      debugPrint('❌ Error consultando reseñas del usuario: $e');
      return [];
    }
  }
}