// lib/presentation/screens/owner/add_room_screen.dart

import 'package:aureviarooms/data/services/methods/room_rate_service.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:flutter/material.dart';

class AddRoomScreen extends StatefulWidget {
  final int stayId;
  const AddRoomScreen({super.key, required this.stayId});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _priceController = TextEditingController(); // <-- ANOTACIÓN: Añadido para el precio
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ANOTACIÓN: La lógica de guardado ahora crea la habitación Y su tarifa
  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // 1. Crear la habitación
    final newRoom = await RoomService.createRoom(
      context: context,
      stayId: widget.stayId,
      features: {'description': _descController.text.trim()},
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    );

    // 2. Si la habitación se crea con éxito, crear su tarifa estándar
    if (newRoom != null && newRoom.roomId != null && mounted) {
      final price = double.tryParse(_priceController.text);
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Precio inválido.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }

      await RoomRateService.createRate(
        context: context,
        roomId: newRoom.roomId!,
        rateType: 'Estándar', // Se crea una tarifa estándar por defecto
        price: price,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habitación añadida con éxito'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Devuelve 'true' para indicar que se debe recargar
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la habitación'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Nueva Habitación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descController,
                decoration: _buildInputDecoration(label: 'Descripción de la habitación', hint: 'Ej: Habitación Doble con vista al lago'),
                validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // ANOTACIÓN: Campo añadido para el precio, que es esencial
              TextFormField(
                controller: _priceController,
                decoration: _buildInputDecoration(label: 'Precio por Noche', hint: 'Ej: 50.00'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El precio es requerido';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Ingrese un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: _buildInputDecoration(label: 'URL de la Imagen (Opcional)'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                    : const Text('Guardar Habitación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}