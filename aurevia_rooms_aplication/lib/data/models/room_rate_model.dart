// lib/data/models/room_rate_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_rate_model.freezed.dart';
part 'room_rate_model.g.dart';

@freezed
class RoomRate with _$RoomRate {
  const factory RoomRate({
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'room_id') required int roomId,
    @JsonKey(name: 'rate_type') required String rateType,
    required double price,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'promotion_id') String? promotionId,
  }) = _RoomRate;

  factory RoomRate.fromJson(Map<String, dynamic> json) => _$RoomRateFromJson(json);
}