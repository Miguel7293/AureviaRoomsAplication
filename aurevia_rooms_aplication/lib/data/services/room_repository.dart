// room_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';

class RoomRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  RoomRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<Room> createRoom(Room room) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('rooms').insert(room.toJson()).select().single(),
    );

    final newRoom = Room.fromJson(response);
    await _cacheRoom(newRoom);
    return newRoom;
  }

Future<Room> updateRoom(Room room) async {
  if (!await _connectionProvider.isConnected) {
    throw Exception('No hay conexión a internet');
  }

  if (room.roomId == null) {
    throw Exception('El roomId no puede ser null para una actualización.');
  }

  final response = await _retryOptions.retry(
    () => _client
        .from('rooms')
        .update(room.toJson())
        .eq('room_id', room.roomId!)
        .select()
        .single(),
  );

  final updatedRoom = Room.fromJson(response);
  await _cacheRoom(updatedRoom);
  return updatedRoom;
}


  Future<void> deleteRoom(int roomId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('rooms').delete().eq('room_id', roomId),
    );

    await _removeCachedRoom(roomId);
  }

  Future<Room> getRoomById(int roomId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedRoom(roomId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('rooms').select().eq('room_id', roomId).single(),
      );

      final room = Room.fromJson(response);
      await _cacheRoom(room);
      return room;
    } catch (e) {
      debugPrint('❌ Error obteniendo habitación: $e');
      return _getCachedRoom(roomId);
    }
  }

  Future<List<Room>> getRoomsByStay(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedStayRooms(stayId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('rooms').select().eq('stay_id', stayId),
      );

      final rooms = (response as List).map((json) => Room.fromJson(json)).toList();
      await _cacheStayRooms(stayId, rooms);
      return rooms;
    } catch (e) {
      debugPrint('❌ Error obteniendo habitaciones de alojamiento: $e');
      return _getCachedStayRooms(stayId);
    }
  }

  Future<List<Room>> getAvailableRoomsByStay(int stayId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedAvailableRooms(stayId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('rooms')
          .select()
          .eq('stay_id', stayId)
          .eq('availability_status', 'Available'),
      );

      final rooms = (response as List).map((json) => Room.fromJson(json)).toList();
      await _cacheAvailableRooms(stayId, rooms);
      return rooms;
    } catch (e) {
      debugPrint('❌ Error obteniendo habitaciones disponibles: $e');
      return _getCachedAvailableRooms(stayId);
    }
  }

  // Caché methods
  Future<void> _cacheRoom(Room room) async {
    final prefs = await SharedPreferences.getInstance();
    final rooms = await _getCachedRooms();
    final index = rooms.indexWhere((r) => r.roomId == room.roomId);
    
    if (index != -1) {
      rooms[index] = room;
    } else {
      rooms.add(room);
    }
    
    await prefs.setString('cached_rooms', jsonEncode(rooms.map((r) => r.toJson()).toList()));
  }

  Future<void> _removeCachedRoom(int roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final rooms = await _getCachedRooms();
    rooms.removeWhere((r) => r.roomId == roomId);
    await prefs.setString('cached_rooms', jsonEncode(rooms.map((r) => r.toJson()).toList()));
  }

  Future<List<Room>> _getCachedRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_rooms');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de habitaciones: $e');
      return [];
    }
  }

  Future<Room> _getCachedRoom(int roomId) async {
    final rooms = await _getCachedRooms();
    return rooms.firstWhere((r) => r.roomId == roomId, orElse: () => throw Exception('Habitación no encontrada en caché'));
  }

  Future<void> _cacheStayRooms(int stayId, List<Room> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stay_rooms_$stayId', jsonEncode(rooms.map((r) => r.toJson()).toList()));
  }

  Future<List<Room>> _getCachedStayRooms(int stayId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('stay_rooms_$stayId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de habitaciones de alojamiento: $e');
      return [];
    }
  }

  Future<void> _cacheAvailableRooms(int stayId, List<Room> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('available_rooms_$stayId', jsonEncode(rooms.map((r) => r.toJson()).toList()));
  }

  Future<List<Room>> _getCachedAvailableRooms(int stayId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('available_rooms_$stayId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de habitaciones disponibles: $e');
      return [];
    }
  }
}