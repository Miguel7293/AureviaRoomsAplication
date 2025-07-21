// lib/data/services/room_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/room_model.dart';

class RoomRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;

  static const _cacheKey = 'all_rooms_cache';

  RoomRepository(this._connectionProvider)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));
  
  // --- MÉTODOS PÚBLICOS ---

  Future<Room> createRoom(Room room) async {
    await _guardConnection();
    final response = await _retryOptions.retry(
      () => _client.from('rooms').insert(room.toJson()).select().single(),
    );
    final newRoom = Room.fromJson(response);
    await _addOrUpdateCache([newRoom]);
    return newRoom;
  }

  Future<Room> updateRoom(Room room) async {
    await _guardConnection();
    if (room.roomId == null) throw Exception('El roomId es requerido para actualizar.');

    final response = await _retryOptions.retry(
      () => _client.from('rooms').update(room.toJson()).eq('room_id', room.roomId!).select().single(),
    );
    final updatedRoom = Room.fromJson(response);
    await _addOrUpdateCache([updatedRoom]);
    return updatedRoom;
  }

  Future<void> deleteRoom(int roomId) async {
    await _guardConnection();
    await _retryOptions.retry(
      () => _client.from('rooms').delete().eq('room_id', roomId),
    );
    await _removeRoomFromCache(roomId);
  }

  Future<List<Room>> getRoomsByStay(int stayId) async {
    final cachedRooms = await _getRoomsFromCache();
    if (!await _connectionProvider.isConnected) {
      return cachedRooms.values.where((r) => r.stayId == stayId).toList();
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('rooms').select().eq('stay_id', stayId));
      final rooms = (response as List).map((json) => Room.fromJson(json)).toList();
      await _addOrUpdateCache(rooms);
      return rooms;
    } catch (e) {
      debugPrint('❌ Error obteniendo habitaciones, filtrando desde caché: $e');
      return cachedRooms.values.where((r) => r.stayId == stayId).toList();
    }
  }

    Future<Room> getRoomById(int roomId) async {
    // Si no hay conexión, intenta obtener del caché.
    if (!await _connectionProvider.isConnected) {
      final cachedRooms = await _getRoomsFromCache();
      final room = cachedRooms[roomId];
      if (room == null) throw Exception('Habitación no encontrada en caché');
      return room;
    }

    // Si hay conexión, obtiene de Supabase y actualiza el caché.
    try {
      final response = await _retryOptions.retry(
        () => _client.from('rooms').select().eq('room_id', roomId).single(),
      );
      final room = Room.fromJson(response);
      await _addOrUpdateCache([room]); // Actualiza el caché central
      return room;
    } catch (e) {
      debugPrint('❌ Error obteniendo habitación de la API, intentando desde caché: $e');
      final cachedRooms = await _getRoomsFromCache();
      final room = cachedRooms[roomId];
      if (room == null) throw Exception('Habitación no encontrada en API ni en caché');
      return room;
    }
  }

  Future<List<Room>> getAvailableRoomsByStay(int stayId) async {
  // Define el filtro para la lógica offline
  bool isRoomAvailable(Room r) => r.stayId == stayId && r.availabilityStatus == 'available';

  final cachedRooms = await _getRoomsFromCache();
  if (!await _connectionProvider.isConnected) {
    return cachedRooms.values.where(isRoomAvailable).toList();
  }

  try {
    // Consulta a Supabase con doble filtro
    final response = await _retryOptions.retry(
      () => _client
          .from('rooms')
          .select()
          .eq('stay_id', stayId)
          .eq('availability_status', 'available'),
    );
    final rooms = (response as List).map((json) => Room.fromJson(json)).toList();
    await _addOrUpdateCache(rooms); // Actualiza el caché con los datos frescos
    return rooms;
  } catch (e) {
    debugPrint('❌ Error obteniendo habitaciones disponibles, filtrando desde caché: $e');
    return cachedRooms.values.where(isRoomAvailable).toList();
  }
}

  // --- MÉTODOS PRIVADOS ---

  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet.');
    }
  }

  Future<Map<int, Room>> _getRoomsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};
      final list = (jsonDecode(data) as List).map((json) => Room.fromJson(json));
      return {for (var room in list) room.roomId!: room};
    } catch (e) {
      debugPrint('⚠️ Error al leer caché de habitaciones: $e');
      return {};
    }
  }

  Future<void> _saveRoomsToCache(Map<int, Room> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final listToStore = rooms.values.map((r) => r.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(listToStore));
  }

  Future<void> _addOrUpdateCache(List<Room> rooms) async {
    final cachedMap = await _getRoomsFromCache();
    for (var room in rooms) {
      if (room.roomId != null) {
        cachedMap[room.roomId!] = room;
      }
    }
    await _saveRoomsToCache(cachedMap);
  }

  Future<void> _removeRoomFromCache(int roomId) async {
    final cachedMap = await _getRoomsFromCache();
    cachedMap.remove(roomId);
    await _saveRoomsToCache(cachedMap);
  }


}