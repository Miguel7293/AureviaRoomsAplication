import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/models/room_rate_model.dart';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:aureviarooms/data/services/room_rate_repository.dart';

class StayDetailScreen extends StatefulWidget {
  final Stay stay;

  const StayDetailScreen({super.key, required this.stay});

  @override
  State<StayDetailScreen> createState() => _StayDetailScreenState();
}

class _StayDetailScreenState extends State<StayDetailScreen> {
  late Future<List<Room>> _roomsFuture;
  // Declarar las instancias de los repositorios como 'late'
  late RoomRepository _roomRepository;
  late RoomRateRepository _roomRateRepository;

  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    // En initState() no se debe acceder al context para Providers directamente
    // Se inicializarán en didChangeDependencies()
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Aquí es seguro acceder a los Providers, ya que el context está completamente inicializado
    // y los Providers están disponibles en el árbol de widgets.
    _roomRepository = Provider.of<RoomRepository>(context, listen: false);
    _roomRateRepository = Provider.of<RoomRateRepository>(context, listen: false);
    
    // Solo carga las habitaciones si stay.stayId no es nulo
    if (widget.stay.stayId != null) {
      _loadRooms(); 
    } else {
      // Manejar el caso donde stayId es nulo, quizás mostrar un error.
      _roomsFuture = Future.error('El ID del alojamiento es nulo.');
    }
  }

  void _loadRooms() {
    _roomsFuture = _roomRepository.getRoomsByStay(widget.stay.stayId!);
    // No es necesario setState aquí, ya que el FutureBuilder en el build() se encargará de la actualización.
  }

  // Ahora _getRoomDetails usa las instancias de los repositorios ya obtenidas en didChangeDependencies
  Future<Map<String, dynamic>> _getRoomDetails(int roomId) async {
    double? minPrice;
    String? featuresText;

    try {
      final List<RoomRate> rates = await _roomRateRepository.getActiveRatesByRoom(roomId);
      if (rates.isNotEmpty) {
        minPrice = rates.map((r) => r.price).reduce((a, b) => a < b ? a : b);
      }
    } catch (e) {
      debugPrint('Error obteniendo tarifas para Room $roomId: $e');
    }

final Room? room = await RoomService.getRoomById(context: context, roomId: roomId);
final features = room?.features;
if (features != null && features.isNotEmpty) {
  // Dentro de este bloque, Dart sabe que 'features' no es nulo y es seguro de usar.
  featuresText = features.entries.map((entry) {
    final key = entry.key;
    final value = entry.value;
    if (value is bool) return '${key.replaceFirst(key[0], key[0].toUpperCase())}: ${value ? 'Sí' : 'No'}';
    return '${key.replaceFirst(key[0], key[0].toUpperCase())}: $value';
  }).join(', ');
}
    return {
      'minPrice': minPrice,
      'featuresText': featuresText,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stay.name, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.stay.mainImageUrl != null && widget.stay.mainImageUrl!.isNotEmpty)
              Image.network(
                widget.stay.mainImageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 80, color: Colors.grey[600]),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stay.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.stay.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryBlue.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.stay.description != null && widget.stay.description!.isNotEmpty)
                    Text(
                      widget.stay.description!,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Habitaciones disponibles',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Room>>(
                    future: _roomsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error cargando habitaciones: ${snapshot.error}'));
                      }
                      final rooms = snapshot.data ?? [];
                      if (rooms.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('No hay habitaciones disponibles para este alojamiento.'),
                          ),
                        );
                      }
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getRoomDetails(room.roomId!),
      builder: (context, snapshot) {
        double? price = snapshot.data?['minPrice'];
        String? features = snapshot.data?['featuresText'];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error in FutureBuilder for room details: ${snapshot.error}');
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar detalles de la habitación: ${snapshot.error}'),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    room.roomImageUrl ?? 'https://via.placeholder.com/100?text=Room',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Habitación #${room.roomId}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                      ),
                      const SizedBox(height: 8),
                      if (features != null && features.isNotEmpty)
                        Text(
                          features,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        price != null ? '\$${price.toStringAsFixed(0)} /noche' : 'Precio no disponible',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: accentGold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estado: ${room.availabilityStatus}',
                        style: TextStyle(
                            fontSize: 14,
                            color: room.availabilityStatus == 'Available' ? Colors.green : Colors.red),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: room.availabilityStatus == 'Available' ? () {
                            debugPrint('Reservar Habitación ${room.roomId}');
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGold,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reservar Ahora'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}