// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  @JsonKey(name: 'auth_user_id')
  String get authUserId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  String get userType => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_language')
  String? get preferredLanguage => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_theme')
  Map<String, dynamic>? get preferredTheme =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image_url')
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'auth_user_id') String authUserId,
      String username,
      @JsonKey(name: 'user_type') String userType,
      @JsonKey(name: 'preferred_language') String? preferredLanguage,
      @JsonKey(name: 'preferred_theme') Map<String, dynamic>? preferredTheme,
      @JsonKey(name: 'profile_image_url') String? profileImageUrl,
      String email,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authUserId = null,
    Object? username = null,
    Object? userType = null,
    Object? preferredLanguage = freezed,
    Object? preferredTheme = freezed,
    Object? profileImageUrl = freezed,
    Object? email = null,
    Object? phoneNumber = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      authUserId: null == authUserId
          ? _value.authUserId
          : authUserId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as String,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredTheme: freezed == preferredTheme
          ? _value.preferredTheme
          : preferredTheme // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'auth_user_id') String authUserId,
      String username,
      @JsonKey(name: 'user_type') String userType,
      @JsonKey(name: 'preferred_language') String? preferredLanguage,
      @JsonKey(name: 'preferred_theme') Map<String, dynamic>? preferredTheme,
      @JsonKey(name: 'profile_image_url') String? profileImageUrl,
      String email,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authUserId = null,
    Object? username = null,
    Object? userType = null,
    Object? preferredLanguage = freezed,
    Object? preferredTheme = freezed,
    Object? profileImageUrl = freezed,
    Object? email = null,
    Object? phoneNumber = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$UserModelImpl(
      authUserId: null == authUserId
          ? _value.authUserId
          : authUserId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as String,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredTheme: freezed == preferredTheme
          ? _value._preferredTheme
          : preferredTheme // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {@JsonKey(name: 'auth_user_id') required this.authUserId,
      required this.username,
      @JsonKey(name: 'user_type') required this.userType,
      @JsonKey(name: 'preferred_language') this.preferredLanguage,
      @JsonKey(name: 'preferred_theme')
      final Map<String, dynamic>? preferredTheme,
      @JsonKey(name: 'profile_image_url') this.profileImageUrl,
      required this.email,
      @JsonKey(name: 'phone_number') this.phoneNumber,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _preferredTheme = preferredTheme;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey(name: 'auth_user_id')
  final String authUserId;
  @override
  final String username;
  @override
  @JsonKey(name: 'user_type')
  final String userType;
  @override
  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage;
  final Map<String, dynamic>? _preferredTheme;
  @override
  @JsonKey(name: 'preferred_theme')
  Map<String, dynamic>? get preferredTheme {
    final value = _preferredTheme;
    if (value == null) return null;
    if (_preferredTheme is EqualUnmodifiableMapView) return _preferredTheme;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  @override
  final String email;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'UserModel(authUserId: $authUserId, username: $username, userType: $userType, preferredLanguage: $preferredLanguage, preferredTheme: $preferredTheme, profileImageUrl: $profileImageUrl, email: $email, phoneNumber: $phoneNumber, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.authUserId, authUserId) ||
                other.authUserId == authUserId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            const DeepCollectionEquality()
                .equals(other._preferredTheme, _preferredTheme) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      authUserId,
      username,
      userType,
      preferredLanguage,
      const DeepCollectionEquality().hash(_preferredTheme),
      profileImageUrl,
      email,
      phoneNumber,
      createdAt);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
          {@JsonKey(name: 'auth_user_id') required final String authUserId,
          required final String username,
          @JsonKey(name: 'user_type') required final String userType,
          @JsonKey(name: 'preferred_language') final String? preferredLanguage,
          @JsonKey(name: 'preferred_theme')
          final Map<String, dynamic>? preferredTheme,
          @JsonKey(name: 'profile_image_url') final String? profileImageUrl,
          required final String email,
          @JsonKey(name: 'phone_number') final String? phoneNumber,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @JsonKey(name: 'auth_user_id')
  String get authUserId;
  @override
  String get username;
  @override
  @JsonKey(name: 'user_type')
  String get userType;
  @override
  @JsonKey(name: 'preferred_language')
  String? get preferredLanguage;
  @override
  @JsonKey(name: 'preferred_theme')
  Map<String, dynamic>? get preferredTheme;
  @override
  @JsonKey(name: 'profile_image_url')
  String? get profileImageUrl;
  @override
  String get email;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
