// booking_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aureviarooms/data/models/booking_model.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase/supabase_config.dart';

class BookingRepository {
  final SupabaseClient _client;
  final ConnectionProvider _connectionProvider;
  final LocalStorageManager _localStorage;
  final RetryOptions _retryOptions;

  BookingRepository(this._connectionProvider, this._localStorage)
      : _client = SupabaseConfig.client,
        _retryOptions = const RetryOptions(maxAttempts: 3, delayFactor: Duration(seconds: 1));

  Future<Booking> createBooking(Booking booking) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    final response = await _retryOptions.retry(
      () => _client.from('bookings').insert(booking.toJson()).select().single(),
    );

    final newBooking = Booking.fromJson(response);
    await _cacheBooking(newBooking);
    return newBooking;
  }

Future<Booking> updateBooking(Booking booking) async {
  if (!await _connectionProvider.isConnected) {
    throw Exception('No hay conexión a internet');
  }

  if (booking.bookingId == null) {
    throw Exception('El bookingId no puede ser null para una actualización.');
  }

  final response = await _retryOptions.retry(
    () => _client
        .from('bookings')
        .update(booking.toJson())
        .eq('booking_id', booking.bookingId!)
        .select()
        .single(),
  );

  final updatedBooking = Booking.fromJson(response);
  await _cacheBooking(updatedBooking);
  return updatedBooking;
}


  Future<void> deleteBooking(int bookingId) async {
    if (!await _connectionProvider.isConnected) {
      throw Exception('No hay conexión a internet');
    }

    await _retryOptions.retry(
      () => _client.from('bookings').delete().eq('booking_id', bookingId),
    );

    await _removeCachedBooking(bookingId);
  }

  Future<Booking> getBookingById(int bookingId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedBooking(bookingId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('bookings').select().eq('booking_id', bookingId).single().timeout(Duration(seconds: 5)),
      );

      final booking = Booking.fromJson(response);
      await _cacheBooking(booking);
      return booking;
    } catch (e) {
      debugPrint('❌ Error obteniendo reserva: $e');
      return _getCachedBooking(bookingId);
    }
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    if (!await _connectionProvider.isConnected) {
      return _getCachedUserBookings(userId);
    }

    try {
      final response = await _retryOptions.retry(
        () => _client.from('bookings').select().eq('user_id', userId).timeout(Duration(seconds: 5)),
      );

      final bookings = (response as List).map((json) => Booking.fromJson(json)).toList();
      await _cacheUserBookings(userId, bookings);
      return bookings;
    } catch (e) {
      debugPrint('❌ Error obteniendo reservas de usuario: $e');
      return _getCachedUserBookings(userId);
    }
  }

  // Caché methods
  Future<void> _cacheBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await _getCachedBookings();
    final index = bookings.indexWhere((b) => b.bookingId == booking.bookingId);
    
    if (index != -1) {
      bookings[index] = booking;
    } else {
      bookings.add(booking);
    }
    
    await prefs.setString('cached_bookings', jsonEncode(bookings.map((b) => b.toJson()).toList()));
  }

  Future<void> _removeCachedBooking(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await _getCachedBookings();
    bookings.removeWhere((b) => b.bookingId == bookingId);
    await prefs.setString('cached_bookings', jsonEncode(bookings.map((b) => b.toJson()).toList()));
  }

  Future<List<Booking>> _getCachedBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cached_bookings');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de reservas: $e');
      return [];
    }
  }

  Future<Booking> _getCachedBooking(int bookingId) async {
    final bookings = await _getCachedBookings();
    return bookings.firstWhere((b) => b.bookingId == bookingId, orElse: () => throw Exception('Reserva no encontrada en caché'));
  }

  Future<void> _cacheUserBookings(String userId, List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_bookings_$userId', jsonEncode(bookings.map((b) => b.toJson()).toList()));
  }

  Future<List<Booking>> _getCachedUserBookings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_bookings_$userId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error recuperando caché de reservas de usuario: $e');
      return [];
    }
  }
}