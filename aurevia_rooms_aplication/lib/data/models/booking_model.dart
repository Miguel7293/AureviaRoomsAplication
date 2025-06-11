class Booking {
  final int? bookingId;
  final String userId;
  final int roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String bookingStatus;
  final double totalPrice;
  final DateTime createdAt;

  Booking({
    this.bookingId,
    required this.userId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingStatus,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      userId: json['user_id'],
      roomId: json['room_id'],
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: DateTime.parse(json['check_out_date']),
      bookingStatus: json['booking_status'],
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'room_id': roomId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'booking_status': bookingStatus,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
