import 'package:flutter/material.dart';
import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;

  const EditRoomScreen({super.key, required this.room});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _capacityController;
  late TextEditingController _imageUrlController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final f = widget.room.features ?? {};
    _nameController = TextEditingController(text: f['name'] ?? '');
    _descController = TextEditingController(text: f['description'] ?? '');
    _capacityController =
        TextEditingController(text: f['capacity']?.toString() ?? '1');
    _imageUrlController =
        TextEditingController(text: widget.room.roomImageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final updatedFeatures = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'capacity': int.tryParse(_capacityController.text.trim()) ?? 1,
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

    setState(() => _loading = false);

    if (result != null) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al actualizar habitación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color dividerColor = theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Habitación"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// ✅ NOMBRE BLOQUEADO
              _buildStyledTextField(
                icon: Icons.bed_outlined,
                label: "Nombre de la Habitación",
                controller: _nameController,
                textColor: textColor,
                dividerColor: dividerColor,
                primaryColor: primaryColor,
                readOnly: true,
              ),
              const SizedBox(height: 12),

              /// ✅ DESCRIPCIÓN
              _buildStyledTextField(
                icon: Icons.description_outlined,
                label: "Descripción",
                controller: _descController,
                textColor: textColor,
                dividerColor: dividerColor,
                primaryColor: primaryColor,
                maxLines: 2,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'La descripción no puede estar vacía';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              /// ✅ CAPACIDAD
              _buildStyledTextField(
                icon: Icons.people_outline,
                label: "Capacidad",
                controller: _capacityController,
                textColor: textColor,
                dividerColor: dividerColor,
                primaryColor: primaryColor,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Ingrese la capacidad';
                  }
                  final num? cap = int.tryParse(val);
                  if (cap == null || cap < 1) {
                    return 'Capacidad inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              /// ✅ IMAGEN
              _buildStyledTextField(
                icon: Icons.image_outlined,
                label: "URL de Imagen",
                controller: _imageUrlController,
                textColor: textColor,
                dividerColor: dividerColor,
                primaryColor: primaryColor,
              ),

              const Spacer(),

              /// ✅ BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _updateRoom,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Guardar Cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ MISMO ESTILO QUE EN PROFILEOWNER
  Widget _buildStyledTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color textColor,
    required Color dividerColor,
    required Color primaryColor,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.withOpacity(0.1) : null,
      ),
    );
  }
}
