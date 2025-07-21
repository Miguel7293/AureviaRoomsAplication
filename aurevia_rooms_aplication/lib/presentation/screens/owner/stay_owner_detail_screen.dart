import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:aureviarooms/data/services/methods/stay_service.dart';

import 'package:aureviarooms/presentation/screens/owner/edit_room_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/add_room_screen.dart';

class StayOwnerDetailScreen extends StatefulWidget {
  final Stay stay;

  const StayOwnerDetailScreen({super.key, required this.stay});

  @override
  State<StayOwnerDetailScreen> createState() => _StayOwnerDetailScreenState();
}

class _StayOwnerDetailScreenState extends State<StayOwnerDetailScreen> {
  static const Color primaryBlue = Color(0xFF2A3A5B);

  late Stay _currentStay; // ✅ Estado editable del alojamiento
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _currentStay = widget.stay; // copiamos el Stay inicial
    _loadRooms();
  }

  void _loadRooms() {
    final roomRepo = Provider.of<RoomRepository>(context, listen: false);
    setState(() {
      _roomsFuture = roomRepo.getRoomsByStay(_currentStay.stayId!);
    });
  }

  Future<void> _deleteRoom(Room room) async {
    final roomRepo = Provider.of<RoomRepository>(context, listen: false);

    final features = room.features ?? {};
    final name = features['name'] ?? 'Habitación';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar habitación"),
        content: Text("¿Seguro que deseas eliminar la habitación '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await roomRepo.deleteRoom(room.roomId!);
      _loadRooms(); // recargar lista
    }
  }

  /// ✅ Diálogo para editar el alojamiento y guardar en Supabase
  Future<Stay?> _showEditStayDialog(Stay stay) async {
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
              title: const Text("Editar alojamiento"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Nombre"),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Descripción"),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: "URL Imagen"),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: "Estado"),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
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
                                  content: Text("❌ No se pudo actualizar el alojamiento"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF2A3A5B)),
        title: Text(
          _currentStay.name, // ✅ usamos el estado actualizado
          style: const TextStyle(
              color: Color(0xFF2A3A5B), fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRoomScreen(stayId: _currentStay.stayId!),
            ),
          );
          if (added == true) _loadRooms();
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStayInfoCard(),
            const SizedBox(height: 24),
            _buildRoomsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStayInfoCard() {
    return GestureDetector(
      onTap: () async {
        final updatedStay = await _showEditStayDialog(_currentStay);
        if (updatedStay != null) {
          setState(() {
            _currentStay = updatedStay; // ✅ Actualizamos el estado local
          });
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                _currentStay.mainImageUrl ??
                    'https://via.placeholder.com/400x200?text=Stay',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentStay.name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentStay.description ?? "Sin descripción",
                    style: TextStyle(
                        fontSize: 14, color: primaryBlue.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text("Estado: ${_currentStay.status}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentStay.status == 'published'
                              ? Colors.green
                              : Colors.orange)),
                  const SizedBox(height: 6),
                  const Text(
                    "👉 Toca la tarjeta para editar",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Habitaciones",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
        const SizedBox(height: 16),
        FutureBuilder<List<Room>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Text("Error: ${snapshot.error}");
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text("No hay habitaciones registradas."),
                ),
              );
            }

            final rooms = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _buildRoomCard(room);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoomCard(Room room) {
    final features = room.features ?? {};
    final name = features['name'] ?? 'Habitación sin nombre';
    final description = features['description'] ?? 'Sin descripción';
    final capacity = features['capacity']?.toString() ?? '1';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (room.roomImageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                room.roomImageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.bed, size: 50, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: primaryBlue.withOpacity(0.7)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Capacidad: $capacity",
                        style: TextStyle(
                            fontSize: 13,
                            color: primaryBlue.withOpacity(0.8))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditRoomScreen(room: room),
                          ),
                        );
                        if (updated == true) _loadRooms();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteRoom(room),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
