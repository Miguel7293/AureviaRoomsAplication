import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/models/room_model.dart'; // Import Room model
import 'package:aureviarooms/data/models/room_rate_model.dart'; // Import RoomRate model
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/data/services/room_repository.dart'; // Import RoomRepository
import 'package:aureviarooms/data/services/room_rate_repository.dart'; // Import RoomRateRepository
import 'package:aureviarooms/presentation/screens/user/stay_detail_screen.dart'; // Importar StayDetailScreen

// --- MainUserScreen (remains StatefulWidget) ---
class MainUserScreen extends StatefulWidget {
  const MainUserScreen({super.key});

  @override
  State<MainUserScreen> createState() => _MainUserScreenState();
}

class _MainUserScreenState extends State<MainUserScreen> {
  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  late Future<List<Stay>> _availableStaysFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAvailableStays();
  }

  void _loadAvailableStays() {
    final stayRepository = Provider.of<StayRepository>(context, listen: false);
    _availableStaysFuture = stayRepository.getAllPublishedStays();
    setState(() {});
  }

  // --- Método para obtener el precio mínimo de un Stay ---
  Future<double?> _getMinPriceForStay(int stayId) async {
    try {
      final roomRepository = Provider.of<RoomRepository>(context, listen: false);
      final roomRateRepository = Provider.of<RoomRateRepository>(context, listen: false);

      final List<Room> rooms = await roomRepository.getRoomsByStay(stayId);

      if (rooms.isEmpty) return null;

      double minPrice = double.infinity;
      for (var room in rooms) {
        // Asegurarse de que roomId no sea null antes de usarlo
        if (room.roomId != null) {
          final List<RoomRate> rates = await roomRateRepository.getActiveRatesByRoom(room.roomId!);
          if (rates.isNotEmpty) {
            final currentMinRoomPrice = rates.map((r) => r.price).reduce((a, b) => a < b ? a : b);
            if (currentMinRoomPrice < minPrice) {
              minPrice = currentMinRoomPrice;
            }
          }
        }
      }
      return minPrice == double.infinity ? null : minPrice;
    } catch (e) {
      debugPrint('Error obteniendo precio mínimo para Stay $stayId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/Logo_Nombre.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text(
              'AureviaRooms',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryBlue),
            onPressed: _loadAvailableStays,
            tooltip: 'Recargar Alojamientos',
          ),
        ],
      ),
      body: HomeTab(
        availableStaysFuture: _availableStaysFuture,
        getMinPriceForStay: _getMinPriceForStay,
        primaryBlue: primaryBlue,
        accentGold: accentGold,
      ),
    );
  }
}

// --- HomeTab (remains StatelessWidget) ---
class HomeTab extends StatelessWidget {
  final Future<List<Stay>> availableStaysFuture;
  final Future<double?> Function(int stayId) getMinPriceForStay;
  final Color primaryBlue;
  final Color accentGold;

  const HomeTab({
    super.key,
    required this.availableStaysFuture,
    required this.getMinPriceForStay,
    required this.primaryBlue,
    required this.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encuentra tu estancia perfecta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Busca ofertas en hoteles, casas y mucho más...',
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            _buildSearchAndFilters(primaryBlue, accentGold),
            const SizedBox(height: 24),
            _buildFeaturedPlaces(context, availableStaysFuture, getMinPriceForStay, primaryBlue, accentGold),
          ],
        ),
      ),
    );
  }

Widget _buildSearchAndFilters(Color primaryBlue, Color accentGold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100], // Fondo más claro para el campo de búsqueda
            borderRadius: BorderRadius.circular(12), // Bordes más redondeados
            border: Border.all(color: primaryBlue.withOpacity(0.3)), // Borde sutil
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: '¿A dónde quieres ir?', // Traducido
              hintStyle: TextStyle(color: primaryBlue.withOpacity(0.6)),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: primaryBlue), // Icono en color de marca
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            style: TextStyle(color: primaryBlue), // Texto de entrada en color de marca
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('Todo', true, primaryBlue, accentGold), // Pasar colores
            _buildFilterChip('Hoteles', false, primaryBlue, accentGold), // Pasar colores
            _buildFilterChip('Apartamentos', false, primaryBlue, accentGold), // Pasar colores
            // TODO: Implementar lógica de selección para estos chips
          ],
        ),
        // ¡Se eliminó el paréntesis ')' extra aquí!
      ], // Este es el cierre de la lista de 'children' del Column
    ); // Este es el cierre del 'Column'
  } // Este es el cierre del método _buildSearchAndFilters

  Widget _buildFilterChip(String label, bool selected, Color primaryBlue, Color accentGold) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) {},
      selectedColor: primaryBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : primaryBlue,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[100],
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? primaryBlue : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildFeaturedPlaces(
      BuildContext context,
      Future<List<Stay>> staysFuture,
      Future<double?> Function(int stayId) getMinPriceForStay,
      Color primaryBlue,
      Color accentGold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alojamientos Destacados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navegar a una pantalla de "Ver todos"
              },
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Stay>>(
          future: staysFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error cargando alojamientos: ${snapshot.error}'));
            }

            final stays = snapshot.data ?? []; // <-- 'stays' se define aquí

            if (stays.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    'No hay alojamientos disponibles en este momento.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stays.length,
              itemBuilder: (context, index) {
                final stay = stays[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StayDetailScreen(stay: stay),
                      ),
                    );
                  },
                  child: _buildFeaturedPlaceCard(
                    stay: stay,
                    getMinPriceForStay: getMinPriceForStay, // <-- Aquí se pasa correctamente
                    primaryBlue: primaryBlue,
                    accentGold: accentGold,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedPlaceCard({
    required Stay stay,
    required Future<double?> Function(int stayId) getMinPriceForStay, // <-- Aquí se define
    required Color primaryBlue,
    required Color accentGold,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              stay.mainImageUrl ?? 'https://via.placeholder.com/400x200?text=No+Image',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stay.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stay.category,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<double?>(
                  future: getMinPriceForStay(stay.stayId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (snapshot.hasError) {
                      debugPrint('Error en FutureBuilder de precio: ${snapshot.error}');
                      return Text(
                        'Precio N/D',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      );
                    }
                    final price = snapshot.data;
                    return Text(
                      price != null ? '\$${price.toStringAsFixed(0)} /noche' : 'Consultar precio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentGold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}