// lib/presentation/screens/owner/edit_stay_screen.dart
import 'package:flutter/material.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/methods/stay_service.dart';

class EditStayScreen extends StatefulWidget {
  final Stay stay;
  const EditStayScreen({super.key, required this.stay});

  @override
  State<EditStayScreen> createState() => _EditStayScreenState();
}

class _EditStayScreenState extends State<EditStayScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late String _status;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.stay.name);
    _descriptionController = TextEditingController(text: widget.stay.description ?? '');
    _categoryController = TextEditingController(text: widget.stay.category ?? '');
    _status = widget.stay.status ?? 'draft';
  }
  Future<Stay?> _showEditStayDialog(Stay stay) async {
  final theme = Theme.of(context);
  final Color primaryColor = theme.primaryColor;
  final Color textColor = theme.textTheme.bodyLarge!.color!;
  final Color dividerColor = theme.dividerColor;

  final nameController = TextEditingController(text: stay.name);
  final descController = TextEditingController(text: stay.description ?? "");
  final imageController = TextEditingController(text: stay.mainImageUrl ?? "");
  String status = stay.status ?? "draft";
  bool isSaving = false;

  return await showDialog<Stay>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Editar Alojamiento",
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: primaryColor)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyledTextField(
                    icon: Icons.home_outlined,
                    label: "Nombre del Alojamiento",
                    controller: nameController,
                    textColor: textColor,
                    dividerColor: dividerColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildStyledTextField(
                    icon: Icons.description_outlined,
                    label: "Descripción",
                    controller: descController,
                    textColor: textColor,
                    dividerColor: dividerColor,
                    primaryColor: primaryColor,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildStyledTextField(
                    icon: Icons.image_outlined,
                    label: "URL Imagen",
                    controller: imageController,
                    textColor: textColor,
                    dividerColor: dividerColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: "Estado",
                      prefixIcon: const Icon(Icons.toggle_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: dividerColor),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "draft", child: Text("Borrador")),
                      DropdownMenuItem(
                          value: "published", child: Text("Publicado")),
                    ],
                    onChanged: (val) => setDialogState(() => status = val!),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text("Cancelar", style: TextStyle(color: textColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);

                        final updatedStay = stay.copyWith(
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          mainImageUrl: imageController.text.trim(),
                          status: status,
                        );

                        final savedStay = await StayService.updateStay(
                          context: context,
                          stayToUpdate: updatedStay,
                        );

                        setDialogState(() => isSaving = false);

                        if (savedStay != null && context.mounted) {
                          Navigator.pop(context, savedStay);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "❌ No se pudo actualizar el alojamiento"),
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _saveChanges() async {
  setState(() => _isSaving = true);

  final updatedStay = widget.stay.copyWith(
    name: _nameController.text.trim(),
    description: _descriptionController.text.trim(),
    category: _categoryController.text.trim(),
    status: _status,
  );

  final result = await StayService.updateStay(
    context: context,
    stayToUpdate: updatedStay,
  );

  if (!mounted) return;

  if (result != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Alojamiento actualizado correctamente"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true); // Devuelve true para refrescar
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Error al actualizar"),
        backgroundColor: Colors.red,
      ),
    );
  }

  setState(() => _isSaving = false);
}
Widget _buildStyledTextField({
  required IconData icon,
  required String label,
  required TextEditingController controller,
  required Color textColor,
  required Color dividerColor,
  required Color primaryColor,
  int maxLines = 1,
  bool readOnly = false,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    style: TextStyle(color: textColor),
    readOnly: readOnly,
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
      fillColor:
          readOnly ? Colors.grey.withOpacity(0.1) : null,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Alojamiento")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Datos del Alojamiento",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Nombre"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Descripción"),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: "Categoría (Hotel, Apartamento...)"),
          ),
          const SizedBox(height: 20),

          // ✅ Selector de estado del alojamiento
          const Text("Estado", style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _status,
            items: const [
              DropdownMenuItem(value: 'draft', child: Text("Borrador")),
              DropdownMenuItem(value: 'published', child: Text("Publicado")),
              DropdownMenuItem(value: 'inactive', child: Text("Inactivo")),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _status = val);
            },
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const CircularProgressIndicator()
                : const Text("Guardar Cambios"),
          ),
        ],
      ),
    );
  }
}
