import 'package:flutter/material.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';

class AddRoomScreen extends StatefulWidget {
  final int stayId;

  const AddRoomScreen({super.key, required this.stayId});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _capacityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _loading = false;

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final features = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'capacity': int.tryParse(_capacityController.text.trim()) ?? 1,
    };

    final success = await RoomService.createRoom(
      context: context,
      stayId: widget.stayId,
      features: features,
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    );

    setState(() => _loading = false);

    if (success != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al crear habitación')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Agregar Habitación', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nombre de la habitación',
                validator: (v) => v!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descController,
                label: 'Descripción',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _capacityController,
                label: 'Capacidad (número de personas)',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Ingrese capacidad';
                  final cap = int.tryParse(v);
                  if (cap == null || cap <= 0) return 'Capacidad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _imageUrlController,
                label: 'URL de imagen (opcional)',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _loading ? null : _saveRoom,
                  label: const Text('Guardar habitación', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryBlue.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}
