// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_rate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoomRate _$RoomRateFromJson(Map<String, dynamic> json) {
  return _RoomRate.fromJson(json);
}

/// @nodoc
mixin _$RoomRate {
  @JsonKey(includeIfNull: false)
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_id')
  int get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'rate_type')
  String get rateType => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'promotion_id')
  String? get promotionId => throw _privateConstructorUsedError;

  /// Serializes this RoomRate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomRateCopyWith<RoomRate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomRateCopyWith<$Res> {
  factory $RoomRateCopyWith(RoomRate value, $Res Function(RoomRate) then) =
      _$RoomRateCopyWithImpl<$Res, RoomRate>;
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) int? id,
      @JsonKey(name: 'room_id') int roomId,
      @JsonKey(name: 'rate_type') String rateType,
      double price,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'promotion_id') String? promotionId});
}

/// @nodoc
class _$RoomRateCopyWithImpl<$Res, $Val extends RoomRate>
    implements $RoomRateCopyWith<$Res> {
  _$RoomRateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? roomId = null,
    Object? rateType = null,
    Object? price = null,
    Object? createdAt = null,
    Object? promotionId = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      rateType: null == rateType
          ? _value.rateType
          : rateType // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      promotionId: freezed == promotionId
          ? _value.promotionId
          : promotionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomRateImplCopyWith<$Res>
    implements $RoomRateCopyWith<$Res> {
  factory _$$RoomRateImplCopyWith(
          _$RoomRateImpl value, $Res Function(_$RoomRateImpl) then) =
      __$$RoomRateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) int? id,
      @JsonKey(name: 'room_id') int roomId,
      @JsonKey(name: 'rate_type') String rateType,
      double price,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'promotion_id') String? promotionId});
}

/// @nodoc
class __$$RoomRateImplCopyWithImpl<$Res>
    extends _$RoomRateCopyWithImpl<$Res, _$RoomRateImpl>
    implements _$$RoomRateImplCopyWith<$Res> {
  __$$RoomRateImplCopyWithImpl(
      _$RoomRateImpl _value, $Res Function(_$RoomRateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoomRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? roomId = null,
    Object? rateType = null,
    Object? price = null,
    Object? createdAt = null,
    Object? promotionId = freezed,
  }) {
    return _then(_$RoomRateImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      rateType: null == rateType
          ? _value.rateType
          : rateType // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      promotionId: freezed == promotionId
          ? _value.promotionId
          : promotionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomRateImpl implements _RoomRate {
  const _$RoomRateImpl(
      {@JsonKey(includeIfNull: false) this.id,
      @JsonKey(name: 'room_id') required this.roomId,
      @JsonKey(name: 'rate_type') required this.rateType,
      required this.price,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'promotion_id') this.promotionId});

  factory _$RoomRateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomRateImplFromJson(json);

  @override
  @JsonKey(includeIfNull: false)
  final int? id;
  @override
  @JsonKey(name: 'room_id')
  final int roomId;
  @override
  @JsonKey(name: 'rate_type')
  final String rateType;
  @override
  final double price;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'promotion_id')
  final String? promotionId;

  @override
  String toString() {
    return 'RoomRate(id: $id, roomId: $roomId, rateType: $rateType, price: $price, createdAt: $createdAt, promotionId: $promotionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomRateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.rateType, rateType) ||
                other.rateType == rateType) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.promotionId, promotionId) ||
                other.promotionId == promotionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, roomId, rateType, price, createdAt, promotionId);

  /// Create a copy of RoomRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomRateImplCopyWith<_$RoomRateImpl> get copyWith =>
      __$$RoomRateImplCopyWithImpl<_$RoomRateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomRateImplToJson(
      this,
    );
  }
}

abstract class _RoomRate implements RoomRate {
  const factory _RoomRate(
          {@JsonKey(includeIfNull: false) final int? id,
          @JsonKey(name: 'room_id') required final int roomId,
          @JsonKey(name: 'rate_type') required final String rateType,
          required final double price,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'promotion_id') final String? promotionId}) =
      _$RoomRateImpl;

  factory _RoomRate.fromJson(Map<String, dynamic> json) =
      _$RoomRateImpl.fromJson;

  @override
  @JsonKey(includeIfNull: false)
  int? get id;
  @override
  @JsonKey(name: 'room_id')
  int get roomId;
  @override
  @JsonKey(name: 'rate_type')
  String get rateType;
  @override
  double get price;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'promotion_id')
  String? get promotionId;

  /// Create a copy of RoomRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomRateImplCopyWith<_$RoomRateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
