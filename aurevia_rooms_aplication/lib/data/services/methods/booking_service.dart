// lib/data/services/usage/methods/booking_service.dart

import 'package:aureviarooms/data/models/booking_model.dart';
import 'package:aureviarooms/data/services/booking_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';

class BookingService {
  static Future<Booking?> createBooking({
    required BuildContext context,
    required int roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required double totalPrice,
  }) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      debugPrint('⚠️ Usuario no autenticado para crear reserva.');
      return null;
    }
    final repo = context.read<BookingRepository>();
    final newBooking = Booking(
      userId: userId,
      roomId: roomId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
      totalPrice: totalPrice,
      bookingStatus: 'pending',
      createdAt: DateTime.now(),
    );
    try {
      return await repo.createBooking(newBooking);
    } catch (e) {
      debugPrint('❌ Error creando reserva: $e');
      return null;
    }
  }

  static Future<Booking?> updateBookingStatus({
    required BuildContext context,
    required int bookingId,
    required String newStatus,
  }) async {
    final repo = context.read<BookingRepository>();
    try {
      final booking = await repo.getBookingById(bookingId);
      final updatedBooking = booking.copyWith(bookingStatus: newStatus);
      return await repo.updateBooking(updatedBooking);
    } catch (e) {
      debugPrint('❌ Error actualizando estado de la reserva: $e');
      return null;
    }
  }

  // --- MÉTODO AÑADIDO QUE FALTABA ---
  static Future<bool> deleteBooking({
    required BuildContext context,
    required int bookingId,
  }) async {
    try {
      await context.read<BookingRepository>().deleteBooking(bookingId);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando la reserva: $e');
      return false;
    }
  }
  
  // --- MÉTODO AÑADIDO QUE FALTABA ---
  static Future<Booking?> getBookingById({
    required BuildContext context,
    required int bookingId,
  }) async {
    try {
      return await context.read<BookingRepository>().getBookingById(bookingId);
    } catch (e) {
      debugPrint('❌ Error obteniendo reserva por ID: $e');
      return null;
    }
  }

  static Future<List<Booking>> getBookingsForCurrentUser({required BuildContext context}) async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return [];
    try {
      return await context.read<BookingRepository>().getBookingsByUser(userId);
    } catch (e) {
      debugPrint('❌ Error obteniendo reservas del usuario: $e');
      return [];
    }
  }
}