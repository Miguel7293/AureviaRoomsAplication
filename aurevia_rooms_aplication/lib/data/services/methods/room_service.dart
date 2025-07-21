// lib/data/services/usage/methods/room_service.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/room_model.dart';
import '../room_repository.dart';

class RoomService {
  static Future<Room?> createRoom({
    required BuildContext context,
    required int stayId,
    Map<String, dynamic>? features,
    String? imageUrl,
  }) async {
    final roomRepo = context.read<RoomRepository>();
    final newRoom = Room(
      stayId: stayId,
      availabilityStatus: 'available',
      features: features,
      roomImageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
    try {
      return await roomRepo.createRoom(newRoom);
    } catch (e) {
      debugPrint('❌ Error creando la habitación: $e');
      return null;
    }
  }

  // --- MÉTODO AÑADIDO ---
  static Future<Room?> updateRoom({
    required BuildContext context,
    required Room roomToUpdate,
  }) async {
    try {
      return await context.read<RoomRepository>().updateRoom(roomToUpdate);
    } catch (e) {
      debugPrint('❌ Error actualizando la habitación: $e');
      return null;
    }
  }

  // --- MÉTODO AÑADIDO ---
  static Future<bool> deleteRoom({
    required BuildContext context,
    required int roomId,
  }) async {
    try {
      await context.read<RoomRepository>().deleteRoom(roomId);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando la habitación: $e');
      return false;
    }
  }

  static Future<List<Room>> getRoomsByStay({
    required BuildContext context,
    required int stayId,
  }) async {
    try {
      return await context.read<RoomRepository>().getRoomsByStay(stayId);
    } catch (e) {
      debugPrint('❌ Error obteniendo las habitaciones del alojamiento: $e');
      return [];
    }
  }

    static Future<Room?> getRoomById({
    required BuildContext context,
    required int roomId,
  }) async {
    try {
      // Llama al nuevo método del repositorio
      return await context.read<RoomRepository>().getRoomById(roomId);
    } catch (e) {
      debugPrint('❌ Error obteniendo habitación por ID: $e');
      return null;
    }
  }

  static Future<List<Room>> getAvailableRoomsByStay({
  required BuildContext context,
  required int stayId,
}) async {
  try {
    return await context.read<RoomRepository>().getAvailableRoomsByStay(stayId);
  } catch (e) {
    debugPrint('❌ Error obteniendo las habitaciones disponibles: $e');
    return [];
  }
}
static Future<List<Room>> getRoomsByStayIds({
  required BuildContext context,
  required List<int> stayIds,
}) async {
  try {
    return await context.read<RoomRepository>().getRoomsByStayIds(stayIds);
  } catch (e) {
    debugPrint('❌ Error obteniendo rooms por stayIds: $e');
    return [];
  }
}

}