// lib/data/models/room_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    @JsonKey(name: 'room_id', includeIfNull: false) int? roomId,
    @JsonKey(name: 'stay_id') required int stayId,
    @JsonKey(name: 'availability_status') required String availabilityStatus,
    @JsonKey(name: 'room_image_url') String? roomImageUrl,
    // El tipo Map<String, dynamic> es correcto para un campo JSONB
    Map<String, dynamic>? features,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}