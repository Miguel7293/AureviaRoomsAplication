// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stay_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Stay _$StayFromJson(Map<String, dynamic> json) {
  return _Stay.fromJson(json);
}

/// @nodoc
mixin _$Stay {
  @JsonKey(name: 'stay_id', includeIfNull: false)
  int? get stayId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'main_image_url')
  String? get mainImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String? get ownerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // El tipo Map<String, dynamic> para el campo de location (PostGIS/GeoJSON) es correcto.
  Map<String, dynamic>? get location => throw _privateConstructorUsedError;

  /// Serializes this Stay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StayCopyWith<Stay> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StayCopyWith<$Res> {
  factory $StayCopyWith(Stay value, $Res Function(Stay) then) =
      _$StayCopyWithImpl<$Res, Stay>;
  @useResult
  $Res call(
      {@JsonKey(name: 'stay_id', includeIfNull: false) int? stayId,
      String name,
      String category,
      String? description,
      String status,
      @JsonKey(name: 'main_image_url') String? mainImageUrl,
      @JsonKey(name: 'owner_id') String? ownerId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Map<String, dynamic>? location});
}

/// @nodoc
class _$StayCopyWithImpl<$Res, $Val extends Stay>
    implements $StayCopyWith<$Res> {
  _$StayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stayId = freezed,
    Object? name = null,
    Object? category = null,
    Object? description = freezed,
    Object? status = null,
    Object? mainImageUrl = freezed,
    Object? ownerId = freezed,
    Object? createdAt = null,
    Object? location = freezed,
  }) {
    return _then(_value.copyWith(
      stayId: freezed == stayId
          ? _value.stayId
          : stayId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      mainImageUrl: freezed == mainImageUrl
          ? _value.mainImageUrl
          : mainImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StayImplCopyWith<$Res> implements $StayCopyWith<$Res> {
  factory _$$StayImplCopyWith(
          _$StayImpl value, $Res Function(_$StayImpl) then) =
      __$$StayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'stay_id', includeIfNull: false) int? stayId,
      String name,
      String category,
      String? description,
      String status,
      @JsonKey(name: 'main_image_url') String? mainImageUrl,
      @JsonKey(name: 'owner_id') String? ownerId,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Map<String, dynamic>? location});
}

/// @nodoc
class __$$StayImplCopyWithImpl<$Res>
    extends _$StayCopyWithImpl<$Res, _$StayImpl>
    implements _$$StayImplCopyWith<$Res> {
  __$$StayImplCopyWithImpl(_$StayImpl _value, $Res Function(_$StayImpl) _then)
      : super(_value, _then);

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stayId = freezed,
    Object? name = null,
    Object? category = null,
    Object? description = freezed,
    Object? status = null,
    Object? mainImageUrl = freezed,
    Object? ownerId = freezed,
    Object? createdAt = null,
    Object? location = freezed,
  }) {
    return _then(_$StayImpl(
      stayId: freezed == stayId
          ? _value.stayId
          : stayId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      mainImageUrl: freezed == mainImageUrl
          ? _value.mainImageUrl
          : mainImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StayImpl implements _Stay {
  const _$StayImpl(
      {@JsonKey(name: 'stay_id', includeIfNull: false) this.stayId,
      required this.name,
      required this.category,
      this.description,
      required this.status,
      @JsonKey(name: 'main_image_url') this.mainImageUrl,
      @JsonKey(name: 'owner_id') this.ownerId,
      @JsonKey(name: 'created_at') required this.createdAt,
      final Map<String, dynamic>? location})
      : _location = location;

  factory _$StayImpl.fromJson(Map<String, dynamic> json) =>
      _$$StayImplFromJson(json);

  @override
  @JsonKey(name: 'stay_id', includeIfNull: false)
  final int? stayId;
  @override
  final String name;
  @override
  final String category;
  @override
  final String? description;
  @override
  final String status;
  @override
  @JsonKey(name: 'main_image_url')
  final String? mainImageUrl;
  @override
  @JsonKey(name: 'owner_id')
  final String? ownerId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// El tipo Map<String, dynamic> para el campo de location (PostGIS/GeoJSON) es correcto.
  final Map<String, dynamic>? _location;
// El tipo Map<String, dynamic> para el campo de location (PostGIS/GeoJSON) es correcto.
  @override
  Map<String, dynamic>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableMapView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Stay(stayId: $stayId, name: $name, category: $category, description: $description, status: $status, mainImageUrl: $mainImageUrl, ownerId: $ownerId, createdAt: $createdAt, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StayImpl &&
            (identical(other.stayId, stayId) || other.stayId == stayId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mainImageUrl, mainImageUrl) ||
                other.mainImageUrl == mainImageUrl) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._location, _location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stayId,
      name,
      category,
      description,
      status,
      mainImageUrl,
      ownerId,
      createdAt,
      const DeepCollectionEquality().hash(_location));

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StayImplCopyWith<_$StayImpl> get copyWith =>
      __$$StayImplCopyWithImpl<_$StayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StayImplToJson(
      this,
    );
  }
}

abstract class _Stay implements Stay {
  const factory _Stay(
      {@JsonKey(name: 'stay_id', includeIfNull: false) final int? stayId,
      required final String name,
      required final String category,
      final String? description,
      required final String status,
      @JsonKey(name: 'main_image_url') final String? mainImageUrl,
      @JsonKey(name: 'owner_id') final String? ownerId,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final Map<String, dynamic>? location}) = _$StayImpl;

  factory _Stay.fromJson(Map<String, dynamic> json) = _$StayImpl.fromJson;

  @override
  @JsonKey(name: 'stay_id', includeIfNull: false)
  int? get stayId;
  @override
  String get name;
  @override
  String get category;
  @override
  String? get description;
  @override
  String get status;
  @override
  @JsonKey(name: 'main_image_url')
  String? get mainImageUrl;
  @override
  @JsonKey(name: 'owner_id')
  String? get ownerId;
  @override
  @JsonKey(name: 'created_at')
  DateTime
      get createdAt; // El tipo Map<String, dynamic> para el campo de location (PostGIS/GeoJSON) es correcto.
  @override
  Map<String, dynamic>? get location;

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StayImplCopyWith<_$StayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
