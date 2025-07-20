// lib/data/models/stay_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stay_model.freezed.dart';
part 'stay_model.g.dart';

@freezed
class Stay with _$Stay {
  const factory Stay({
    @JsonKey(name: 'stay_id', includeIfNull: false) int? stayId,
    required String name,
    required String category,
    String? description,
    required String status,
    @JsonKey(name: 'main_image_url') String? mainImageUrl,
    @JsonKey(name: 'owner_id') String? ownerId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // El tipo Map<String, dynamic> para el campo de location (PostGIS/GeoJSON) es correcto.
    Map<String, dynamic>? location,
  }) = _Stay;

  factory Stay.fromJson(Map<String, dynamic> json) => _$StayFromJson(json);
}