// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      authUserId: json['auth_user_id'] as String,
      username: json['username'] as String,
      userType: json['user_type'] as String,
      preferredLanguage: json['preferred_language'] as String?,
      preferredTheme: json['preferred_theme'] as Map<String, dynamic>?,
      profileImageUrl: json['profile_image_url'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'auth_user_id': instance.authUserId,
      'username': instance.username,
      'user_type': instance.userType,
      'preferred_language': instance.preferredLanguage,
      'preferred_theme': instance.preferredTheme,
      'profile_image_url': instance.profileImageUrl,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'created_at': instance.createdAt.toIso8601String(),
    };
