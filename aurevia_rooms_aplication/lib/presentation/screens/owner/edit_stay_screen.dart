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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late String _status;

  bool _isSaving = false;

  // ANOTACIÓN: Definimos los estados permitidos.
  final List<String> _statusOptions = ['draft', 'published', 'closed'];
  String? _selectedCategory;
  final List<String> _categoryOptions = ['hotel', 'apartment'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.stay.name);
    _descriptionController = TextEditingController(text: widget.stay.description ?? '');
    _categoryController = TextEditingController(text: widget.stay.category);
    _selectedCategory = widget.stay.category;
    
    // Aseguramos que el estado inicial sea uno de los válidos.
    _status = _statusOptions.contains(widget.stay.status) ? widget.stay.status : 'draft';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final updatedStay = widget.stay.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        status: _status,
      );

      final result = await StayService.updateStay(
        context: context,
        stayToUpdate: updatedStay,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Alojamiento actualizado correctamente"), backgroundColor: Colors.green),
        );
        
        // ANOTACIÓN: Esta es la línea clave.
        // Devolvemos el objeto 'result' (el Stay actualizado) en lugar de 'true'.
        Navigator.pop(context, result);
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Error al actualizar el alojamiento"), backgroundColor: Colors.red),
        );
        // Solo detenemos el indicador de carga en caso de error. En caso de éxito, la pantalla se cierra.
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Alojamiento")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(label: "Nombre"),
                validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                maxLength: 45,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(label: "Descripción"),
                maxLines: 4,
                maxLength: 70,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _buildInputDecoration(label: "Categoría"),
                items: _categoryOptions.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 20),

              // ANOTACIÓN: Selector de estado con las 3 opciones correctas.
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _buildInputDecoration(label: "Estado de Publicación"),
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text("Borrador (No visible para usuarios)")),
                  DropdownMenuItem(value: 'published', child: Text("Publicado (Visible para usuarios)")),
                  DropdownMenuItem(value: 'closed', child: Text("Cerrado (No admite nuevas reservas)")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text("Guardar Cambios", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ANOTACIÓN: Helper para unificar el estilo de los campos del formulario.
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
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}