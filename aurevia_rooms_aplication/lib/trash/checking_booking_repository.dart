import 'package:aureviarooms/data/services/booking_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/booking_model.dart';
import 'package:aureviarooms/provider/auth_provider.dart';

class BookingTestScreen extends StatefulWidget {
  const BookingTestScreen({super.key});

  @override
  State<BookingTestScreen> createState() => _BookingTestScreenState();
}

class _BookingTestScreenState extends State<BookingTestScreen> {
  late BookingRepository _bookingRepo;
  String? _userId;
  Booking? _lastCreatedBooking;
  List<Booking> _userBookings = [];
  String _log = '';
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _runTests();
  }

  void _initializeDependencies() {
    _bookingRepo = context.read<BookingRepository>();
    _userId = context.read<AuthProvider>().userId;
  }

  void _addLog(String message) {
    setState(() {
      _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log';
    });
    debugPrint(message); // También se muestra en la consola
  }

  Future<void> _runTests() async {
    setState(() => _isTesting = true); // <-- Actualiza el estado al iniciar
    if (_userId == null) {
      _addLog('⚠️ Usuario no autenticado');
      setState(() => _isTesting = false); // <-- Actualiza al finalizar
      return;
    }

    _addLog('=== INICIANDO PRUEBAS DE BOOKING ===');
    
    await _testCreateBooking();
    
    if (_lastCreatedBooking != null) {
      await _testUpdateBooking();
      await _testGetBookingById();
      await _testDeleteBooking();
    }
    
    await _testGetUserBookings();
    
    _addLog('=== PRUEBAS COMPLETADAS ===');
    setState(() => _isTesting = false); // <-- Actualiza al finalizar
  }


  Future<void> _testCreateBooking() async {
    setState(() => _isTesting = true);
    _addLog('▶️ Probando creación de reserva...');
    try {
      final booking = Booking(
        userId: _userId!,
        roomId: 1,
        checkInDate: DateTime.now().add(const Duration(days: 1)),
        checkOutDate: DateTime.now().add(const Duration(days: 3)),
        bookingStatus: 'pending',
        totalPrice: 250.0,
        createdAt: DateTime.now(),
      );

      final created = await _bookingRepo.createBooking(booking);
      setState(() => _lastCreatedBooking = created);
      
      _addLog('✅ Reserva creada:'
          '\nID: ${created.bookingId}'
          '\nHabitación: ${created.roomId}'
          '\nEstado: ${created.bookingStatus}'
          '\nPrecio: ${created.totalPrice}');
    } catch (e) {
      _addLog('❌ Error creando reserva: $e');
    } finally {
      setState(() => _isTesting = false); // <--
    }
  }

  Future<void> _testUpdateBooking() async {
    if (_lastCreatedBooking == null) return;
    
    _addLog('▶️ Probando actualización de reserva ${_lastCreatedBooking!.bookingId}...');
    try {
      final updated = Booking(
        bookingId: _lastCreatedBooking!.bookingId,
        userId: _lastCreatedBooking!.userId,
        roomId: _lastCreatedBooking!.roomId,
        checkInDate: _lastCreatedBooking!.checkInDate,
        checkOutDate: _lastCreatedBooking!.checkOutDate,
        bookingStatus: 'confirmed',
        totalPrice: 225.0,
        createdAt: _lastCreatedBooking!.createdAt,
      );

      final result = await _bookingRepo.updateBooking(updated);
      setState(() => _lastCreatedBooking = result);
      
      _addLog('🔄 Reserva actualizada:'
          '\nNuevo estado: ${result.bookingStatus}'
          '\nNuevo precio: ${result.totalPrice}');
    } catch (e) {
      _addLog('❌ Error actualizando reserva: $e');
    }
  }

  Future<void> _testGetBookingById() async {
    if (_lastCreatedBooking == null) return;
    
    _addLog('▶️ Probando obtener reserva por ID: ${_lastCreatedBooking!.bookingId}...');
    try {
      final booking = await _bookingRepo.getBookingById(_lastCreatedBooking!.bookingId!);
      _addLog('🔍 Reserva obtenida:'
          '\nCheck-in: ${booking.checkInDate}'
          '\nCheck-out: ${booking.checkOutDate}');
    } catch (e) {
      _addLog('❌ Error obteniendo reserva: $e');
    }
  }

  Future<void> _testDeleteBooking() async {
    if (_lastCreatedBooking == null) return;
    
    _addLog('▶️ Probando eliminar reserva ${_lastCreatedBooking!.bookingId}...');
    try {
      await _bookingRepo.deleteBooking(_lastCreatedBooking!.bookingId!);
      _addLog('🗑️ Reserva eliminada exitosamente');
      setState(() => _lastCreatedBooking = null);
    } catch (e) {
      _addLog('❌ Error eliminando reserva: $e');
    }
  }

  Future<void> _testGetUserBookings() async {
    _addLog('▶️ Probando obtener reservas del usuario $_userId...');
    try {
      final bookings = await _bookingRepo.getBookingsByUser(_userId!);
      setState(() => _userBookings = bookings);
      
      _addLog('📋 ${bookings.length} reservas encontradas:');
      for (var b in bookings) {
        _addLog('   - Hab ${b.roomId}: \$${b.totalPrice} (${b.bookingStatus})');
      }
    } catch (e) {
      _addLog('❌ Error obteniendo reservas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas Booking Repository')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 20),
            if (_isTesting) const CircularProgressIndicator(),
            if (_userBookings.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Reservas del usuario:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._userBookings.map((b) => ListTile(
                title: Text('Habitación ${b.roomId}'),
                subtitle: Text('\$${b.totalPrice} - ${b.bookingStatus}'),
              )).toList(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runTests,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}