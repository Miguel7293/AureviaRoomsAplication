// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return _Booking.fromJson(json);
}

/// @nodoc
mixin _$Booking {
  @JsonKey(name: 'booking_id', includeIfNull: false)
  int? get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_id')
  int get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'check_in_date')
  DateTime get checkInDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'check_out_date')
  DateTime get checkOutDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_status')
  String get bookingStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_price')
  double get totalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingCopyWith<Booking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res, Booking>;
  @useResult
  $Res call(
      {@JsonKey(name: 'booking_id', includeIfNull: false) int? bookingId,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'room_id') int roomId,
      @JsonKey(name: 'check_in_date') DateTime checkInDate,
      @JsonKey(name: 'check_out_date') DateTime checkOutDate,
      @JsonKey(name: 'booking_status') String bookingStatus,
      @JsonKey(name: 'total_price') double totalPrice,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = freezed,
    Object? userId = null,
    Object? roomId = null,
    Object? checkInDate = null,
    Object? checkOutDate = null,
    Object? bookingStatus = null,
    Object? totalPrice = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      checkInDate: null == checkInDate
          ? _value.checkInDate
          : checkInDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkOutDate: null == checkOutDate
          ? _value.checkOutDate
          : checkOutDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingImplCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$$BookingImplCopyWith(
          _$BookingImpl value, $Res Function(_$BookingImpl) then) =
      __$$BookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'booking_id', includeIfNull: false) int? bookingId,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'room_id') int roomId,
      @JsonKey(name: 'check_in_date') DateTime checkInDate,
      @JsonKey(name: 'check_out_date') DateTime checkOutDate,
      @JsonKey(name: 'booking_status') String bookingStatus,
      @JsonKey(name: 'total_price') double totalPrice,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$BookingImplCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingImpl>
    implements _$$BookingImplCopyWith<$Res> {
  __$$BookingImplCopyWithImpl(
      _$BookingImpl _value, $Res Function(_$BookingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = freezed,
    Object? userId = null,
    Object? roomId = null,
    Object? checkInDate = null,
    Object? checkOutDate = null,
    Object? bookingStatus = null,
    Object? totalPrice = null,
    Object? createdAt = null,
  }) {
    return _then(_$BookingImpl(
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as int,
      checkInDate: null == checkInDate
          ? _value.checkInDate
          : checkInDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      checkOutDate: null == checkOutDate
          ? _value.checkOutDate
          : checkOutDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingImpl implements _Booking {
  const _$BookingImpl(
      {@JsonKey(name: 'booking_id', includeIfNull: false) this.bookingId,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'room_id') required this.roomId,
      @JsonKey(name: 'check_in_date') required this.checkInDate,
      @JsonKey(name: 'check_out_date') required this.checkOutDate,
      @JsonKey(name: 'booking_status') required this.bookingStatus,
      @JsonKey(name: 'total_price') required this.totalPrice,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$BookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingImplFromJson(json);

  @override
  @JsonKey(name: 'booking_id', includeIfNull: false)
  final int? bookingId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'room_id')
  final int roomId;
  @override
  @JsonKey(name: 'check_in_date')
  final DateTime checkInDate;
  @override
  @JsonKey(name: 'check_out_date')
  final DateTime checkOutDate;
  @override
  @JsonKey(name: 'booking_status')
  final String bookingStatus;
  @override
  @JsonKey(name: 'total_price')
  final double totalPrice;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Booking(bookingId: $bookingId, userId: $userId, roomId: $roomId, checkInDate: $checkInDate, checkOutDate: $checkOutDate, bookingStatus: $bookingStatus, totalPrice: $totalPrice, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.checkInDate, checkInDate) ||
                other.checkInDate == checkInDate) &&
            (identical(other.checkOutDate, checkOutDate) ||
                other.checkOutDate == checkOutDate) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bookingId, userId, roomId,
      checkInDate, checkOutDate, bookingStatus, totalPrice, createdAt);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      __$$BookingImplCopyWithImpl<_$BookingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingImplToJson(
      this,
    );
  }
}

abstract class _Booking implements Booking {
  const factory _Booking(
      {@JsonKey(name: 'booking_id', includeIfNull: false) final int? bookingId,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'room_id') required final int roomId,
      @JsonKey(name: 'check_in_date') required final DateTime checkInDate,
      @JsonKey(name: 'check_out_date') required final DateTime checkOutDate,
      @JsonKey(name: 'booking_status') required final String bookingStatus,
      @JsonKey(name: 'total_price') required final double totalPrice,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$BookingImpl;

  factory _Booking.fromJson(Map<String, dynamic> json) = _$BookingImpl.fromJson;

  @override
  @JsonKey(name: 'booking_id', includeIfNull: false)
  int? get bookingId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'room_id')
  int get roomId;
  @override
  @JsonKey(name: 'check_in_date')
  DateTime get checkInDate;
  @override
  @JsonKey(name: 'check_out_date')
  DateTime get checkOutDate;
  @override
  @JsonKey(name: 'booking_status')
  String get bookingStatus;
  @override
  @JsonKey(name: 'total_price')
  double get totalPrice;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
