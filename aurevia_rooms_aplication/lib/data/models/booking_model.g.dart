// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      bookingId: (json['booking_id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      roomId: (json['room_id'] as num).toInt(),
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      bookingStatus: json['booking_status'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      if (instance.bookingId case final value?) 'booking_id': value,
      'user_id': instance.userId,
      'room_id': instance.roomId,
      'check_in_date': instance.checkInDate.toIso8601String(),
      'check_out_date': instance.checkOutDate.toIso8601String(),
      'booking_status': instance.bookingStatus,
      'total_price': instance.totalPrice,
      'created_at': instance.createdAt.toIso8601String(),
    };
