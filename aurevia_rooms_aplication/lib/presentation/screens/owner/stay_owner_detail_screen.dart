// lib/presentation/screens/owner/owner_stay_detail_screen.dart

import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:aureviarooms/presentation/screens/owner/add_room_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/edit_room_screen.dart';
import 'package:aureviarooms/presentation/screens/owner/edit_stay_screen.dart';
import 'package:flutter/material.dart';

class StayOwnerDetailScreen extends StatefulWidget {
  final Stay stay;
  const StayOwnerDetailScreen({super.key, required this.stay});

  @override
  State<StayOwnerDetailScreen> createState() => _OwnerStayDetailScreenState();
}

class _OwnerStayDetailScreenState extends State<StayOwnerDetailScreen> {
  static const Color primaryBlue = Color(0xFF2A3A5B);
  late Stay _currentStay;
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _currentStay = widget.stay;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRooms();
  }

  void _loadRooms() {
    if (_currentStay.stayId == null) {
      _roomsFuture = Future.value([]);
      return;
    }
    setState(() {
      _roomsFuture = RoomService.getRoomsByStay(context: context, stayId: _currentStay.stayId!);
    });
  }

  void _navigateToEditStay() async {
    final updatedStay = await Navigator.push<Stay>(
      context,
      MaterialPageRoute(builder: (_) => EditStayScreen(stay: _currentStay)),
    );
    if (updatedStay != null) {
      setState(() {
        _currentStay = updatedStay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStay.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditStay,
            tooltip: 'Editar Alojamiento',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => AddRoomScreen(stayId: _currentStay.stayId!)),
          );
          if (result == true) {
            _loadRooms();
          }
        },
        tooltip: 'Añadir Habitación',
        child: const Icon(Icons.add_business_rounded),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStayHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            _buildRoomsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStayHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentStay.mainImageUrl != null)
          Image.network(
            _currentStay.mainImageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentStay.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_currentStay.description ?? "Sin descripción", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _currentStay.status == 'published' ? Icons.public : Icons.lock_outline,
                    color: _currentStay.status == 'published' ? Colors.green : Colors.orange,
                    size: 16
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estado: ${_currentStay.status}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _currentStay.status == 'published' ? Colors.green : Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Habitaciones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
          const SizedBox(height: 16),
          FutureBuilder<List<Room>>(
            future: _roomsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No hay habitaciones registradas."));
              }
              final rooms = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rooms.length,
                // ANOTACIÓN: Aquí pasamos el índice (index + 1) a la función que construye la tarjeta.
                itemBuilder: (context, index) => _buildRoomCard(rooms[index], index + 1),
              );
            },
          ),
        ],
      ),
    );
  }

  // ANOTACIÓN: El método ahora acepta un 'roomNumber' para mostrarlo.
  Widget _buildRoomCard(Room room, int roomNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.bed, color: primaryBlue),
        // ANOTACIÓN: El título ahora es el número de la habitación.
        title: Text('Habitación $roomNumber'),
        // ANOTACIÓN: Usamos el subtítulo para la descripción y el estado.
        subtitle: Text('${room.features?['description'] ?? 'Sin descripción'}\nEstado: ${room.availabilityStatus}'),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditRoomScreen(room: room),
            ),
          );
          if (result == true) {
            _loadRooms();
          }
        },
      ),
    );
  }
}