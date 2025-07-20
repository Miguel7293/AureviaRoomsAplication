// lib/screens/testing/booking_repository_test.dart

import 'package:aureviarooms/data/services/methods/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/booking_model.dart';

class BookingRepositoryTestScreen extends StatefulWidget {
  const BookingRepositoryTestScreen({super.key});

  @override
  State<BookingRepositoryTestScreen> createState() => _BookingRepositoryTestScreenState();
}

class _BookingRepositoryTestScreenState extends State<BookingRepositoryTestScreen> {
  Booking? _lastCreatedBooking;
  List<Booking> _userBookings = [];
  String _log = '';
  bool _isTesting = false;
  
  final int testRoomId = 1; 

  void _addLog(String message) {
    setState(() => _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log');
    debugPrint(message);
  }

  Future<void> _runAllTests() async {
    setState(() { _isTesting = true; _log = ''; });
    _addLog('=== INICIANDO PRUEBAS DE BOOKING ===');

    await _testCreateBooking();
    await _testUpdateBookingStatus();
    await _testGetBookingsForCurrentUser();
    await _testDeleteBooking(); // <-- Prueba de eliminación añadida al flujo
    
    _addLog('=== PRUEBAS DE BOOKING COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreateBooking() async {
    _addLog('▶️ Creando reserva para la Habitación ID: $testRoomId...');
    final now = DateTime.now();
    final created = await BookingService.createBooking(
      context: context,
      roomId: testRoomId,
      checkIn: now,
      checkOut: now.add(const Duration(days: 2)),
      totalPrice: 150.75,
    );
    if (created != null) {
      setState(() => _lastCreatedBooking = created);
      _addLog('✅ Creada: ID ${created.bookingId}, Status: ${created.bookingStatus}');
    } else {
      _addLog('❌ Error al crear la reserva.');
    }
  }

  Future<void> _testUpdateBookingStatus() async {
    if (_lastCreatedBooking == null) return;
    _addLog('▶️ Actualizando reserva ID ${_lastCreatedBooking!.bookingId} a "confirmed"...');
    final updated = await BookingService.updateBookingStatus(
      context: context,
      bookingId: _lastCreatedBooking!.bookingId!,
      newStatus: 'confirmed',
    );
    if (updated != null) {
      setState(() => _lastCreatedBooking = updated);
      _addLog('🔄 Actualizada: Nuevo status "${updated.bookingStatus}"');
    } else {
      _addLog('❌ Error actualizando la reserva.');
    }
  }
  
  Future<void> _testGetBookingsForCurrentUser() async {
    _addLog('▶️ Consultando reservas del usuario actual...');
    final bookings = await BookingService.getBookingsForCurrentUser(context: context);
    setState(() => _userBookings = bookings);
    _addLog('📋 Encontradas ${bookings.length} reservas.');
  }

  // --- MÉTODO DE PRUEBA AÑADIDO ---
  Future<void> _testDeleteBooking() async {
    if (_lastCreatedBooking == null) {
      _addLog('ℹ️ No hay reserva para eliminar, saltando prueba.');
      return;
    }
    _addLog('▶️ Eliminando reserva ID: ${_lastCreatedBooking!.bookingId!}');
    final success = await BookingService.deleteBooking(context: context, bookingId: _lastCreatedBooking!.bookingId!);
    if (success) {
      _addLog('🗑️ Reserva eliminada exitosamente.');
      setState(() {
        _lastCreatedBooking = null;
        _userBookings.clear(); // Limpia la lista para reflejar el cambio en la UI
      });
    } else {
      _addLog('❌ Error eliminando la reserva.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de BookingRepository')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_isTesting) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const Divider(height: 30),
            Text('Reservas del Usuario:', style: Theme.of(context).textTheme.titleMedium),
            if (_userBookings.isEmpty) const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Ninguna'),
            ),
            ..._userBookings.map((b) => Card(
              child: ListTile(
                title: Text('Reserva ID: ${b.bookingId} - Habitación: ${b.roomId}'),
                subtitle: Text('Status: ${b.bookingStatus}\nCheck-in: ${b.checkInDate.toLocal().toString().substring(0, 10)}'),
                isThreeLine: true,
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runAllTests,
        child: const Icon(Icons.calendar_today),
      ),
    );
  }
}