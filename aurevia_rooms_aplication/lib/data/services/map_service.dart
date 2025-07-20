import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  final String googleApiKey = 'TU_API_KEY_DE_GOOGLE_MAPS'; // pon tu API Key

  /// ✅ Obtiene las coordenadas de una ruta (polyline) entre dos puntos
  Future<List<LatLng>> getRouteCoordinates(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error obteniendo la ruta');
    }

    final data = jsonDecode(response.body);

    if ((data['routes'] as List).isEmpty) {
      throw Exception('No se encontró ninguna ruta');
    }

    final points = data['routes'][0]['overview_polyline']['points'];
    return _decodePolyline(points);
  }

  /// ✅ Decodifica polyline en lista de LatLng
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }
}
