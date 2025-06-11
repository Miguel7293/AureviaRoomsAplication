// 📁 lib/core/services/local_storage_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageManager {
  static const _prefix = 'cached_cartas';

  Future<void> saveCartas(int restaurantId, List<Map<String, dynamic>> cartas) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = cartas.map((carta) => jsonEncode(carta)).toList();
    await prefs.setStringList('$_prefix$restaurantId', encodedData);
  }

  Future<List<Map<String, dynamic>>> getCartas(int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getStringList('$_prefix$restaurantId') ?? [];
    return encodedData.map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>).toList();
  }

  
}