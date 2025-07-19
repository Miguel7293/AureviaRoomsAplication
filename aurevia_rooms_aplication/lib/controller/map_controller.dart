import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models/stay_model.dart';
import '../data/services/stay_repository.dart';
import '../data/services/map_service.dart';

class MapController {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final StayRepository _stayRepo;
  final MapService _mapService = MapService();

  // Cusco (por ejemplo) como posición inicial si no hay ubicación
  final LatLng _initialPosition = const LatLng(-15.8402, -70.0219);

  final Function() updateUI;
  final Function(Stay) showStayDetails;
  final Function(String) showMessage;

  MapController({
    required StayRepository stayRepo,
    required this.updateUI,
    required this.showStayDetails,
    required this.showMessage,
  }) : _stayRepo = stayRepo;

  CameraPosition get initialCameraPosition =>
      CameraPosition(target: _initialPosition, zoom: 13);

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> initialize() async {
    await _getUserLocation();
    await _loadStays();
  }

  void dispose() {
    _mapController?.dispose();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showMessage('Los servicios de ubicación están desactivados.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showMessage('Permiso de ubicación denegado.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showMessage('Permisos de ubicación bloqueados permanentemente.');
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );


    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _loadStays() async {
    try {
      final stays = await _stayRepo.getAllPublishedStays();
      markers.clear();

      for (var stay in stays) {
        final locationData = stay.location;
        if (locationData != null && locationData['coordinates'] is List) {
          final coords = locationData['coordinates'] as List;
          if (coords.length >= 2) {
            // GeoJSON [lng, lat]
            final lat = coords[1] as double;
            final lng = coords[0] as double;
            final position = LatLng(lat, lng);

            markers.add(
              Marker(
                markerId: MarkerId(stay.stayId.toString()),
                position: position,
                infoWindow: InfoWindow(title: stay.name),
                onTap: () => showStayDetails(stay),
              ),
            );
          }
        }
      }

      updateUI(); // notifica a la UI para reconstruir
    } catch (e) {
      showMessage("Error al cargar los alojamientos: ${e.toString()}");
    }
  }

  /// ✅ Opcional: dibujar una ruta desde tu ubicación al destino
  Future<void> drawRoute(LatLng destination) async {
    if (_currentPosition == null) {
      showMessage('Ubicación actual no disponible');
      return;
    }

    final origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final points = await _mapService.getRouteCoordinates(origin, destination);

    polylines.clear();
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: points,
      ),
    );

    updateUI();

    // Opcional: centrar la cámara en la ruta
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(points), 50),
      );
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// ✅ Enfocar manualmente una ubicación
  void focusOnLocation(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
  }
}
