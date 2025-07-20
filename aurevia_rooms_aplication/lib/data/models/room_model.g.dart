// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
      roomId: (json['room_id'] as num?)?.toInt(),
      stayId: (json['stay_id'] as num).toInt(),
      availabilityStatus: json['availability_status'] as String,
      roomImageUrl: json['room_image_url'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      if (instance.roomId case final value?) 'room_id': value,
      'stay_id': instance.stayId,
      'availability_status': instance.availabilityStatus,
      'room_image_url': instance.roomImageUrl,
      'features': instance.features,
      'created_at': instance.createdAt.toIso8601String(),
    };
