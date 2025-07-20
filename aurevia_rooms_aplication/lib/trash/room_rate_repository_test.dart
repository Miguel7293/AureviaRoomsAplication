// lib/screens/testing/room_rate_repository_test.dart

import 'package:aureviarooms/data/services/methods/room_rate_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/room_rate_model.dart';

class RoomRateRepositoryTestScreen extends StatefulWidget {
  const RoomRateRepositoryTestScreen({super.key});

  @override
  State<RoomRateRepositoryTestScreen> createState() => _RoomRateRepositoryTestScreenState();
}

class _RoomRateRepositoryTestScreenState extends State<RoomRateRepositoryTestScreen> {
  RoomRate? _lastCreatedRate;
  List<RoomRate> _foundRates = [];
  String _log = '';
  bool _isTesting = false;
  
  // IDs de prueba que deben existir en tu DB
  final int testRoomId = 1;

  void _addLog(String message) {
    setState(() => _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log');
    debugPrint(message);
  }

  Future<void> _runAllTests() async {
    setState(() { _isTesting = true; _log = ''; });
    _addLog('=== INICIANDO PRUEBAS DE ROOM_RATE ===');

    await _testCreateRate();
    await _testUpdateRatePrice();
    await _testGetRatesByRoom();
    await _testDeleteRate();
    
    _addLog('=== PRUEBAS DE ROOM_RATE COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreateRate() async {
    _addLog('▶️ Creando tarifa para Habitación ID: $testRoomId...');
    final created = await RoomRateService.createRate(
      context: context,
      roomId: testRoomId,
      rateType: 'night',
      price: 99.99,
    );
    if (created != null) {
      setState(() => _lastCreatedRate = created);
      _addLog('✅ Creada: ID ${created.id}, Precio: ${created.price}');
    } else {
      _addLog('❌ Error al crear la tarifa.');
    }
  }

  Future<void> _testUpdateRatePrice() async {
    if (_lastCreatedRate == null) return;
    _addLog('▶️ Actualizando tarifa ID ${_lastCreatedRate!.id}...');
    
    final updated = await RoomRateService.updateRatePrice(
      context: context,
      rateId: _lastCreatedRate!.id!,
      newPrice: 120.50,
    );

    if (updated != null) {
      setState(() => _lastCreatedRate = updated);
      _addLog('🔄 Actualizada: Nuevo precio ${updated.price}');
    } else {
      _addLog('❌ Error actualizando tarifa.');
    }
  }
  
  Future<void> _testGetRatesByRoom() async {
    _addLog('▶️ Consultando tarifas para la Habitación ID: $testRoomId...');
    final rates = await RoomRateService.getRatesByRoom(context: context, roomId: testRoomId);
    setState(() => _foundRates = rates);
    _addLog('📋 Encontradas ${rates.length} tarifas.');
  }

  Future<void> _testDeleteRate() async {
    if (_lastCreatedRate == null) return;
    _addLog('▶️ Eliminando tarifa ID ${_lastCreatedRate!.id}...');
    final success = await RoomRateService.deleteRate(context: context, rateId: _lastCreatedRate!.id!);
    if (success) {
      _addLog('🗑️ Tarifa eliminada exitosamente.');
      setState(() {
        _lastCreatedRate = null;
        _foundRates.clear();
      });
    } else {
      _addLog('❌ Error eliminando tarifa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de RoomRateRepository')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_isTesting) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const Divider(height: 30),
            Text('Tarifas Encontradas (Room ID: $testRoomId):', style: Theme.of(context).textTheme.titleMedium),
            if (_foundRates.isEmpty) const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Ninguna'),
            ),
            ..._foundRates.map((r) => Card(
              child: ListTile(
                title: Text('Tarifa ID: ${r.id} - ${r.rateType}'),
                subtitle: Text('Precio: \$${r.price.toStringAsFixed(2)}'),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runAllTests,
        child: const Icon(Icons.price_change),
      ),
    );
  }
}