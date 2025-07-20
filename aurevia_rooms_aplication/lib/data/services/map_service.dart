import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Más seguro
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // <-- Más simple

class MapService {
  // ✅ Carga la clave de API de forma segura desde el archivo .env
  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    if (_apiKey == null) {
      throw Exception("API Key no encontrada en el archivo .env");
    }
    
    final url = "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey";
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "OK" && data["routes"].isNotEmpty) {
        final points = data["routes"][0]["overview_polyline"]["points"];
        // ✅ Decodifica la ruta en una sola línea usando el paquete
        return PolylinePoints().decodePolyline(points).map((p) => LatLng(p.latitude, p.longitude)).toList();
      } else {
        throw Exception("Error en Directions API: ${data["error_message"] ?? data["status"]}");
      }
    } else {
      throw Exception("Error en la solicitud HTTP: ${response.statusCode}");
    }
  }
}