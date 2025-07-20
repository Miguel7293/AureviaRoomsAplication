// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_rate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomRateImpl _$$RoomRateImplFromJson(Map<String, dynamic> json) =>
    _$RoomRateImpl(
      id: (json['id'] as num?)?.toInt(),
      roomId: (json['room_id'] as num).toInt(),
      rateType: json['rate_type'] as String,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      promotionId: json['promotion_id'] as String?,
    );

Map<String, dynamic> _$$RoomRateImplToJson(_$RoomRateImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'room_id': instance.roomId,
      'rate_type': instance.rateType,
      'price': instance.price,
      'created_at': instance.createdAt.toIso8601String(),
      'promotion_id': instance.promotionId,
    };
