import 'package:aureviarooms/data/services/methods/stay_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddStayScreen extends StatefulWidget {
  const AddStayScreen({super.key});

  @override
  State<AddStayScreen> createState() => _AddStayScreenState();
}

class _AddStayScreenState extends State<AddStayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  String? _selectedCategory;
  final List<String> _categories = ['hotel', 'apartment'];
  Position? _currentPosition;
  bool _isFetchingLocation = false;

  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        await _showEnableGpsDialog();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Los servicios de ubicación están desactivados.');
        }
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación están permanentemente denegados.');
      }
      
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _showEnableGpsDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activar Ubicación'),
        content: const Text('Para obtener la ubicación del alojamiento, por favor, enciende el GPS de tu dispositivo.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Ir a Ajustes'),
            onPressed: () {
              Geolocator.openLocationSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveStay() async {
    if (_formKey.currentState!.validate()) {
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, obtén la ubicación del alojamiento.'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isLoading = true);
      const defaultImageUrl = 'https://i.pinimg.com/736x/e2/d3/b2/e2d3b2a5f000bfa5b24cf53076142e93.jpg';
      final locationJson = {
        'type': 'Point',
        'coordinates': [_currentPosition!.longitude, _currentPosition!.latitude]
      };

      final newStay = await StayService.createStay(
        context: context,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        mainImageUrl: defaultImageUrl, 
        location: locationJson,
      );

      if (mounted) {
        if (newStay != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alojamiento creado con éxito'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al crear el alojamiento'), backgroundColor: Colors.red));
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Alojamiento', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(label: 'Nombre del Alojamiento'),
                validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
                maxLength: 45,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(label: 'Descripción'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _buildInputDecoration(label: 'Categoría'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                validator: (value) => value == null ? 'Por favor, selecciona una categoría' : null,
              ),
              const SizedBox(height: 32),
              const Text('Ubicación del Alojamiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    if (_currentPosition != null)
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: const Text('Ubicación Obtenida'),
                        subtitle: Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLon: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: _isFetchingLocation 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                            : const Icon(Icons.my_location),
                        label: Text(_isFetchingLocation ? 'Obteniendo...' : 'Obtener Ubicación Actual'),
                        onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveStay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                    : const Text('Guardar Alojamiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    );
  }
}