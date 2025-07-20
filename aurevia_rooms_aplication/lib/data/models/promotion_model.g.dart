// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromotionImpl _$$PromotionImplFromJson(Map<String, dynamic> json) =>
    _$PromotionImpl(
      promotionId: json['promotion_id'] as String?,
      stayId: (json['stay_id'] as num).toInt(),
      description: json['description'] as String,
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      state: json['state'] as String,
    );

Map<String, dynamic> _$$PromotionImplToJson(_$PromotionImpl instance) =>
    <String, dynamic>{
      if (instance.promotionId case final value?) 'promotion_id': value,
      'stay_id': instance.stayId,
      'description': instance.description,
      'discount_percentage': instance.discountPercentage,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'state': instance.state,
    };
