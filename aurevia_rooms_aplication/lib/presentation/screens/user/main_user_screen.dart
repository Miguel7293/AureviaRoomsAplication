import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/models/room_rate_model.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:aureviarooms/data/services/room_rate_repository.dart';
import 'package:aureviarooms/presentation/screens/user/stay_detail_screen.dart';

class MainUserScreen extends StatefulWidget {
  const MainUserScreen({super.key});

  @override
  State<MainUserScreen> createState() => _MainUserScreenState();
}

class _MainUserScreenState extends State<MainUserScreen> {
  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  late Future<List<Stay>> _staysFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todo';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchStays();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchStays() {
    final stayRepository = Provider.of<StayRepository>(context, listen: false);
    setState(() {
      if (_searchQuery.isEmpty) {
        _staysFuture = stayRepository.getAllPublishedStays();
      } else {
        _staysFuture = stayRepository.searchStays(_searchQuery);
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _selectedCategory = 'Todo';
    });
    _fetchStays();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _fetchStays();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<double?> _getMinPriceForStay(int stayId) async {
    if (!mounted) return null;
    try {
      final roomRepository = Provider.of<RoomRepository>(context, listen: false);
      final roomRateRepository = Provider.of<RoomRateRepository>(context, listen: false);
      final rooms = await roomRepository.getRoomsByStay(stayId);
      if (rooms.isEmpty) return null;

      double minPrice = double.infinity;
      for (var room in rooms) {
        if (room.roomId != null) {
          final rates = await roomRateRepository.getActiveRatesByRoom(room.roomId!);
          if (rates.isNotEmpty) {
            final minRoomPrice = rates.map((r) => r.price).reduce((a, b) => a < b ? a : b);
            if (minRoomPrice < minPrice) minPrice = minRoomPrice;
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
          child: Image.asset('assets/Logo_Nombre.png', height: 40),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryBlue),
            onPressed: _fetchStays,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Encuentra tu estancia perfecta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 8),
              Text('Busca ofertas en hoteles, casas y mucho más...', style: TextStyle(fontSize: 16, color: primaryBlue.withOpacity(0.7))),
              const SizedBox(height: 24),
              _buildSearchAndFilters(),
              const SizedBox(height: 24),
              _buildFeaturedPlaces(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final stayRepository = Provider.of<StayRepository>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Stay>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.length < 2) return const Iterable<Stay>.empty();
            return stayRepository.searchStays(textEditingValue.text);
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: ListTile(title: Text(option.name)),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          displayStringForOption: (Stay option) => option.name,
          onSelected: (Stay selection) => _performSearch(selection.name),
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryBlue.withOpacity(0.3)),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (value) {
                  _performSearch(value);
                  onFieldSubmitted();
                },
                decoration: InputDecoration(
                  hintText: '¿A dónde quieres ir?',
                  hintStyle: TextStyle(color: primaryBlue.withOpacity(0.6)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: primaryBlue),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            controller.clear();
                            _clearSearch();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: TextStyle(color: primaryBlue),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('Todo'),
            _buildFilterChip('Hotel'),
            _buildFilterChip('Apartamento'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategory == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) _selectCategory(label);
      },
      selectedColor: primaryBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : primaryBlue,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[100],
      shape: StadiumBorder(side: BorderSide(color: isSelected ? primaryBlue : Colors.grey[300]!)),
    );
  }

  Widget _buildFeaturedPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Alojamientos Destacados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
            TextButton(
              onPressed: () {},
              child: Text('Ver todos', style: TextStyle(color: accentGold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStaysList(), // Aquí se llama al método que faltaba
      ],
    );
  }

  // ANOTACIÓN: Aquí está el método que te faltaba.
  Widget _buildStaysList() {
    return FutureBuilder<List<Stay>>(
      future: _staysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No se encontraron alojamientos.'));

        final allStays = snapshot.data!;
        final displayedStays = allStays.where((stay) {
          return _selectedCategory == 'Todo' || stay.category.toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        if (displayedStays.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text('No hay alojamientos en esta categoría.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedStays.length,
          itemBuilder: (context, index) {
            final stay = displayedStays[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StayDetailScreen(stay: stay))),
              child: _buildFeaturedPlaceCard(stay),
            );
          },
        );
      },
    );
  }

  // ANOTACIÓN: Y este es el widget de la tarjeta que usa el método anterior.
  Widget _buildFeaturedPlaceCard(Stay stay) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              errorBuilder: (context, _, __) => Container(
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
                Text(stay.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                const SizedBox(height: 4),
                Text(stay.category, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                FutureBuilder<double?>(
                  future: _getMinPriceForStay(stay.stayId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                       return Text(
                        'Consultar precio',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentGold),
                      );
                    }
                    final price = snapshot.data!;
                    return Text(
                      '\$${price.toStringAsFixed(0)} /noche',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentGold),
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