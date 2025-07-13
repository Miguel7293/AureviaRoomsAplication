import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/core/theme/app_theme.dart';

class MainOwnerScreen extends StatefulWidget {
  const MainOwnerScreen({super.key});

  @override
  State<MainOwnerScreen> createState() => _MainOwnerScreenState();
}

class _MainOwnerScreenState extends State<MainOwnerScreen> with SingleTickerProviderStateMixin {
  late Future<List<Stay>> _staysFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadStays();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadStays() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stayRepository = Provider.of<StayRepository>(context, listen: false);
    final ownerId = authProvider.userId;
    debugPrint('MainOwnerScreen: Owner ID: $ownerId (type: ${ownerId.runtimeType})');

    if (ownerId == null) {
      _staysFuture = Future.error('Usuario no autenticado');
    } else {
      _staysFuture = stayRepository.getStaysByOwner(ownerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightModernTheme,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: const Text('Mis Alojamientos'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => setState(_loadStays),
                      tooltip: 'Recargar',
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: FutureBuilder<List<Stay>>(
                      future: _staysFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFF333333),
                                    size: 72,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Error: ${snapshot.error}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF333333),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => setState(_loadStays),
                                    child: const Text('Intentar de nuevo'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.home_work_outlined,
                                    color: Color(0xFF333333),
                                    size: 72,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'No tienes alojamientos registrados.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final stays = snapshot.data!;
                        return ListView.builder(
                          itemCount: stays.length,
                          itemBuilder: (context, index) {
                            final stay = stays[index];
                            String locationText = 'Ubicación no disponible';
                            if (stay.location != null && stay.location!['coordinates'] != null) {
                              final coordinates = stay.location!['coordinates'] as List<dynamic>;
                              locationText = 'Lat: ${coordinates[1].toStringAsFixed(2)}, Lon: ${coordinates[0].toStringAsFixed(2)}';
                            }

                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Implementar navegación a detalles del alojamiento
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: const Color(0xFF4FC3F7).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          stay.mainImageUrl != null && stay.mainImageUrl!.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    stay.mainImageUrl!,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                                      Icons.broken_image,
                                                      size: 80,
                                                      color: Color(0xFF333333),
                                                    ),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.home,
                                                  size: 80,
                                                  color: Color(0xFF333333),
                                                ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  stay.name,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF333333),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  stay.category.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF4FC3F7),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (stay.description != null && stay.description!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      stay.description!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Color(0xFF666666),
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    locationText,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF666666),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16),
                                            child: Chip(
                                              label: Text(
                                                stay.status.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              backgroundColor: stay.status == 'published'
                                                  ? const Color(0xFF66BB6A).withOpacity(0.8)
                                                  : stay.status == 'draft'
                                                      ? const Color(0xFFFFCA28).withOpacity(0.8)
                                                      : const Color(0xFFEF5350).withOpacity(0.8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                side: BorderSide(
                                                  color: const Color(0xFF4FC3F7).withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}