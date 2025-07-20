// lib/screens/testing/review_repository_test.dart

import 'package:aureviarooms/data/services/methods/review_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/review_model.dart';

class ReviewRepositoryTestScreen extends StatefulWidget {
  const ReviewRepositoryTestScreen({super.key});

  @override
  // ASEGÚRATE DE QUE ESTA LÍNEA ES CORRECTA
  State<ReviewRepositoryTestScreen> createState() => _ReviewRepositoryTestScreenState();
}

class _ReviewRepositoryTestScreenState extends State<ReviewRepositoryTestScreen> {
  Review? _lastCreatedReview;
  List<Review> _userReviews = [];
  String _log = '';
  bool _isTesting = false;

  // Debes tener un stayId válido y existente en tu DB para las pruebas.
  final int testStayId = 7;

  void _addLog(String message) {
    setState(() {
      _log = '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n$_log';
    });
    debugPrint(message);
  }

  Future<void> _runReviewTests() async {
    setState(() => _isTesting = true);
    _addLog('=== INICIANDO PRUEBAS DE REVIEW (vía Service) ===');

    await _testCreateReview();
    await _testGetReviewsByUser();
    await _testUpdateReview();
    await _testGetReviewById();
    await _testGetReviewsByStay();
    await _testDeleteReview();

    _addLog('=== PRUEBAS COMPLETADAS ===');
    setState(() => _isTesting = false);
  }

  Future<void> _testCreateReview() async {
    _addLog('▶️ Creando reseña...');
    final created = await ReviewService.createReview(
      context: context,
      stayId: testStayId,
      rating: 4,
      comment: 'Muy buena estancia, limpio y cómodo.',
    );
    if (created != null) {
      setState(() => _lastCreatedReview = created);
      _addLog('✅ Creada: ID ${created.reviewId}, Estancia ${created.stayId}');
    } else {
      _addLog('❌ Error creando reseña.');
    }
  }

  Future<void> _testUpdateReview() async {
    if (_lastCreatedReview == null) return;
    _addLog('▶️ Actualizando reseña ID ${_lastCreatedReview!.reviewId}...');
    
    final updated = await ReviewService.updateReview(
      context: context,
      reviewToUpdate: _lastCreatedReview!.copyWith(
        rating: 3,
        comment: 'Cambio de opinión: regular, mucho ruido.',
      ),
    );

    if (updated != null) {
      setState(() => _lastCreatedReview = updated);
      _addLog('🔄 Actualizada: Nueva calificación ${updated.rating}');
    } else {
      _addLog('❌ Error actualizando reseña.');
    }
  }

  Future<void> _testGetReviewById() async {
    if (_lastCreatedReview == null) return;
    _addLog('▶️ Consultando reseña ID ${_lastCreatedReview!.reviewId}...');

    final review = await ReviewService.getReviewById(context: context, reviewId: _lastCreatedReview!.reviewId!);
    if (review != null) {
      _addLog('🔍 Encontrada: Estancia ${review.stayId}, Rating ${review.rating}');
    } else {
      _addLog('❌ Error obteniendo reseña por ID.');
    }
  }

  Future<void> _testDeleteReview() async {
    if (_lastCreatedReview == null) return;
    _addLog('▶️ Eliminando reseña ID ${_lastCreatedReview!.reviewId}...');

    final success = await ReviewService.deleteReview(context: context, reviewId: _lastCreatedReview!.reviewId!);
    if (success) {
      _addLog('🗑️ Eliminada exitosamente');
      setState(() => _lastCreatedReview = null);
    } else {
      _addLog('❌ Error eliminando reseña.');
    }
  }

  Future<void> _testGetReviewsByUser() async {
    _addLog('▶️ Consultando reseñas del usuario...');
    final reviews = await ReviewService.getReviewsByUser(context: context);
    setState(() => _userReviews = reviews);
    _addLog('📋 ${reviews.length} reseñas encontradas:');
    for (var r in reviews) {
      _addLog('   - Estancia ${r.stayId}: ${r.rating} estrellas');
    }
  }

  Future<void> _testGetReviewsByStay() async {
    _addLog('▶️ Consultando reseñas del alojamiento $testStayId...');
    final reviews = await ReviewService.getReviewsByStay(context: context, stayId: testStayId);
    _addLog('🏨 ${reviews.length} reseñas encontradas para estancia $testStayId.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pruebas de Review (vía Service)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_log, style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 20),
            if (_isTesting) const Center(child: CircularProgressIndicator()),
            if (_userReviews.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Reseñas del usuario:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._userReviews.map((r) => ListTile(
                    title: Text('Estancia ${r.stayId}'),
                    subtitle: Text('${r.rating} estrellas - ${r.comment}'),
                  )),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isTesting ? null : _runReviewTests,
        child: const Icon(Icons.rate_review),
      ),
    );
  }
}