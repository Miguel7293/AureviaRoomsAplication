// lib/presentation/screens/owner/add_stay_screen.dart
import 'package:aureviarooms/data/services/methods/stay_service.dart';
import 'package:flutter/material.dart';

class AddStayScreen extends StatefulWidget {
  const AddStayScreen({super.key});

  @override
  State<AddStayScreen> createState() => _AddStayScreenState();
}

class _AddStayScreenState extends State<AddStayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveStay() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newStay = await StayService.createStay(
        context: context,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
      );

      if (mounted) {
        if (newStay != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alojamiento creado con éxito'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Devuelve 'true' para indicar que se debe recargar la lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear el alojamiento'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Alojamiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Alojamiento'),
                validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría (ej. Hotel, Apartamento)'),
                validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveStay,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Guardar Alojamiento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}