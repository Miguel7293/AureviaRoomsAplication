// lib/presentation/screens/user/map_user_screen.dart

import 'package:aureviarooms/presentation/screens/user/stay_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../data/models/stay_model.dart';
import '../../../data/services/stay_repository.dart';
import '../../../controller/map_controller.dart';
import '../../../provider/connection_provider.dart';
import '../../../data/services/local_storage_manager.dart';
import '../../../data/services/map_service.dart';

class MapUserScreen extends StatefulWidget {
  const MapUserScreen({super.key});

  @override
  State<MapUserScreen> createState() => _MapUserScreenState();
}

class _MapUserScreenState extends State<MapUserScreen> {
  late MapController _mapController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final stayRepository = Provider.of<StayRepository>(context, listen: false);

    // ✅ Crear las dependencias necesarias
    final connectionProvider = ConnectionProvider();
    final localStorageManager = LocalStorageManager();

    // ✅ Inicializar el controlador del mapa
    _mapController = MapController(
      stayRepo: stayRepository,
      updateUI: () { if (mounted) setState(() {}); },
      showStayDetails: _showStayDetails,
      showMessage: _showSnackBar,
    );

    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _mapController.initialize();
    } catch (e) {
      if (mounted) _errorMessage = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showStayDetails(Stay stay) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StayDetailsSheet(
        stay: stay,
        onGetDirections: () {
          Navigator.pop(context);
          _mapController.drawRouteToStay(stay);
        },
        onViewDetails: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StayDetailScreen(stay: stay)),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Alojamientos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error al cargar el mapa: $_errorMessage', textAlign: TextAlign.center),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: _mapController.initialCameraPosition,
                  markers: _mapController.markers,
                  polylines: _mapController.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: _mapController.onMapCreated,
                ),
    );
  }
}

class _StayDetailsSheet extends StatelessWidget {
  final Stay stay;
  final VoidCallback onGetDirections;
  final VoidCallback onViewDetails;

  const _StayDetailsSheet({
    required this.stay,
    required this.onGetDirections,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stay.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(stay.description ?? 'Sin descripción disponible.', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
          const SizedBox(height: 12),
          Text('Categoría: ${stay.category}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Saber más'),
                  onPressed: onViewDetails,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Cómo llegar'),
                  onPressed: onGetDirections,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}