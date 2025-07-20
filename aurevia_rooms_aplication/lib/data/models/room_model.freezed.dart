// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  @JsonKey(name: 'room_id', includeIfNull: false)
  int? get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'stay_id')
  int get stayId => throw _privateConstructorUsedError;
  @JsonKey(name: 'availability_status')
  String get availabilityStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_image_url')
  String? get roomImageUrl =>
      throw _privateConstructorUsedError; // El tipo Map<String, dynamic> es correcto para un campo JSONB
  Map<String, dynamic>? get features => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call(
      {@JsonKey(name: 'room_id', includeIfNull: false) int? roomId,
      @JsonKey(name: 'stay_id') int stayId,
      @JsonKey(name: 'availability_status') String availabilityStatus,
      @JsonKey(name: 'room_image_url') String? roomImageUrl,
      Map<String, dynamic>? features,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = freezed,
    Object? stayId = null,
    Object? availabilityStatus = null,
    Object? roomImageUrl = freezed,
    Object? features = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int?,
      stayId: null == stayId
          ? _value.stayId
          : stayId // ignore: cast_nullable_to_non_nullable
              as int,
      availabilityStatus: null == availabilityStatus
          ? _value.availabilityStatus
          : availabilityStatus // ignore: cast_nullable_to_non_nullable
              as String,
      roomImageUrl: freezed == roomImageUrl
          ? _value.roomImageUrl
          : roomImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      features: freezed == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
          _$RoomImpl value, $Res Function(_$RoomImpl) then) =
      __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'room_id', includeIfNull: false) int? roomId,
      @JsonKey(name: 'stay_id') int stayId,
      @JsonKey(name: 'availability_status') String availabilityStatus,
      @JsonKey(name: 'room_image_url') String? roomImageUrl,
      Map<String, dynamic>? features,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = freezed,
    Object? stayId = null,
    Object? availabilityStatus = null,
    Object? roomImageUrl = freezed,
    Object? features = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$RoomImpl(
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int?,
      stayId: null == stayId
          ? _value.stayId
          : stayId // ignore: cast_nullable_to_non_nullable
              as int,
      availabilityStatus: null == availabilityStatus
          ? _value.availabilityStatus
          : availabilityStatus // ignore: cast_nullable_to_non_nullable
              as String,
      roomImageUrl: freezed == roomImageUrl
          ? _value.roomImageUrl
          : roomImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      features: freezed == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl(
      {@JsonKey(name: 'room_id', includeIfNull: false) this.roomId,
      @JsonKey(name: 'stay_id') required this.stayId,
      @JsonKey(name: 'availability_status') required this.availabilityStatus,
      @JsonKey(name: 'room_image_url') this.roomImageUrl,
      final Map<String, dynamic>? features,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _features = features;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  @JsonKey(name: 'room_id', includeIfNull: false)
  final int? roomId;
  @override
  @JsonKey(name: 'stay_id')
  final int stayId;
  @override
  @JsonKey(name: 'availability_status')
  final String availabilityStatus;
  @override
  @JsonKey(name: 'room_image_url')
  final String? roomImageUrl;
// El tipo Map<String, dynamic> es correcto para un campo JSONB
  final Map<String, dynamic>? _features;
// El tipo Map<String, dynamic> es correcto para un campo JSONB
  @override
  Map<String, dynamic>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableMapView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Room(roomId: $roomId, stayId: $stayId, availabilityStatus: $availabilityStatus, roomImageUrl: $roomImageUrl, features: $features, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.stayId, stayId) || other.stayId == stayId) &&
            (identical(other.availabilityStatus, availabilityStatus) ||
                other.availabilityStatus == availabilityStatus) &&
            (identical(other.roomImageUrl, roomImageUrl) ||
                other.roomImageUrl == roomImageUrl) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      roomId,
      stayId,
      availabilityStatus,
      roomImageUrl,
      const DeepCollectionEquality().hash(_features),
      createdAt);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(
      this,
    );
  }
}

abstract class _Room implements Room {
  const factory _Room(
          {@JsonKey(name: 'room_id', includeIfNull: false) final int? roomId,
          @JsonKey(name: 'stay_id') required final int stayId,
          @JsonKey(name: 'availability_status')
          required final String availabilityStatus,
          @JsonKey(name: 'room_image_url') final String? roomImageUrl,
          final Map<String, dynamic>? features,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  @JsonKey(name: 'room_id', includeIfNull: false)
  int? get roomId;
  @override
  @JsonKey(name: 'stay_id')
  int get stayId;
  @override
  @JsonKey(name: 'availability_status')
  String get availabilityStatus;
  @override
  @JsonKey(name: 'room_image_url')
  String?
      get roomImageUrl; // El tipo Map<String, dynamic> es correcto para un campo JSONB
  @override
  Map<String, dynamic>? get features;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
