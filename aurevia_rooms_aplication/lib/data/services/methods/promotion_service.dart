// lib/data/services/usage/methods/promotion_service.dart

import 'package:aureviarooms/data/models/promotion_model.dart';
import 'package:aureviarooms/data/services/promotion_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromotionService {
  static Future<Promotion?> createPromotion({
    required BuildContext context,
    required int stayId,
    required String description,
    required double discount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final repo = context.read<PromotionRepository>();
    final newPromotion = Promotion(
      stayId: stayId,
      description: description,
      discountPercentage: discount,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      state: 'active',
    );
    try {
      return await repo.createPromotion(newPromotion);
    } catch (e) {
      debugPrint('❌ Error creando promoción: $e');
      return null;
    }
  }

  static Future<Promotion?> updatePromotion({
    required BuildContext context,
    required Promotion promotionToUpdate,
  }) async {
    try {
      return await context.read<PromotionRepository>().updatePromotion(promotionToUpdate);
    } catch (e) {
      debugPrint('❌ Error actualizando la promoción: $e');
      return null;
    }
  }

  static Future<bool> deletePromotion({
    required BuildContext context,
    required String promotionId,
  }) async {
    try {
      await context.read<PromotionRepository>().deletePromotion(promotionId);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando promoción: $e');
      return false;
    }
  }

  static Future<List<Promotion>> getActivePromotionsByStay({
    required BuildContext context,
    required int stayId,
  }) async {
    try {
      return await context.read<PromotionRepository>().getActivePromotionsByStay(stayId);
    } catch (e) {
      debugPrint('❌ Error obteniendo promociones activas: $e');
      return [];
    }
  }
}