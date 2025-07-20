// lib/presentation/screens/user/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:aureviarooms/data/services/room_rate_repository.dart';
import 'package:aureviarooms/presentation/screens/user/stay_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<Stay> allStays;
  const SearchScreen({super.key, required this.allStays});


  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Stay> _filteredStays = [];
  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _filteredStays = widget.allStays;
    _searchController.addListener(() {
      _filterStays();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStays() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStays = widget.allStays.where((stay) {
        final nameMatch = stay.name.toLowerCase().contains(query);
        final categoryMatch = stay.category.toLowerCase().contains(query);
        return nameMatch || categoryMatch;
      }).toList();
    });
  }

  Future<double?> _getMinPriceForStay(int stayId) async {
    // Copiamos la misma lógica de la pantalla principal para que las tarjetas funcionen
    if (!mounted) return null;
    final roomRepository = Provider.of<RoomRepository>(context, listen: false);
    final roomRateRepository = Provider.of<RoomRateRepository>(context, listen: false);
    // ... (el resto de la lógica de getMinPrice es idéntica)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Alojamientos'),
        backgroundColor: const Color(0xFF2A3A5B),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredStays.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron coincidencias.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStays.length,
                    itemBuilder: (context, index) {
                      final stay = _filteredStays[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StayDetailScreen(stay: stay))),
                        child: _buildFeaturedPlaceCard(stay),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o categoría...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
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
                    final price = snapshot.data;
                    return Text(
                      price != null ? '\$${price.toStringAsFixed(0)} /noche' : 'Consultar precio',
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