// lib/data/models/booking_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class Booking with _$Booking {
  const factory Booking({
    @JsonKey(name: 'booking_id', includeIfNull: false) int? bookingId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'room_id') required int roomId,
    @JsonKey(name: 'check_in_date') required DateTime checkInDate,
    @JsonKey(name: 'check_out_date') required DateTime checkOutDate,
    @JsonKey(name: 'booking_status') required String bookingStatus,
    @JsonKey(name: 'total_price') required double totalPrice,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}