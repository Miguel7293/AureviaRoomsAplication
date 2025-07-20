// lib/presentation/screens/owner/main_owner_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/provider/auth_provider.dart'; // <-- Necesario para obtener el ID del dueño

// Importa los otros repositorios si la tarjeta necesita calcular precios
// import 'package:aureviarooms/data/repositories/room_repository.dart';
// import 'package:aureviarooms/data/repositories/room_rate_repository.dart';


class MainOwnerScreen extends StatefulWidget {
  const MainOwnerScreen({super.key});

  @override
  State<MainOwnerScreen> createState() => _MainOwnerScreenState();
}

class _MainOwnerScreenState extends State<MainOwnerScreen> {
  late Future<List<Stay>> _ownerStaysFuture;
  String? _ownerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ANOTACIÓN: Obtenemos el ID del dueño actual desde AuthProvider.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _ownerId = authProvider.userId;
    _loadOwnerStays();
  }

  void _loadOwnerStays() {
    if (_ownerId == null) {
      // Si no hay ID de dueño, no podemos cargar nada.
      setState(() {
        _ownerStaysFuture = Future.value([]); // Devuelve una lista vacía
      });
      return;
    }
    final stayRepository = Provider.of<StayRepository>(context, listen: false);
    setState(() {
      // ANOTACIÓN: Usamos el método específico para obtener los alojamientos del dueño.
      _ownerStaysFuture = stayRepository.getStaysByOwner(_ownerId!);
    });
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
            icon: const Icon(Icons.refresh, color: Color(0xFF2A3A5B)),
            onPressed: _loadOwnerStays,
          ),
        ],
      ),
      // ANOTACIÓN: Pasamos el Future al widget de la UI.
      body: HomeTab(ownerStaysFuture: _ownerStaysFuture),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a la pantalla para crear un nuevo Stay.
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final Future<List<Stay>> ownerStaysFuture;

  const HomeTab({super.key, required this.ownerStaysFuture});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestiona tus Alojamientos', // <-- Texto adaptado para el dueño
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisa, edita o añade nuevas estancias.', // <-- Texto adaptado
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // ANOTACIÓN: La sección de búsqueda y filtros puede ser diferente para el dueño.
            // Por ahora la mantenemos, pero podrías querer cambiarla o quitarla.
            const SizedBox(height: 24),
            _buildYourPlacesList(context),
          ],
        ),
      ),
    );
  }



  Widget _buildYourPlacesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tus Alojamientos', // <-- Texto adaptado
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todos', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ANOTACIÓN: El FutureBuilder ahora consume los alojamientos del dueño.
        FutureBuilder<List<Stay>>(
          future: ownerStaysFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aún no tienes alojamientos registrados.'));
            }
            final stays = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stays.length,
              itemBuilder: (context, index) {
                final stay = stays[index];
                return _buildStayCard(stay);
              },
            );
          },
        ),
      ],
    );
  }

  // ANOTACIÓN: La tarjeta ahora solo necesita el objeto Stay.
  Widget _buildStayCard(Stay stay) {
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
              stay.mainImageUrl ?? 'https://via.placeholder.com/400x200?text=AureviaRooms',
              height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.hotel, size: 50, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stay.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                // ANOTACIÓN: Mostramos el estado del alojamiento, útil para el dueño.
                Text(
                  'Estado: ${stay.status}',
                  style: TextStyle(
                    color: stay.status == 'published' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Podrías añadir más información relevante para el dueño aquí.
              ],
            ),
          ),
        ],
      ),
    );
  }
}