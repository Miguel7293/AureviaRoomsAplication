import 'package:aureviarooms/data/models/booking_model.dart';
import 'package:aureviarooms/data/models/promotion_model.dart';
import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/models/stay_model.dart';
import 'package:aureviarooms/data/models/room_rate_model.dart';
import 'package:aureviarooms/data/services/methods/booking_service.dart';
import 'package:aureviarooms/data/services/methods/promotion_service.dart';
import 'package:aureviarooms/data/services/methods/room_rate_service.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:flutter/material.dart';

// ANOTACIÓN: La clase auxiliar ahora también incluye las reservas del usuario.
class StayDetailsData {
  final List<Room> rooms;
  final List<Promotion> promotions;
  final List<Booking> userBookings;
  StayDetailsData({required this.rooms, required this.promotions, required this.userBookings});
}

class DisplayRateInfo {
  final RoomRate? standardRate;
  final RoomRate? promotionalRate;
  final Promotion? promotion;
  DisplayRateInfo({this.standardRate, this.promotionalRate, this.promotion});
}

class StayDetailScreen extends StatefulWidget {
  final Stay stay;
  const StayDetailScreen({super.key, required this.stay});

  @override
  State<StayDetailScreen> createState() => _StayDetailScreenState();
}

class _StayDetailScreenState extends State<StayDetailScreen> {
  late Future<StayDetailsData> _detailsFuture;
  
  static const Color primaryBlue = Color(0xFF2A3A5B);
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStayDetails();
  }

  void _loadStayDetails() {
    if (widget.stay.stayId == null) {
      _detailsFuture = Future.error('El ID del alojamiento es nulo.');
      return;
    }
    setState(() {
      _detailsFuture = _fetchDetails();
    });
  }
  
  // ANOTACIÓN: Ahora cargamos habitaciones, promociones y las reservas del usuario en paralelo.
  Future<StayDetailsData> _fetchDetails() async {
    final stayId = widget.stay.stayId!;
    final results = await Future.wait([
      RoomService.getAvailableRoomsByStay(context: context, stayId: stayId),
      PromotionService.getActivePromotionsByStay(context: context, stayId: stayId),
      BookingService.getBookingsForCurrentUser(context: context), // <-- Se añade la llamada
    ]);
    return StayDetailsData(
      rooms: results[0] as List<Room>,
      promotions: results[1] as List<Promotion>,
      userBookings: results[2] as List<Booking>, // <-- Se guardan las reservas
    );
  }

  void _handleBookingRequest(BuildContext context, Room room, double price) async {
    final checkInDate = DateTime.now();
    final checkOutDate = DateTime.now().add(const Duration(days: 1));

    final booking = await BookingService.createBooking(
      context: context,
      roomId: room.roomId!,
      checkIn: checkInDate,
      checkOut: checkOutDate,
      totalPrice: price,
    );

    if (booking != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Solicitud de reserva enviada!'), backgroundColor: Colors.green),
      );
      // ANOTACIÓN: Volvemos a cargar los datos para que el estado del botón se actualice inmediatamente.
      _loadStayDetails(); 
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar la solicitud.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stay.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.stay.mainImageUrl != null)
              Image.network(
                widget.stay.mainImageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.stay.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.stay.description ?? 'Sin descripción.', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 24),
                  Text('Habitaciones disponibles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
                  const SizedBox(height: 16),
                  FutureBuilder<StayDetailsData>(
                    future: _detailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.rooms.isEmpty) {
                        return const Center(child: Text('No hay habitaciones disponibles.'));
                      }
                      
                      final rooms = snapshot.data!.rooms;
                      final promotions = snapshot.data!.promotions;
                      final userBookings = snapshot.data!.userBookings;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          return _RoomCard(
                            room: rooms[index],
                            promotions: promotions,
                            userBookings: userBookings, // <-- Pasamos las reservas del usuario
                            onBook: (price) => _handleBookingRequest(context, rooms[index], price),
                          );
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
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final List<Promotion> promotions;
  final List<Booking> userBookings; // <-- Recibe las reservas
  final Function(double price) onBook;

  const _RoomCard({
    required this.room,
    required this.promotions,
    required this.userBookings,
    required this.onBook,
  });

  Future<DisplayRateInfo?> _getRateDetails(BuildContext context) async {
    final allRates = await RoomRateService.getRatesByRoom(context: context, roomId: room.roomId!);
    if (allRates.isEmpty) return null;

    RoomRate? standardRate;
    RoomRate? promotionalRate;

    for (var rate in allRates) {
      if (rate.promotionId == null) {
        standardRate = rate;
      } else {
        promotionalRate = rate;
      }
    }

    if (promotionalRate != null) {
      Promotion? promotionDetails;
      if (promotionalRate.promotionId != null) {
        try {
          promotionDetails = promotions.firstWhere((p) => p.promotionId == promotionalRate!.promotionId);
        } catch (e) { /* Promoción no activa */ }
      }
      return DisplayRateInfo(
        standardRate: standardRate, 
        promotionalRate: promotionalRate,
        promotion: promotionDetails,
      );
    } else if (standardRate != null) {
      return DisplayRateInfo(standardRate: standardRate);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = room.availabilityStatus.toLowerCase() == 'available';
    // ANOTACIÓN: Verificamos si ya existe una solicitud pendiente o confirmada para esta habitación.
    final hasPendingBooking = userBookings.any((b) => b.roomId == room.roomId && (b.bookingStatus == 'pending' || b.bookingStatus == 'confirmed'));
    
    final Color statusColor = isAvailable ? Colors.green : Colors.red;
    final String statusText = isAvailable ? 'Disponible' : 'No Disponible';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room.roomImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  room.roomImageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(room.features?['description'] ?? 'Habitación Estándar', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Estado: $statusText',
              style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<DisplayRateInfo?>(
              future: _getRateDetails(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Precio no disponible.');
                }

                final rateInfo = snapshot.data!;
                final standardPrice = rateInfo.standardRate?.price;
                final promotionalPrice = rateInfo.promotionalRate?.price;
                final promotion = rateInfo.promotion;
                final finalPrice = promotionalPrice ?? standardPrice ?? 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (promotion != null && promotionalPrice != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200)
                        ),
                        child: Text(
                          '🎉 OFERTA: ${promotion.description}',
                          style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (promotionalPrice != null && standardPrice != null)
                              Text(
                                '\$${standardPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            Text(
                              '\$${finalPrice.toStringAsFixed(0)} /noche',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                        // ANOTACIÓN: El botón ahora comprueba si ya existe una reserva.
                        ElevatedButton(
                          onPressed: (finalPrice > 0 && isAvailable && !hasPendingBooking) ? () => onBook(finalPrice) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasPendingBooking ? Colors.grey : Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(hasPendingBooking ? 'Solicitud Enviada' : 'Solicitar Reserva'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}