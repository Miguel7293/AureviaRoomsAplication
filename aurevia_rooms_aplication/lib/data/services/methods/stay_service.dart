// lib/data/services/usage/methods/stay_service.dart

import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';


class StayService {
  static Future<Stay?> createStay({
    required BuildContext context,
    required String name,
    required String category,
    String? description,
  }) async {
    final ownerId = context.read<AuthProvider>().userId;
    if (ownerId == null) {
      debugPrint('⚠️ Usuario no autenticado, no se puede crear el alojamiento.');
      return null;
    }

    final stayRepo = context.read<StayRepository>();
    final newStay = Stay(
      name: name,
      category: category,
      description: description,
      status: 'draft', // Los alojamientos se crean como borrador por defecto
      ownerId: ownerId,
      createdAt: DateTime.now(),
    );

    try {
      return await stayRepo.createStay(newStay);
    } catch (e) {
      debugPrint('❌ Error creando alojamiento: $e');
      return null;
    }
  }
  
  static Future<Stay?> updateStay({
    required BuildContext context,
    required Stay stayToUpdate,
  }) async {
    try {
      return await context.read<StayRepository>().updateStay(stayToUpdate);
    } catch (e) {
      debugPrint('❌ Error actualizando el alojamiento: $e');
      return null;
    }
  }

  static Future<bool> deleteStay({
    required BuildContext context,
    required int stayId,
  }) async {
    try {
      await context.read<StayRepository>().deleteStay(stayId);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando el alojamiento: $e');
      return false;
    }
  }

  static Future<Stay?> getStayById({
    required BuildContext context,
    required int stayId,
  }) async {
    try {
      return await context.read<StayRepository>().getStayById(stayId);
    } catch (e) {
      debugPrint('❌ Error obteniendo alojamiento por ID: $e');
      return null;
    }
  }
  
  static Future<List<Stay>> getStaysByCurrentUser({required BuildContext context}) async {
    final ownerId = context.read<AuthProvider>().userId;
    if (ownerId == null) {
      debugPrint('⚠️ Usuario no autenticado.');
      return [];
    }
    try {
      return await context.read<StayRepository>().getStaysByOwner(ownerId);
    } catch (e) {
      debugPrint('❌ Error obteniendo los alojamientos del usuario: $e');
      return [];
    }
  }
  
  static Future<List<Stay>> getAllPublishedStays({required BuildContext context}) async {
    try {
      return await context.read<StayRepository>().getAllPublishedStays();
    } catch (e) {
      debugPrint('❌ Error obteniendo todos los alojamientos publicados: $e');
      return [];
    }
  }

    static Future<List<Stay>> searchStays({
    required BuildContext context,
    required String query,
  }) async {
    if (query.trim().isEmpty) return [];
    try {
      return await context.read<StayRepository>().searchStays(query);
    } catch (e) {
      debugPrint('❌ Error buscando alojamientos: $e');
      return [];
    }
  }
}