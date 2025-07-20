// lib/controller/map_controller.dart

import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/data/services/map_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapController {
  final StayRepository stayRepo;
  final Function() updateUI;
  final Function(Stay) showStayDetails;
  final Function(String) showMessage;
  
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(-15.8402, -70.0219), // Puno, Peru
    zoom: 13,
  );

  MapController({
    required this.stayRepo,
    required this.updateUI,
    required this.showStayDetails,
    required this.showMessage,
  });

  void onMapCreated(GoogleMapController controller) => _mapController = controller;

  Future<void> initialize() async {
    await _getUserLocation();
    await _loadStayMarkers();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Servicios de ubicación desactivados.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          throw Exception('Permisos de ubicación denegados.');
        }
      }
      
      _currentPosition = await Geolocator.getCurrentPosition();
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 14));
    } catch (e) {
      showMessage('No se pudo obtener la ubicación actual: ${e.toString()}');
    }
  }

  Future<void> drawRouteToStay(Stay stay) async {
    if (_currentPosition == null) {
      showMessage('Ubicación actual no disponible para trazar la ruta.');
      return;
    }
    final locationData = stay.location;
    if (locationData == null || locationData['coordinates'] is! List || (locationData['coordinates'] as List).length < 2) {
      showMessage('El destino no tiene una ubicación válida.');
      return;
    }
    
    final coords = locationData['coordinates'] as List;
    final destination = LatLng(coords[1] as double, coords[0] as double);
    
    try {
      final points = await _mapService.getRoute(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        destination,
      );
      polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.blueAccent,
          width: 6,
        )
      };
      updateUI();
    } catch (e) {
      showMessage('Error al obtener la ruta: ${e.toString()}');
    }
  }

  Future<void> _loadStayMarkers() async {
    try {
      final stays = await stayRepo.getAllPublishedStays();
      markers.clear();

      for (var stay in stays) {
        final locationData = stay.location;
        if (locationData != null && locationData['coordinates'] is List) {
          final coords = locationData['coordinates'] as List;
          if (coords.length >= 2) {
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
      updateUI();
    } catch (e) {
      showMessage('Error al cargar alojamientos: ${e.toString()}');
      throw Exception('No se pudieron cargar los marcadores.');
    }
  }

  void dispose() => _mapController?.dispose();
}