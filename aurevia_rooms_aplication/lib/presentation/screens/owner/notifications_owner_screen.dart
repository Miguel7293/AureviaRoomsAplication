import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aureviarooms/data/models/booking_model.dart';
import 'package:aureviarooms/data/models/room_model.dart';
import 'package:aureviarooms/data/services/methods/booking_service.dart';
import 'package:aureviarooms/data/services/methods/room_service.dart';
import 'package:aureviarooms/provider/auth_provider.dart';

import 'booking_detail_screen.dart'; // 👈 importa la pantalla de detalles

class NotificationsOwnerScreen extends StatefulWidget {
  const NotificationsOwnerScreen({super.key});

  @override
  State<NotificationsOwnerScreen> createState() => _NotificationsOwnerScreenState();
}

class _NotificationsOwnerScreenState extends State<NotificationsOwnerScreen> {
  bool _loading = true;
  List<Booking> _pendingBookings = [];
  Map<int, Room> _roomDetails = {}; // roomId → Room

  @override
  void initState() {
    super.initState();
    _loadPendingBookings();
  }

  Future<void> _loadPendingBookings() async {
    setState(() => _loading = true);

    final authProvider = context.read<AuthProvider>();
    final ownerId = authProvider.userId;

    debugPrint("👤 Owner logueado con ID: $ownerId");

    if (ownerId == null) {
      debugPrint("⚠️ No hay owner logueado");
      setState(() {
        _pendingBookings = [];
        _loading = false;
      });
      return;
    }

    // ✅ Usamos el nuevo método optimizado para OWNER
    debugPrint("📡 Cargando reservas pendientes SOLO para este owner...");
    final ownerPending = await BookingService.getPendingBookingsForOwner(context: context);

    debugPrint("✅ Se obtuvieron ${ownerPending.length} reservas pendientes para el owner");

    // 🔍 Traemos los detalles de cada room
    Map<int, Room> roomDetailsTemp = {};
    for (var booking in ownerPending) {
      final room = await RoomService.getRoomById(
        context: context,
        roomId: booking.roomId,
      );

      if (room != null) {
        roomDetailsTemp[booking.roomId] = room;
      }
    }

    debugPrint("📊 Total de reservas pendientes finales para mostrar: ${ownerPending.length}");

    setState(() {
      _pendingBookings = ownerPending;
      _roomDetails = roomDetailsTemp;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color dividerColor = theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendingBookings.isEmpty
              ? const Center(child: Text("No hay reservas pendientes"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingBookings.length,
                  separatorBuilder: (_, __) => Divider(color: dividerColor),
                  itemBuilder: (context, index) {
                    final booking = _pendingBookings[index];
                    final room = _roomDetails[booking.roomId];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: room?.roomImageUrl != null
                              ? NetworkImage(room!.roomImageUrl!)
                              : const NetworkImage("https://via.placeholder.com/150"),
                        ),
                        title: Text(
                          room?.features?['name'] ?? "Habitación ${booking.roomId}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Check-in: ${booking.checkInDate.toString().substring(0, 10)}",
                              style: TextStyle(color: textColor.withOpacity(0.7)),
                            ),
                            Text(
                              "Check-out: ${booking.checkOutDate.toString().substring(0, 10)}",
                              style: TextStyle(color: textColor.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Estado: ${booking.bookingStatus}",
                              style: TextStyle(
                                color: booking.bookingStatus == "pending"
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right, color: primaryColor),

                        // 👇 AQUÍ LA NAVEGACIÓN
                        onTap: () async {
                          debugPrint("👆 Click en booking ${booking.bookingId}");

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailScreen(booking: booking),
                            ),
                          );

                          if (result == true) {
                            _loadPendingBookings(); // Recarga la lista si hubo cambios
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
