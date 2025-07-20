// lib/data/models/review_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    // AÑADE includeIfNull: false A LA ANOTACIÓN
    @JsonKey(name: 'review_id', includeIfNull: false) int? reviewId,
    
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'stay_id') required int stayId,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}