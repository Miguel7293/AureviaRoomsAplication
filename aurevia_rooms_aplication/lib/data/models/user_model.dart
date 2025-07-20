// lib/data/models/user_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: 'auth_user_id') required String authUserId,
    required String username,
    @JsonKey(name: 'user_type') required String userType,
    @JsonKey(name: 'preferred_language') String? preferredLanguage,
    @JsonKey(name: 'preferred_theme') Map<String, dynamic>? preferredTheme,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    required String email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}