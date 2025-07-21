import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:flutter/material.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;

  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descController;
  late TextEditingController _capacityController;
  late TextEditingController _imageUrlController;

  bool _hasWifi = false;
  bool _hasTV = false;
  bool _hasPrivateBathroom = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final f = widget.room.features ?? {};
    _descController = TextEditingController(text: f['description'] ?? '');
    _capacityController = TextEditingController(text: f['capacity']?.toString() ?? '1');
    _imageUrlController = TextEditingController(text: widget.room.roomImageUrl ?? '');

    _hasWifi = (f['wifi'] as bool?) ?? false;
    _hasTV = (f['tv'] as bool?) ?? false;
    _hasPrivateBathroom = (f['private_bathroom'] as bool?) ?? false;
  }

  @override
  void dispose() {
    _descController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final updatedFeatures = {
      'description': _descController.text.trim(),
      'capacity': int.tryParse(_capacityController.text.trim()) ?? 1,
      'wifi': _hasWifi,
      'tv': _hasTV,
      'private_bathroom': _hasPrivateBathroom,
    };

    final updatedRoom = widget.room.copyWith(
      roomImageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      features: updatedFeatures,
    );

    final result = await RoomService.updateRoom(
      context: context,
      roomToUpdate: updatedRoom,
    );

    if (mounted) {
      setState(() => _loading = false);
      if (result != null) {
        Navigator.pop(context, true); // Devuelve true para recargar la lista anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al actualizar habitación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Habitación")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Habitación #${widget.room.roomId}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _descController,
              decoration: _buildInputDecoration(label: "Descripción", icon: Icons.description_outlined),
              maxLines: 2,
              validator: (val) => (val == null || val.trim().isEmpty) ? 'La descripción no puede estar vacía' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: _buildInputDecoration(label: "Capacidad (personas)", icon: Icons.people_outline),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Ingrese la capacidad';
                final num? cap = int.tryParse(val);
                if (cap == null || cap < 1) return 'Capacidad inválida';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: _buildInputDecoration(label: "URL de Imagen", icon: Icons.image_outlined),
            ),
            const Divider(height: 40),

            Text('Características Adicionales', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('WiFi'),
              value: _hasWifi,
              onChanged: (value) => setState(() => _hasWifi = value),
              secondary: const Icon(Icons.wifi),
            ),
            SwitchListTile(
              title: const Text('Televisión'),
              value: _hasTV,
              onChanged: (value) => setState(() => _hasTV = value),
              secondary: const Icon(Icons.tv),
            ),
            SwitchListTile(
              title: const Text('Baño Privado'),
              value: _hasPrivateBathroom,
              onChanged: (value) => setState(() => _hasPrivateBathroom = value),
              secondary: const Icon(Icons.bathtub_outlined),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _updateRoom,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Guardar Cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
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