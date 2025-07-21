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
  // Elimina las definiciones de colores estáticos aquí, ahora vienen del tema
  // static const Color primaryBlue = Color(0xFF2A3A5B);
  // static const Color accentGold = Color(0xFFD4AF37);

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
    // Accede a los colores del tema
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).hintColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!; // Color de texto principal
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!; // Color de texto secundario
    final Color cardColor = Theme.of(context).cardColor;
    final Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color dividerColor = Theme.of(context).dividerColor;


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldBackgroundColor, // Usa el color de fondo del Scaffold o el de la AppBar del tema
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset('assets/Logo_Nombre.png', height: 40),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor), // Usa primaryColor
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
              Text(
                'Encuentra tu estancia perfecta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Usa primaryColor
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Busca ofertas en hoteles, casas y mucho más...',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7), // Usa el color de texto y ajusta opacidad
                ),
              ),
              const SizedBox(height: 24),
              _buildSearchAndFilters(primaryColor, textColor, accentColor), // Pasa los colores
              const SizedBox(height: 24),
              _buildFeaturedPlaces(primaryColor, accentColor), // Pasa los colores
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(Color primaryColor, Color textColor, Color accentColor) {
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
                color: Theme.of(context).cardColor, // Usa el color de la tarjeta del tema
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: ListTile(
                          title: Text(option.name, style: TextStyle(color: textColor)), // Usa textColor
                        ),
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
                color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[100], // Usa color de relleno del input
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)), // Usa primaryColor
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
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)), // Usa textColor
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: primaryColor), // Usa primaryColor
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color), // Usa iconTheme color
                          onPressed: () {
                            controller.clear();
                            _clearSearch();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: TextStyle(color: textColor), // Usa textColor
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip('Todo', primaryColor, textColor), // Pasa los colores
            _buildFilterChip('Hotel', primaryColor, textColor), // Pasa los colores
            _buildFilterChip('Apartamento', primaryColor, textColor), // Pasa los colores
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Color primaryColor, Color textColor) {
    bool isSelected = _selectedCategory == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) _selectCategory(label);
      },
      selectedColor: primaryColor, // Usa primaryColor
      checkmarkColor: Theme.of(context).colorScheme.onPrimary, // Color del checkmark basado en el tema
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : textColor, // Usa colorScheme.onPrimary para texto seleccionado
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context).secondaryHeaderColor, // Puedes usar secondaryHeaderColor o cardColor
      shape: StadiumBorder(side: BorderSide(color: isSelected ? primaryColor : Theme.of(context).dividerColor)), // Usa primaryColor y dividerColor
    );
  }

  Widget _buildFeaturedPlaces(Color primaryColor, Color accentColor) {
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
                color: primaryColor, // Usa primaryColor
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implementar navegación a ver todos los alojamientos
              },
              child: Text(
                'Ver todos',
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold), // Usa accentColor
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStaysList(primaryColor, accentColor), // Pasa los colores
      ],
    );
  }

  Widget _buildStaysList(Color primaryColor, Color accentColor) {
    return FutureBuilder<List<Stay>>(
      future: _staysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error))); // Usa color de error del tema
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No se encontraron alojamientos.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color))); // Usa color de texto pequeño del tema

        final allStays = snapshot.data!;
        final displayedStays = allStays.where((stay) {
          return _selectedCategory == 'Todo' || stay.category.toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        if (displayedStays.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'No hay alojamientos en esta categoría.',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 16), // Usa color de texto pequeño del tema
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedStays.length,
          itemBuilder: (context, index) {
            final stay = displayedStays[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StayDetailScreen(stay: stay))),
              child: _buildFeaturedPlaceCard(stay, primaryColor, accentColor), // Pasa los colores
            );
          },
        );
      },
    );
  }

  Widget _buildFeaturedPlaceCard(Stay stay, Color primaryColor, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor, // Usa el color de la tarjeta del tema
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
                color: Theme.of(context).disabledColor.withOpacity(0.3), // Usa el color de widgets deshabilitados
                child: Icon(Icons.broken_image, size: 50, color: Theme.of(context).iconTheme.color), // Usa el color de icono del tema
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor, // Usa primaryColor
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  stay.category,
                  style: Theme.of(context).textTheme.bodyMedium, // Usa el estilo de texto del tema
                ),
                const SizedBox(height: 8),
                FutureBuilder<double?>(
                  future: _getMinPriceForStay(stay.stayId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return Text(
                        'Consultar precio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentColor, // Usa accentColor
                        ),
                      );
                    }
                    final price = snapshot.data!;
                    return Text(
                      '\$${price.toStringAsFixed(0)} /noche',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor, // Usa accentColor
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