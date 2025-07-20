// lib/screens/testing/promotion_repository_test.dart

import 'package:aureviarooms/data/services/methods/promotion_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/promotion_model.dart';

class PromotionRepositoryTestScreen extends StatefulWidget {
  const PromotionRepositoryTestScreen({super.key});

  @override
  State<PromotionRepositoryTestScreen> createState() => _PromotionRepositoryTestScreenState();
}

class _PromotionRepositoryTestScreenState extends State<PromotionRepositoryTestScreen> {
  Promotion? _lastCreatedPromotion;
  List<Promotion> _foundPromotions = [];
  String _log = '';
  bool _isTesting = false;
  
  final int testStayId = 7; 

  void _addLog(String message) {
    setState(() => _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log');
    debugPrint(message);
  }

  Future<void> _runAllTests() async {
    setState(() { _isTesting = true; _log = ''; });
    _addLog('=== INICIANDO PRUEBAS DE PROMOTION ===');

    await _testCreatePromotion();
    await _testUpdatePromotion(); // <-- Prueba de modificación añadida al flujo
    await _testGetActivePromotionsByStay();
    await _testDeletePromotion();
    
    _addLog('=== PRUEBAS DE PROMOTION COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreatePromotion() async {
    _addLog('▶️ Creando promoción para Alojamiento ID: $testStayId...');
    final now = DateTime.now();
    final created = await PromotionService.createPromotion(
      context: context,
      stayId: testStayId,
      description: 'Oferta de fin de semana!',
      discount: 15.5,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 2)),
    );
    if (created != null) {
      setState(() => _lastCreatedPromotion = created);
      _addLog('✅ Creada: ID ${created.promotionId}');
    } else {
      _addLog('❌ Error al crear la promoción.');
    }
  }
  
  // --- MÉTODO DE PRUEBA AÑADIDO ---
  Future<void> _testUpdatePromotion() async {
    if (_lastCreatedPromotion == null) return;
    _addLog('▶️ Actualizando promoción ID ${_lastCreatedPromotion!.promotionId}...');
    
    final updated = await PromotionService.updatePromotion(
      context: context,
      promotionToUpdate: _lastCreatedPromotion!.copyWith(
        description: 'Oferta flash 24h!',
        discountPercentage: 20.0,
      ),
    );

    if (updated != null) {
      setState(() => _lastCreatedPromotion = updated);
      _addLog('🔄 Actualizada: Nueva descripción "${updated.description}"');
    } else {
      _addLog('❌ Error actualizando promoción.');
    }
  }
  
  Future<void> _testGetActivePromotionsByStay() async {
    _addLog('▶️ Consultando promociones activas para el Alojamiento ID: $testStayId...');
    final promotions = await PromotionService.getActivePromotionsByStay(context: context, stayId: testStayId);
    setState(() => _foundPromotions = promotions);
    _addLog('📋 Encontradas ${promotions.length} promociones activas.');
    for (var promo in promotions) {
      _addLog('  - ID: ${promo.promotionId}, Desc: "${promo.description}"');
    }
  }

  Future<void> _testDeletePromotion() async {
    if (_lastCreatedPromotion == null) return;
    _addLog('▶️ Eliminando promoción ID ${_lastCreatedPromotion!.promotionId}...');
    final success = await PromotionService.deletePromotion(context: context, promotionId: _lastCreatedPromotion!.promotionId!);
    if (success) {
      _addLog('🗑️ Promoción eliminada exitosamente.');
      setState(() {
        _lastCreatedPromotion = null;
        _foundPromotions.clear();
      });
    } else {
      _addLog('❌ Error eliminando promoción.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de PromotionRepository')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (_isTesting) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const Divider(height: 30),
            Text('Promociones Encontradas (Stay ID: $testStayId):', style: Theme.of(context).textTheme.titleMedium),
            if (_foundPromotions.isEmpty) const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Ninguna'),
            ),
            ..._foundPromotions.map((p) => Card(
              child: ListTile(
                title: Text(p.description),
                subtitle: Text('ID: ${p.promotionId}\nDescuento: ${p.discountPercentage}%'),
                isThreeLine: true,
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runAllTests,
        backgroundColor: _isTesting ? Colors.grey : Theme.of(context).primaryColor,
        child: const Icon(Icons.sell),
      ),
    );
  }
}