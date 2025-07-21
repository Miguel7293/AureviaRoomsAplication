// lib/data/services/usage/methods/room_rate_service.dart

import 'package:aureviarooms/data/models/room_rate_model.dart';
import 'package:aureviarooms/data/services/room_rate_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomRateService {
  static Future<RoomRate?> createRate({
    required BuildContext context,
    required int roomId,
    required String rateType,
    required double price,
  }) async {
    final repo = context.read<RoomRateRepository>();
    final newRate = RoomRate(
      roomId: roomId,
      rateType: 'day',
      price: price,
      createdAt: DateTime.now(),
    );
    try {
      return await repo.createRoomRate(newRate);
    } catch (e) {
      debugPrint('❌ Error creando tarifa: $e');
      return null;
    }
  }

  static Future<RoomRate?> updateRatePrice({
    required BuildContext context,
    required int rateId,
    required double newPrice,
  }) async {
    final repo = context.read<RoomRateRepository>();
    try {
      // Obtenemos la tarifa actual para no perder otros datos
      final rates = await repo.getRatesByRoom(rateId); // Asumiendo que getRatesByRoom devuelve una lista que podemos filtrar
      final currentRate = rates.firstWhere((rate) => rate.id == rateId);
      final updatedRate = currentRate.copyWith(price: newPrice);
      return await repo.updateRoomRate(updatedRate);
    } catch (e) {
      debugPrint('❌ Error actualizando precio de tarifa: $e');
      return null;
    }
  }

  static Future<bool> deleteRate({
    required BuildContext context,
    required int rateId,
  }) async {
    try {
      await context.read<RoomRateRepository>().deleteRoomRate(rateId);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando tarifa: $e');
      return false;
    }
  }

  static Future<List<RoomRate>> getRatesByRoom({
    required BuildContext context,
    required int roomId,
  }) async {
    try {
      return await context.read<RoomRateRepository>().getRatesByRoom(roomId);
    } catch (e) {
      debugPrint('❌ Error obteniendo tarifas por habitación: $e');
      return [];
    }
  }

  static Future<List<RoomRate>> getActiveRatesByRoom({
    required BuildContext context,
    required int roomId,
  }) async {
    try {
      return await context.read<RoomRateRepository>().getActiveRatesByRoom(roomId);
    } catch (e) {
      debugPrint('❌ Error obteniendo tarifas activas por habitación: $e');
      return [];
    }
  }
  
}