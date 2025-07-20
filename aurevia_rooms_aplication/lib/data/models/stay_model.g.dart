// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stay_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StayImpl _$$StayImplFromJson(Map<String, dynamic> json) => _$StayImpl(
      stayId: (json['stay_id'] as num?)?.toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      mainImageUrl: json['main_image_url'] as String?,
      ownerId: json['owner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: json['location'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$StayImplToJson(_$StayImpl instance) =>
    <String, dynamic>{
      if (instance.stayId case final value?) 'stay_id': value,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'status': instance.status,
      'main_image_url': instance.mainImageUrl,
      'owner_id': instance.ownerId,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
    };
