// lib/screens/testing/stay_repository_test.dart

import 'package:aureviarooms/data/services/methods/stay_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/stay_model.dart';
// Ya no se importa el repositorio, solo el servicio.

class StayRepositoryTestScreen extends StatefulWidget {
  const StayRepositoryTestScreen({super.key});

  @override
  State<StayRepositoryTestScreen> createState() => _StayRepositoryTestScreenState();
}

class _StayRepositoryTestScreenState extends State<StayRepositoryTestScreen> {
  Stay? _lastCreatedStay;
  List<Stay> _foundStays = [];
  String _log = '';
  bool _isTesting = false;

  void _addLog(String message) {
    setState(() {
      _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log';
    });
    debugPrint(message);
  }

  Future<void> _runAllTests() async {
    setState(() { _isTesting = true; _log = ''; });
    _addLog('=== INICIANDO PRUEBAS DE STAY (vía Service) ===');

    await _testCreateStay();
    await _testGetStaysByCurrentUser();
    await _testUpdateStay();
    await _testGetStayById();
    await _testGetAllPublishedStays();
    await _testDeleteStay();

    _addLog('=== PRUEBAS DE STAY COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreateStay() async {
    _addLog('▶️ Creando alojamiento...');
    final created = await StayService.createStay(
      context: context,
      name: 'Cabaña del Bosque Encantado',
      category: 'cabin',
      description: 'Un lugar mágico para desconectar.',
    );
    if (created != null) {
      setState(() => _lastCreatedStay = created);
      _addLog('✅ Creado: ID ${created.stayId}, Nombre: ${created.name}');
    } else {
      _addLog('❌ Error al crear el alojamiento.');
    }
  }

  Future<void> _testUpdateStay() async {
    if (_lastCreatedStay == null) return;
    _addLog('▶️ Actualizando alojamiento ID ${_lastCreatedStay!.stayId}...');
    
    final updated = await StayService.updateStay(
        context: context, 
        stayToUpdate: _lastCreatedStay!.copyWith(status: 'published', name: 'Cabaña del Bosque (Publicada)'),
    );

    if (updated != null) {
      setState(() => _lastCreatedStay = updated);
      _addLog('🔄 Actualizado: Nuevo status "${updated.status}", Nombre: "${updated.name}"');
    } else {
      _addLog('❌ Error actualizando alojamiento.');
    }
  }

  Future<void> _testGetStayById() async {
    if (_lastCreatedStay == null) return;
    _addLog('▶️ Consultando alojamiento por ID: ${_lastCreatedStay!.stayId}...');

    final found = await StayService.getStayById(context: context, stayId: _lastCreatedStay!.stayId!);
    if (found != null) {
      _addLog('🔍 Encontrado: ${found.name}, Status: ${found.status}');
    } else {
      _addLog('❌ Error consultando por ID.');
    }
  }
  
  Future<void> _testGetStaysByCurrentUser() async {
    _addLog('▶️ Consultando alojamientos del usuario actual...');
    final stays = await StayService.getStaysByCurrentUser(context: context);
    setState(() => _foundStays = stays);
    _addLog('📋 Encontrados ${stays.length} alojamientos para el usuario.');
  }

  Future<void> _testGetAllPublishedStays() async {
    _addLog('▶️ Consultando todos los alojamientos publicados...');
    final stays = await StayService.getAllPublishedStays(context: context);
    _addLog('🏨 Encontrados ${stays.length} alojamientos publicados en total.');
  }

  Future<void> _testDeleteStay() async {
    if (_lastCreatedStay == null) return;
    _addLog('▶️ Eliminando alojamiento ID ${_lastCreatedStay!.stayId}...');
    
    final success = await StayService.deleteStay(context: context, stayId: _lastCreatedStay!.stayId!);
    if (success) {
      _addLog('🗑️ Alojamiento eliminado exitosamente.');
      setState(() => _lastCreatedStay = null);
    } else {
      _addLog('❌ Error eliminando alojamiento.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de Stay (vía Service)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_isTesting) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const Divider(height: 30),
            Text('Alojamientos Encontrados:', style: Theme.of(context).textTheme.titleMedium),
            if (_foundStays.isEmpty) const Text('Ninguno'),
            ..._foundStays.map((s) => Card(
              child: ListTile(title: Text(s.name), subtitle: Text('ID: ${s.stayId} - Status: ${s.status}')),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runAllTests,
        backgroundColor: _isTesting ? Colors.grey : Theme.of(context).primaryColor,
        child: const Icon(Icons.science),
      ),
    );
  }
}