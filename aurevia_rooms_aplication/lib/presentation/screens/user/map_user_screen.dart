import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/stay_model.dart';
import '../../../data/services/stay_repository.dart';
import '../../../provider/connection_provider.dart';
import '../../../data/services/local_storage_manager.dart';
import '../../../data/services/map_service.dart';
import '../../../controller/map_controller.dart';

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

    // ✅ Crear las dependencias necesarias
    final connectionProvider = ConnectionProvider();
    final localStorageManager = LocalStorageManager();
    final stayRepository = StayRepository(connectionProvider);

    // ✅ Inicializar el controlador del mapa
    _mapController = MapController(
      stayRepo: stayRepository,
      updateUI: () => setState(() {}), // fuerza reconstrucción de la UI
      showStayDetails: _showStayDetails,
      showMessage: _showSnackBar,
    );

    // ✅ Inicializar mapa (ubicación + stays)
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _mapController.initialize();
    } catch (e) {
      _errorMessage = e.toString();
    }
    setState(() => _isLoading = false);
  }

  void _showStayDetails(Stay stay) {
    // 👉 Aquí decides qué hacer cuando el usuario toca un marcador
    // Por ejemplo, mostrar un BottomSheet con información del hotel
    showModalBottomSheet(
      context: context,
      builder: (_) => _StayDetailsSheet(stay: stay),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Hoteles')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
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

  const _StayDetailsSheet({required this.stay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stay.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(stay.description ?? 'Sin descripción'),
          const SizedBox(height: 8),
          Text('Categoría: ${stay.category}'),
          if (stay.mainImageUrl != null) ...[
            const SizedBox(height: 10),
            Image.network(stay.mainImageUrl!, height: 120, fit: BoxFit.cover),
          ],
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
