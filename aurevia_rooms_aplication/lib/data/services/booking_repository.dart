// lib/data/services/booking_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/stay_repository.dart';

import '../../config/supabase/supabase_config.dart';
import '../../provider/connection_provider.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final RetryOptions _retryOptions;
  final StayRepository _stayRepository;
  final RoomRepository _roomRepository;

  static const _cacheKey = 'all_bookings_cache';

  BookingRepository(this._connectionProvider,this._stayRepository,this._roomRepository,)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<Booking> createBooking(Booking booking) async {
    await _guardConnection();
    final response = await _retryOptions.retry(() => _client.from('bookings').insert(booking.toJson()).select().single());
    final newBooking = Booking.fromJson(response);
    await _addOrUpdateCache([newBooking]);
    return newBooking;
  }

  Future<Booking> updateBooking(Booking booking) async {
    await _guardConnection();
    if (booking.bookingId == null) throw Exception('El bookingId es requerido para actualizar.');
    
    final response = await _retryOptions.retry(() => _client.from('bookings').update(booking.toJson()).eq('booking_id', booking.bookingId!).select().single());
    final updatedBooking = Booking.fromJson(response);
    await _addOrUpdateCache([updatedBooking]);
    return updatedBooking;
  }

  Future<List<Booking>> getPendingBookingsByUser(String userId) async {
  final cached = await _getBookingsFromCache();

  if (!await _connectionProvider.isConnected) {
    return cached.values
        .where((b) => b.userId == userId && b.bookingStatus == 'pending')
        .toList();
  }

  try {
    final response = await _retryOptions.retry(() =>
        _client.from('bookings')
            .select()
            .eq('user_id', userId)
            .eq('booking_status', 'pending')
    );

    final bookings = (response as List).map((json) => Booking.fromJson(json)).toList();
    await _addOrUpdateCache(bookings);
    return bookings;
  } catch (e) {
    debugPrint('❌ Error obteniendo reservas pendientes, usando caché: $e');
    return cached.values
        .where((b) => b.userId == userId && b.bookingStatus == 'pending')
        .toList();
  }
}


  // --- MÉTODO AÑADIDO QUE FALTABA ---
  Future<void> deleteBooking(int bookingId) async {
    await _guardConnection();
    await _retryOptions.retry(() => _client.from('bookings').delete().eq('booking_id', bookingId));
    await _removeBookingFromCache(bookingId);
  }

  Future<Booking> getBookingById(int bookingId) async {
    if (!await _connectionProvider.isConnected) {
      final cached = await _getBookingsFromCache();
      if (!cached.containsKey(bookingId)) throw Exception('Reserva no encontrada en caché.');
      return cached[bookingId]!;
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('bookings').select().eq('booking_id', bookingId).single());
      final booking = Booking.fromJson(response);
      await _addOrUpdateCache([booking]);
      return booking;
    } catch (e) {
      debugPrint('❌ Error obteniendo reserva por ID, intentando desde caché: $e');
      final cached = await _getBookingsFromCache();
      if (!cached.containsKey(bookingId)) throw Exception('Reserva no encontrada en API ni caché.');
      return cached[bookingId]!;
    }
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    final cached = await _getBookingsFromCache();
    if (!await _connectionProvider.isConnected) {
      return cached.values.where((b) => b.userId == userId).toList();
    }
    try {
      final response = await _retryOptions.retry(() => _client.from('bookings').select().eq('user_id', userId));
      final bookings = (response as List).map((json) => Booking.fromJson(json)).toList();
      await _addOrUpdateCache(bookings);
      return bookings;
    } catch (e) {
      debugPrint('❌ Error obteniendo reservas, filtrando desde caché: $e');
      return cached.values.where((b) => b.userId == userId).toList();
    }
  }

  Future<void> _guardConnection() async {
    if (!await _connectionProvider.isConnected) throw Exception('No hay conexión a internet.');
  }

  Future<Map<int, Booking>> _getBookingsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cacheKey);
      if (data == null) return {};
      final list = (jsonDecode(data) as List).map((json) => Booking.fromJson(json));
      return {for (var booking in list) booking.bookingId!: booking};
    } catch (e) {
      debugPrint('⚠️ Error al leer caché de reservas: $e');
      return {};
    }
  }
  
  Future<void> _addOrUpdateCache(List<Booking> bookings) async {
    final cachedMap = await _getBookingsFromCache();
    for (var booking in bookings) {
      if (booking.bookingId != null) cachedMap[booking.bookingId!] = booking;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(cachedMap.values.map((b) => b.toJson()).toList()));
  }

  // --- MÉTODO AÑADIDO QUE FALTABA ---
  Future<void> _removeBookingFromCache(int bookingId) async {
    final cachedMap = await _getBookingsFromCache();
    cachedMap.remove(bookingId);
    await _addOrUpdateCache(cachedMap.values.toList());
  }

  Future<List<Booking>> getAllPendingBookings() async {
    final cached = await _getBookingsFromCache();

    if (!await _connectionProvider.isConnected) {
      return cached.values.where((b) => b.bookingStatus == 'pending').toList();
    }

    try {
      final response = await _retryOptions.retry(() =>
          _client.from('bookings')
              .select()
              .eq('booking_status', 'pending')
      );

      final bookings = (response as List).map((json) => Booking.fromJson(json)).toList();

      await _addOrUpdateCache(bookings);

      return bookings;
    } catch (e) {
      debugPrint('❌ Error obteniendo TODAS las reservas pendientes, usando caché: $e');
      return cached.values.where((b) => b.bookingStatus == 'pending').toList();
    }
  }

Future<List<Booking>> getPendingBookingsForOwner(String ownerId) async {
  try {
    debugPrint("📡 Obteniendo stays del owner $ownerId...");
    
    // 1️⃣ Obtener stays del owner
    final stays = await _stayRepository.getStaysByOwner(ownerId);
    final stayIds = stays
    .map((s) => s.stayId)
    .whereType<int>() // ✅ elimina nulls
    .toList();

    if (stayIds.isEmpty) {
      debugPrint("⚠️ Este owner no tiene stays asociados");
      return [];
    }

    debugPrint("✅ Owner tiene ${stayIds.length} stays → $stayIds");

    // 2️⃣ Obtener rooms asociadas a esos stays
    final rooms = await _roomRepository.getRoomsByStayIds(stayIds);
    final roomIdsOwner = rooms.map((r) => r.roomId).toSet();

    if (roomIdsOwner.isEmpty) {
      debugPrint("⚠️ Este owner no tiene rooms asociados a sus stays");
      return [];
    }

    debugPrint("✅ Owner tiene ${roomIdsOwner.length} rooms → $roomIdsOwner");

    // 3️⃣ Obtener todos los bookings pendientes (de todos los rooms)
    final allPendingBookings = await getAllPendingBookings();
    debugPrint("📊 Total bookings pendientes recibidos: ${allPendingBookings.length}");

    // 4️⃣ Filtrar solo los bookings que correspondan a rooms del owner
    final filteredBookings = allPendingBookings.where(
      (booking) => roomIdsOwner.contains(booking.roomId),
    ).toList();

    debugPrint("✅ Filtrados ${filteredBookings.length} bookings que pertenecen al owner $ownerId");

    return filteredBookings;
  } catch (e, stack) {
    debugPrint('❌ Error en getPendingBookingsForOwner: $e');
    debugPrint(stack.toString());
    return [];
  }
}

}
