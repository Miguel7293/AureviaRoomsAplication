// lib/data/models/promotion_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion_model.freezed.dart';
part 'promotion_model.g.dart';

@freezed
class Promotion with _$Promotion {
  const factory Promotion({
    @JsonKey(name: 'promotion_id', includeIfNull: false) String? promotionId,
    @JsonKey(name: 'stay_id') required int stayId,
    required String description,
    @JsonKey(name: 'discount_percentage') required double discountPercentage,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String state,
  }) = _Promotion;

  factory Promotion.fromJson(Map<String, dynamic> json) => _$PromotionFromJson(json);
}