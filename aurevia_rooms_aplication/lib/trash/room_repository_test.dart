// lib/screens/testing/room_repository_test.dart

import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/room_model.dart';
// Importa el RoomService, ya no necesitas el repository directamente.

class RoomRepositoryTestScreen extends StatefulWidget {
  const RoomRepositoryTestScreen({super.key});

  @override
  State<RoomRepositoryTestScreen> createState() => _RoomRepositoryTestScreenState();
}

class _RoomRepositoryTestScreenState extends State<RoomRepositoryTestScreen> {
  Room? _lastCreatedRoom;
  List<Room> _foundRooms = [];
  String _log = '';
  bool _isTesting = false;
  
  // Debes tener un stayId válido y existente en tu DB para las pruebas.
  // Usamos un valor de ejemplo.
  final int testStayId = 7; 

  void _addLog(String message) {
    setState(() {
      _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log';
    });
    debugPrint(message);
  }

  Future<void> _runAllTests() async {
    setState(() { _isTesting = true; _log = ''; });
    _addLog('=== INICIANDO PRUEBAS DE ROOM (vía Service) ===');

    await _testCreateRoom();
    await _testUpdateRoom();
    await _testGetRoomsByStay();
    await _testDeleteRoom();
    
    _addLog('=== PRUEBAS DE ROOM COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreateRoom() async {
    _addLog('▶️ Creando habitación para el Alojamiento ID: $testStayId...');
    final created = await RoomService.createRoom(
      context: context,
      stayId: testStayId,
      features: {'wifi': true, 'beds': 2, 'type': 'double'},
      imageUrl: 'https://example.com/room.jpg',

    );
    if (created != null) {
      setState(() => _lastCreatedRoom = created);
      _addLog('✅ Creada: ID ${created.roomId}');
    } else {
      _addLog('❌ Error al crear la habitación.');
    }
  }

  Future<void> _testUpdateRoom() async {
    if (_lastCreatedRoom == null) return;
    _addLog('▶️ Actualizando habitación ID ${_lastCreatedRoom!.roomId}...');
    
    final updated = await RoomService.updateRoom(
      context: context,
      roomToUpdate: _lastCreatedRoom!.copyWith(availabilityStatus: 'unavailable'),
    );

    if (updated != null) {
      setState(() => _lastCreatedRoom = updated);
      _addLog('🔄 Actualizada: Nuevo status "${updated.availabilityStatus}"');
    } else {
       _addLog('❌ Error actualizando habitación.');
    }
  }
  
  Future<void> _testGetRoomsByStay() async {
    _addLog('▶️ Consultando habitaciones del Alojamiento ID: $testStayId...');
    try {
      final rooms = await RoomService.getRoomsByStay(context: context, stayId: testStayId);
      setState(() => _foundRooms = rooms);
      _addLog('📋 Encontradas ${rooms.length} habitaciones.');
      for (var room in rooms) {
        _addLog('  - Room ID: ${room.roomId}, Status: ${room.availabilityStatus}');
      }
    } catch (e) {
      _addLog('❌ Error consultando habitaciones: $e');
    }
  }

  Future<void> _testDeleteRoom() async {
    if (_lastCreatedRoom == null) return;
    _addLog('▶️ Eliminando habitación ID ${_lastCreatedRoom!.roomId}...');
    
    final success = await RoomService.deleteRoom(
      context: context,
      roomId: _lastCreatedRoom!.roomId!,
    );

    if (success) {
      _addLog('🗑️ Habitación eliminada exitosamente.');
      setState(() {
        _lastCreatedRoom = null;
        _foundRooms.clear();
      });
    } else {
       _addLog('❌ Error eliminando habitación.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de Room (vía Service)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_isTesting) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const Divider(height: 30),
            Text('Habitaciones Encontradas (Stay ID: $testStayId):', style: Theme.of(context).textTheme.titleMedium),
            if (_foundRooms.isEmpty) const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Ninguna'),
            ),
            ..._foundRooms.map((r) => Card(
              child: ListTile(
                title: Text('Habitación ID: ${r.roomId}'),
                subtitle: Text('Status: ${r.availabilityStatus}\nFeatures: ${r.features}'),
                isThreeLine: true,
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runAllTests,
        backgroundColor: _isTesting ? Colors.grey : Theme.of(context).primaryColor,
        child: const Icon(Icons.hotel),
      ),
    );
  }
}