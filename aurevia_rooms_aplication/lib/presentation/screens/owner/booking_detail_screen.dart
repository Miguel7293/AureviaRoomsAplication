import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aureviarooms/data/models/booking_model.dart';
import 'package:aureviarooms/data/models/user_model.dart';
import 'package:aureviarooms/data/services/user_model_repository.dart';
import 'package:aureviarooms/data/services/booking_repository.dart';
import 'package:aureviarooms/data/services/room_repository.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  UserModel? requester;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequesterInfo();
  }

  Future<void> _loadRequesterInfo() async {
    try {
      final userRepo = context.read<UserModelRepository>();
      final user = await userRepo.getUserById(widget.booking.userId);

      setState(() {
        requester = user;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando info del usuario solicitante: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    final bookingRepo = context.read<BookingRepository>();
    final roomRepo = context.read<RoomRepository>();

    try {
      final updatedBooking = widget.booking.copyWith(bookingStatus: newStatus);
      await bookingRepo.updateBooking(updatedBooking);

      if (newStatus == 'confirmed') {
        final room = await roomRepo.getRoomById(widget.booking.roomId);
        final updatedRoom = room.copyWith(availabilityStatus: 'unavailable');
        await roomRepo.updateRoom(updatedRoom);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(
            newStatus == "confirmed"
                ? '✅ Reserva confirmada correctamente'
                : '❌ Reserva rechazada',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Error actualizando estado de reserva: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la reserva')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    // 🎨 Colores del tema (igual que MainUserScreen)
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).hintColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final Color cardColor = Theme.of(context).cardColor;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldBg,
        iconTheme: IconThemeData(color: primaryColor),
        title: Text(
          "Detalle de Reserva",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requester == null
              ? Center(
                  child: Text(
                    "❌ No se pudo cargar la info del usuario",
                    style: TextStyle(color: textColor),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏷️ Booking ID y Estado
                      _buildInfoCard(
                        context,
                        icon: Icons.confirmation_number,
                        title: "Booking ID",
                        value: booking.bookingId?.toString() ?? "N/A",
                        primaryColor: primaryColor,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        context,
                        icon: Icons.info_outline,
                        title: "Estado",
                        value: booking.bookingStatus.toUpperCase(),
                        primaryColor: primaryColor,
                        textColor: booking.bookingStatus == "pending"
                            ? Colors.orange
                            : booking.bookingStatus == "confirmed"
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(height: 12),

                      // 👤 Usuario solicitante
                      _buildInfoCard(
                        context,
                        icon: Icons.person,
                        title: "Solicitante",
                        value: "${requester!.username}\n${requester!.email}\nTel: ${requester!.phoneNumber ?? 'No registrado'}",
                        primaryColor: primaryColor,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 12),

                      // 📅 Fechas
                      _buildInfoCard(
                        context,
                        icon: Icons.calendar_today,
                        title: "Fechas de reserva",
                        value: "Check-in: ${booking.checkInDate.toString().substring(0, 10)}\n"
                            "Check-out: ${booking.checkOutDate.toString().substring(0, 10)}",
                        primaryColor: primaryColor,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 24),

                      // ✅ Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateBookingStatus('declined'),
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text("Rechazar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateBookingStatus('confirmed'),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text("Aceptar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }

  /// 🔹 Tarjeta reutilizable para mostrar info con mismo estilo de MainUserScreen
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
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
