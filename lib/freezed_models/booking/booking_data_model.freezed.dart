// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CreateRazorpayRequestModel _$CreateRazorpayRequestModelFromJson(
    Map<String, dynamic> json) {
  return _CreateRazorpayRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CreateRazorpayRequestModel {
  @JsonKey(name: 'fare_token')
  String get fareToken => throw _privateConstructorUsedError;
  List<Traveler> get travelers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateRazorpayRequestModelCopyWith<CreateRazorpayRequestModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateRazorpayRequestModelCopyWith<$Res> {
  factory $CreateRazorpayRequestModelCopyWith(CreateRazorpayRequestModel value,
          $Res Function(CreateRazorpayRequestModel) then) =
      _$CreateRazorpayRequestModelCopyWithImpl<$Res,
          CreateRazorpayRequestModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'fare_token') String fareToken,
      List<Traveler> travelers});
}

/// @nodoc
class _$CreateRazorpayRequestModelCopyWithImpl<$Res,
        $Val extends CreateRazorpayRequestModel>
    implements $CreateRazorpayRequestModelCopyWith<$Res> {
  _$CreateRazorpayRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fareToken = null,
    Object? travelers = null,
  }) {
    return _then(_value.copyWith(
      fareToken: null == fareToken
          ? _value.fareToken
          : fareToken // ignore: cast_nullable_to_non_nullable
              as String,
      travelers: null == travelers
          ? _value.travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<Traveler>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateRazorpayRequestModelImplCopyWith<$Res>
    implements $CreateRazorpayRequestModelCopyWith<$Res> {
  factory _$$CreateRazorpayRequestModelImplCopyWith(
          _$CreateRazorpayRequestModelImpl value,
          $Res Function(_$CreateRazorpayRequestModelImpl) then) =
      __$$CreateRazorpayRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'fare_token') String fareToken,
      List<Traveler> travelers});
}

/// @nodoc
class __$$CreateRazorpayRequestModelImplCopyWithImpl<$Res>
    extends _$CreateRazorpayRequestModelCopyWithImpl<$Res,
        _$CreateRazorpayRequestModelImpl>
    implements _$$CreateRazorpayRequestModelImplCopyWith<$Res> {
  __$$CreateRazorpayRequestModelImplCopyWithImpl(
      _$CreateRazorpayRequestModelImpl _value,
      $Res Function(_$CreateRazorpayRequestModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fareToken = null,
    Object? travelers = null,
  }) {
    return _then(_$CreateRazorpayRequestModelImpl(
      fareToken: null == fareToken
          ? _value.fareToken
          : fareToken // ignore: cast_nullable_to_non_nullable
              as String,
      travelers: null == travelers
          ? _value._travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<Traveler>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateRazorpayRequestModelImpl implements _CreateRazorpayRequestModel {
  const _$CreateRazorpayRequestModelImpl(
      {@JsonKey(name: 'fare_token') required this.fareToken,
      required final List<Traveler> travelers})
      : _travelers = travelers;

  factory _$CreateRazorpayRequestModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreateRazorpayRequestModelImplFromJson(json);

  @override
  @JsonKey(name: 'fare_token')
  final String fareToken;
  final List<Traveler> _travelers;
  @override
  List<Traveler> get travelers {
    if (_travelers is EqualUnmodifiableListView) return _travelers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_travelers);
  }

  @override
  String toString() {
    return 'CreateRazorpayRequestModel(fareToken: $fareToken, travelers: $travelers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateRazorpayRequestModelImpl &&
            (identical(other.fareToken, fareToken) ||
                other.fareToken == fareToken) &&
            const DeepCollectionEquality()
                .equals(other._travelers, _travelers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, fareToken, const DeepCollectionEquality().hash(_travelers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateRazorpayRequestModelImplCopyWith<_$CreateRazorpayRequestModelImpl>
      get copyWith => __$$CreateRazorpayRequestModelImplCopyWithImpl<
          _$CreateRazorpayRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateRazorpayRequestModelImplToJson(
      this,
    );
  }
}

abstract class _CreateRazorpayRequestModel
    implements CreateRazorpayRequestModel {
  const factory _CreateRazorpayRequestModel(
          {@JsonKey(name: 'fare_token') required final String fareToken,
          required final List<Traveler> travelers}) =
      _$CreateRazorpayRequestModelImpl;

  factory _CreateRazorpayRequestModel.fromJson(Map<String, dynamic> json) =
      _$CreateRazorpayRequestModelImpl.fromJson;

  @override
  @JsonKey(name: 'fare_token')
  String get fareToken;
  @override
  List<Traveler> get travelers;
  @override
  @JsonKey(ignore: true)
  _$$CreateRazorpayRequestModelImplCopyWith<_$CreateRazorpayRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BookingResponse _$BookingResponseFromJson(Map<String, dynamic> json) {
  return _BookingResponse.fromJson(json);
}

/// @nodoc
mixin _$BookingResponse {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  Order? get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'key_id')
  String? get keyId => throw _privateConstructorUsedError;
  BookingData? get bookingData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingResponseCopyWith<BookingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingResponseCopyWith<$Res> {
  factory $BookingResponseCopyWith(
          BookingResponse value, $Res Function(BookingResponse) then) =
      _$BookingResponseCopyWithImpl<$Res, BookingResponse>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      Order? order,
      @JsonKey(name: 'key_id') String? keyId,
      BookingData? bookingData});

  $OrderCopyWith<$Res>? get order;
  $BookingDataCopyWith<$Res>? get bookingData;
}

/// @nodoc
class _$BookingResponseCopyWithImpl<$Res, $Val extends BookingResponse>
    implements $BookingResponseCopyWith<$Res> {
  _$BookingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? order = freezed,
    Object? keyId = freezed,
    Object? bookingData = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingData: freezed == bookingData
          ? _value.bookingData
          : bookingData // ignore: cast_nullable_to_non_nullable
              as BookingData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res>? get order {
    if (_value.order == null) {
      return null;
    }

    return $OrderCopyWith<$Res>(_value.order!, (value) {
      return _then(_value.copyWith(order: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BookingDataCopyWith<$Res>? get bookingData {
    if (_value.bookingData == null) {
      return null;
    }

    return $BookingDataCopyWith<$Res>(_value.bookingData!, (value) {
      return _then(_value.copyWith(bookingData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingResponseImplCopyWith<$Res>
    implements $BookingResponseCopyWith<$Res> {
  factory _$$BookingResponseImplCopyWith(_$BookingResponseImpl value,
          $Res Function(_$BookingResponseImpl) then) =
      __$$BookingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      Order? order,
      @JsonKey(name: 'key_id') String? keyId,
      BookingData? bookingData});

  @override
  $OrderCopyWith<$Res>? get order;
  @override
  $BookingDataCopyWith<$Res>? get bookingData;
}

/// @nodoc
class __$$BookingResponseImplCopyWithImpl<$Res>
    extends _$BookingResponseCopyWithImpl<$Res, _$BookingResponseImpl>
    implements _$$BookingResponseImplCopyWith<$Res> {
  __$$BookingResponseImplCopyWithImpl(
      _$BookingResponseImpl _value, $Res Function(_$BookingResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? order = freezed,
    Object? keyId = freezed,
    Object? bookingData = freezed,
  }) {
    return _then(_$BookingResponseImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order?,
      keyId: freezed == keyId
          ? _value.keyId
          : keyId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingData: freezed == bookingData
          ? _value.bookingData
          : bookingData // ignore: cast_nullable_to_non_nullable
              as BookingData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingResponseImpl implements _BookingResponse {
  const _$BookingResponseImpl(
      {this.success,
      this.message,
      this.order,
      @JsonKey(name: 'key_id') this.keyId,
      this.bookingData});

  factory _$BookingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingResponseImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final Order? order;
  @override
  @JsonKey(name: 'key_id')
  final String? keyId;
  @override
  final BookingData? bookingData;

  @override
  String toString() {
    return 'BookingResponse(success: $success, message: $message, order: $order, keyId: $keyId, bookingData: $bookingData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.keyId, keyId) || other.keyId == keyId) &&
            (identical(other.bookingData, bookingData) ||
                other.bookingData == bookingData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, message, order, keyId, bookingData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingResponseImplCopyWith<_$BookingResponseImpl> get copyWith =>
      __$$BookingResponseImplCopyWithImpl<_$BookingResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingResponseImplToJson(
      this,
    );
  }
}

abstract class _BookingResponse implements BookingResponse {
  const factory _BookingResponse(
      {final bool? success,
      final String? message,
      final Order? order,
      @JsonKey(name: 'key_id') final String? keyId,
      final BookingData? bookingData}) = _$BookingResponseImpl;

  factory _BookingResponse.fromJson(Map<String, dynamic> json) =
      _$BookingResponseImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  Order? get order;
  @override
  @JsonKey(name: 'key_id')
  String? get keyId;
  @override
  BookingData? get bookingData;
  @override
  @JsonKey(ignore: true)
  _$$BookingResponseImplCopyWith<_$BookingResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  dynamic get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_due')
  dynamic get amountDue => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paid')
  dynamic get amountPaid => throw _privateConstructorUsedError;
  int? get attempts => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  dynamic get createdAt => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  String? get entity => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  List<dynamic>? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'offer_id')
  String? get offerId => throw _privateConstructorUsedError;
  String? get receipt => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call(
      {dynamic amount,
      @JsonKey(name: 'amount_due') dynamic amountDue,
      @JsonKey(name: 'amount_paid') dynamic amountPaid,
      int? attempts,
      @JsonKey(name: 'created_at') dynamic createdAt,
      String? currency,
      String? entity,
      String? id,
      List<dynamic>? notes,
      @JsonKey(name: 'offer_id') String? offerId,
      String? receipt,
      String? status});
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = freezed,
    Object? amountDue = freezed,
    Object? amountPaid = freezed,
    Object? attempts = freezed,
    Object? createdAt = freezed,
    Object? currency = freezed,
    Object? entity = freezed,
    Object? id = freezed,
    Object? notes = freezed,
    Object? offerId = freezed,
    Object? receipt = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountDue: freezed == amountDue
          ? _value.amountDue
          : amountDue // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountPaid: freezed == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as dynamic,
      attempts: freezed == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      entity: freezed == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      offerId: freezed == offerId
          ? _value.offerId
          : offerId // ignore: cast_nullable_to_non_nullable
              as String?,
      receipt: freezed == receipt
          ? _value.receipt
          : receipt // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
          _$OrderImpl value, $Res Function(_$OrderImpl) then) =
      __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic amount,
      @JsonKey(name: 'amount_due') dynamic amountDue,
      @JsonKey(name: 'amount_paid') dynamic amountPaid,
      int? attempts,
      @JsonKey(name: 'created_at') dynamic createdAt,
      String? currency,
      String? entity,
      String? id,
      List<dynamic>? notes,
      @JsonKey(name: 'offer_id') String? offerId,
      String? receipt,
      String? status});
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
      _$OrderImpl _value, $Res Function(_$OrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = freezed,
    Object? amountDue = freezed,
    Object? amountPaid = freezed,
    Object? attempts = freezed,
    Object? createdAt = freezed,
    Object? currency = freezed,
    Object? entity = freezed,
    Object? id = freezed,
    Object? notes = freezed,
    Object? offerId = freezed,
    Object? receipt = freezed,
    Object? status = freezed,
  }) {
    return _then(_$OrderImpl(
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountDue: freezed == amountDue
          ? _value.amountDue
          : amountDue // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountPaid: freezed == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as dynamic,
      attempts: freezed == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      entity: freezed == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      offerId: freezed == offerId
          ? _value.offerId
          : offerId // ignore: cast_nullable_to_non_nullable
              as String?,
      receipt: freezed == receipt
          ? _value.receipt
          : receipt // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl(
      {this.amount,
      @JsonKey(name: 'amount_due') this.amountDue,
      @JsonKey(name: 'amount_paid') this.amountPaid,
      this.attempts,
      @JsonKey(name: 'created_at') this.createdAt,
      this.currency,
      this.entity,
      this.id,
      final List<dynamic>? notes,
      @JsonKey(name: 'offer_id') this.offerId,
      this.receipt,
      this.status})
      : _notes = notes;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final dynamic amount;
  @override
  @JsonKey(name: 'amount_due')
  final dynamic amountDue;
  @override
  @JsonKey(name: 'amount_paid')
  final dynamic amountPaid;
  @override
  final int? attempts;
  @override
  @JsonKey(name: 'created_at')
  final dynamic createdAt;
  @override
  final String? currency;
  @override
  final String? entity;
  @override
  final String? id;
  final List<dynamic>? _notes;
  @override
  List<dynamic>? get notes {
    final value = _notes;
    if (value == null) return null;
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'offer_id')
  final String? offerId;
  @override
  final String? receipt;
  @override
  final String? status;

  @override
  String toString() {
    return 'Order(amount: $amount, amountDue: $amountDue, amountPaid: $amountPaid, attempts: $attempts, createdAt: $createdAt, currency: $currency, entity: $entity, id: $id, notes: $notes, offerId: $offerId, receipt: $receipt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            const DeepCollectionEquality().equals(other.amount, amount) &&
            const DeepCollectionEquality().equals(other.amountDue, amountDue) &&
            const DeepCollectionEquality()
                .equals(other.amountPaid, amountPaid) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.entity, entity) || other.entity == entity) &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._notes, _notes) &&
            (identical(other.offerId, offerId) || other.offerId == offerId) &&
            (identical(other.receipt, receipt) || other.receipt == receipt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(amount),
      const DeepCollectionEquality().hash(amountDue),
      const DeepCollectionEquality().hash(amountPaid),
      attempts,
      const DeepCollectionEquality().hash(createdAt),
      currency,
      entity,
      id,
      const DeepCollectionEquality().hash(_notes),
      offerId,
      receipt,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(
      this,
    );
  }
}

abstract class _Order implements Order {
  const factory _Order(
      {final dynamic amount,
      @JsonKey(name: 'amount_due') final dynamic amountDue,
      @JsonKey(name: 'amount_paid') final dynamic amountPaid,
      final int? attempts,
      @JsonKey(name: 'created_at') final dynamic createdAt,
      final String? currency,
      final String? entity,
      final String? id,
      final List<dynamic>? notes,
      @JsonKey(name: 'offer_id') final String? offerId,
      final String? receipt,
      final String? status}) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  dynamic get amount;
  @override
  @JsonKey(name: 'amount_due')
  dynamic get amountDue;
  @override
  @JsonKey(name: 'amount_paid')
  dynamic get amountPaid;
  @override
  int? get attempts;
  @override
  @JsonKey(name: 'created_at')
  dynamic get createdAt;
  @override
  String? get currency;
  @override
  String? get entity;
  @override
  String? get id;
  @override
  List<dynamic>? get notes;
  @override
  @JsonKey(name: 'offer_id')
  String? get offerId;
  @override
  String? get receipt;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingData _$BookingDataFromJson(Map<String, dynamic> json) {
  return _BookingData.fromJson(json);
}

/// @nodoc
mixin _$BookingData {
  int? get trekId => throw _privateConstructorUsedError;
  int? get customerId => throw _privateConstructorUsedError;
  List<Traveler>? get travelers => throw _privateConstructorUsedError;
  dynamic get totalAmount => throw _privateConstructorUsedError;
  dynamic get discountAmount => throw _privateConstructorUsedError;
  dynamic get finalAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingDataCopyWith<BookingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingDataCopyWith<$Res> {
  factory $BookingDataCopyWith(
          BookingData value, $Res Function(BookingData) then) =
      _$BookingDataCopyWithImpl<$Res, BookingData>;
  @useResult
  $Res call(
      {int? trekId,
      int? customerId,
      List<Traveler>? travelers,
      dynamic totalAmount,
      dynamic discountAmount,
      dynamic finalAmount});
}

/// @nodoc
class _$BookingDataCopyWithImpl<$Res, $Val extends BookingData>
    implements $BookingDataCopyWith<$Res> {
  _$BookingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trekId = freezed,
    Object? customerId = freezed,
    Object? travelers = freezed,
    Object? totalAmount = freezed,
    Object? discountAmount = freezed,
    Object? finalAmount = freezed,
  }) {
    return _then(_value.copyWith(
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      travelers: freezed == travelers
          ? _value.travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<Traveler>?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingDataImplCopyWith<$Res>
    implements $BookingDataCopyWith<$Res> {
  factory _$$BookingDataImplCopyWith(
          _$BookingDataImpl value, $Res Function(_$BookingDataImpl) then) =
      __$$BookingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? trekId,
      int? customerId,
      List<Traveler>? travelers,
      dynamic totalAmount,
      dynamic discountAmount,
      dynamic finalAmount});
}

/// @nodoc
class __$$BookingDataImplCopyWithImpl<$Res>
    extends _$BookingDataCopyWithImpl<$Res, _$BookingDataImpl>
    implements _$$BookingDataImplCopyWith<$Res> {
  __$$BookingDataImplCopyWithImpl(
      _$BookingDataImpl _value, $Res Function(_$BookingDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trekId = freezed,
    Object? customerId = freezed,
    Object? travelers = freezed,
    Object? totalAmount = freezed,
    Object? discountAmount = freezed,
    Object? finalAmount = freezed,
  }) {
    return _then(_$BookingDataImpl(
      trekId: freezed == trekId
          ? _value.trekId
          : trekId // ignore: cast_nullable_to_non_nullable
              as int?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      travelers: freezed == travelers
          ? _value._travelers
          : travelers // ignore: cast_nullable_to_non_nullable
              as List<Traveler>?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      discountAmount: freezed == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingDataImpl implements _BookingData {
  const _$BookingDataImpl(
      {this.trekId,
      this.customerId,
      final List<Traveler>? travelers,
      this.totalAmount,
      this.discountAmount,
      this.finalAmount})
      : _travelers = travelers;

  factory _$BookingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingDataImplFromJson(json);

  @override
  final int? trekId;
  @override
  final int? customerId;
  final List<Traveler>? _travelers;
  @override
  List<Traveler>? get travelers {
    final value = _travelers;
    if (value == null) return null;
    if (_travelers is EqualUnmodifiableListView) return _travelers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final dynamic totalAmount;
  @override
  final dynamic discountAmount;
  @override
  final dynamic finalAmount;

  @override
  String toString() {
    return 'BookingData(trekId: $trekId, customerId: $customerId, travelers: $travelers, totalAmount: $totalAmount, discountAmount: $discountAmount, finalAmount: $finalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingDataImpl &&
            (identical(other.trekId, trekId) || other.trekId == trekId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            const DeepCollectionEquality()
                .equals(other._travelers, _travelers) &&
            const DeepCollectionEquality()
                .equals(other.totalAmount, totalAmount) &&
            const DeepCollectionEquality()
                .equals(other.discountAmount, discountAmount) &&
            const DeepCollectionEquality()
                .equals(other.finalAmount, finalAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      trekId,
      customerId,
      const DeepCollectionEquality().hash(_travelers),
      const DeepCollectionEquality().hash(totalAmount),
      const DeepCollectionEquality().hash(discountAmount),
      const DeepCollectionEquality().hash(finalAmount));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingDataImplCopyWith<_$BookingDataImpl> get copyWith =>
      __$$BookingDataImplCopyWithImpl<_$BookingDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingDataImplToJson(
      this,
    );
  }
}

abstract class _BookingData implements BookingData {
  const factory _BookingData(
      {final int? trekId,
      final int? customerId,
      final List<Traveler>? travelers,
      final dynamic totalAmount,
      final dynamic discountAmount,
      final dynamic finalAmount}) = _$BookingDataImpl;

  factory _BookingData.fromJson(Map<String, dynamic> json) =
      _$BookingDataImpl.fromJson;

  @override
  int? get trekId;
  @override
  int? get customerId;
  @override
  List<Traveler>? get travelers;
  @override
  dynamic get totalAmount;
  @override
  dynamic get discountAmount;
  @override
  dynamic get finalAmount;
  @override
  @JsonKey(ignore: true)
  _$$BookingDataImplCopyWith<_$BookingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalculateFareRequestModel _$CalculateFareRequestModelFromJson(
    Map<String, dynamic> json) {
  return _CalculateFareRequestModel.fromJson(json);
}

/// @nodoc
mixin _$CalculateFareRequestModel {
  @JsonKey(name: 'batch_id')
  int? get batchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'traveler_count')
  int get travelerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_code')
  String? get couponCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_type')
  String? get cancellationPolicyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'add_insurance')
  bool get addInsurance => throw _privateConstructorUsedError;
  @JsonKey(name: 'add_cancellation_protection')
  bool get addFreeCancellationProtection => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalculateFareRequestModelCopyWith<CalculateFareRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculateFareRequestModelCopyWith<$Res> {
  factory $CalculateFareRequestModelCopyWith(CalculateFareRequestModel value,
          $Res Function(CalculateFareRequestModel) then) =
      _$CalculateFareRequestModelCopyWithImpl<$Res, CalculateFareRequestModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'traveler_count') int travelerCount,
      @JsonKey(name: 'coupon_code') String? couponCode,
      @JsonKey(name: 'cancellation_policy_type') String? cancellationPolicyType,
      @JsonKey(name: 'add_insurance') bool addInsurance,
      @JsonKey(name: 'add_cancellation_protection')
      bool addFreeCancellationProtection});
}

/// @nodoc
class _$CalculateFareRequestModelCopyWithImpl<$Res,
        $Val extends CalculateFareRequestModel>
    implements $CalculateFareRequestModelCopyWith<$Res> {
  _$CalculateFareRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batchId = freezed,
    Object? travelerCount = null,
    Object? couponCode = freezed,
    Object? cancellationPolicyType = freezed,
    Object? addInsurance = null,
    Object? addFreeCancellationProtection = null,
  }) {
    return _then(_value.copyWith(
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      travelerCount: null == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as int,
      couponCode: freezed == couponCode
          ? _value.couponCode
          : couponCode // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as String?,
      addInsurance: null == addInsurance
          ? _value.addInsurance
          : addInsurance // ignore: cast_nullable_to_non_nullable
              as bool,
      addFreeCancellationProtection: null == addFreeCancellationProtection
          ? _value.addFreeCancellationProtection
          : addFreeCancellationProtection // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalculateFareRequestModelImplCopyWith<$Res>
    implements $CalculateFareRequestModelCopyWith<$Res> {
  factory _$$CalculateFareRequestModelImplCopyWith(
          _$CalculateFareRequestModelImpl value,
          $Res Function(_$CalculateFareRequestModelImpl) then) =
      __$$CalculateFareRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'batch_id') int? batchId,
      @JsonKey(name: 'traveler_count') int travelerCount,
      @JsonKey(name: 'coupon_code') String? couponCode,
      @JsonKey(name: 'cancellation_policy_type') String? cancellationPolicyType,
      @JsonKey(name: 'add_insurance') bool addInsurance,
      @JsonKey(name: 'add_cancellation_protection')
      bool addFreeCancellationProtection});
}

/// @nodoc
class __$$CalculateFareRequestModelImplCopyWithImpl<$Res>
    extends _$CalculateFareRequestModelCopyWithImpl<$Res,
        _$CalculateFareRequestModelImpl>
    implements _$$CalculateFareRequestModelImplCopyWith<$Res> {
  __$$CalculateFareRequestModelImplCopyWithImpl(
      _$CalculateFareRequestModelImpl _value,
      $Res Function(_$CalculateFareRequestModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batchId = freezed,
    Object? travelerCount = null,
    Object? couponCode = freezed,
    Object? cancellationPolicyType = freezed,
    Object? addInsurance = null,
    Object? addFreeCancellationProtection = null,
  }) {
    return _then(_$CalculateFareRequestModelImpl(
      batchId: freezed == batchId
          ? _value.batchId
          : batchId // ignore: cast_nullable_to_non_nullable
              as int?,
      travelerCount: null == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as int,
      couponCode: freezed == couponCode
          ? _value.couponCode
          : couponCode // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as String?,
      addInsurance: null == addInsurance
          ? _value.addInsurance
          : addInsurance // ignore: cast_nullable_to_non_nullable
              as bool,
      addFreeCancellationProtection: null == addFreeCancellationProtection
          ? _value.addFreeCancellationProtection
          : addFreeCancellationProtection // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalculateFareRequestModelImpl implements _CalculateFareRequestModel {
  const _$CalculateFareRequestModelImpl(
      {@JsonKey(name: 'batch_id') required this.batchId,
      @JsonKey(name: 'traveler_count') required this.travelerCount,
      @JsonKey(name: 'coupon_code') required this.couponCode,
      @JsonKey(name: 'cancellation_policy_type') this.cancellationPolicyType,
      @JsonKey(name: 'add_insurance') required this.addInsurance,
      @JsonKey(name: 'add_cancellation_protection')
      required this.addFreeCancellationProtection});

  factory _$CalculateFareRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalculateFareRequestModelImplFromJson(json);

  @override
  @JsonKey(name: 'batch_id')
  final int? batchId;
  @override
  @JsonKey(name: 'traveler_count')
  final int travelerCount;
  @override
  @JsonKey(name: 'coupon_code')
  final String? couponCode;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  final String? cancellationPolicyType;
  @override
  @JsonKey(name: 'add_insurance')
  final bool addInsurance;
  @override
  @JsonKey(name: 'add_cancellation_protection')
  final bool addFreeCancellationProtection;

  @override
  String toString() {
    return 'CalculateFareRequestModel(batchId: $batchId, travelerCount: $travelerCount, couponCode: $couponCode, cancellationPolicyType: $cancellationPolicyType, addInsurance: $addInsurance, addFreeCancellationProtection: $addFreeCancellationProtection)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculateFareRequestModelImpl &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.travelerCount, travelerCount) ||
                other.travelerCount == travelerCount) &&
            (identical(other.couponCode, couponCode) ||
                other.couponCode == couponCode) &&
            (identical(other.cancellationPolicyType, cancellationPolicyType) ||
                other.cancellationPolicyType == cancellationPolicyType) &&
            (identical(other.addInsurance, addInsurance) ||
                other.addInsurance == addInsurance) &&
            (identical(other.addFreeCancellationProtection,
                    addFreeCancellationProtection) ||
                other.addFreeCancellationProtection ==
                    addFreeCancellationProtection));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      batchId,
      travelerCount,
      couponCode,
      cancellationPolicyType,
      addInsurance,
      addFreeCancellationProtection);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculateFareRequestModelImplCopyWith<_$CalculateFareRequestModelImpl>
      get copyWith => __$$CalculateFareRequestModelImplCopyWithImpl<
          _$CalculateFareRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalculateFareRequestModelImplToJson(
      this,
    );
  }
}

abstract class _CalculateFareRequestModel implements CalculateFareRequestModel {
  const factory _CalculateFareRequestModel(
          {@JsonKey(name: 'batch_id') required final int? batchId,
          @JsonKey(name: 'traveler_count') required final int travelerCount,
          @JsonKey(name: 'coupon_code') required final String? couponCode,
          @JsonKey(name: 'cancellation_policy_type')
          final String? cancellationPolicyType,
          @JsonKey(name: 'add_insurance') required final bool addInsurance,
          @JsonKey(name: 'add_cancellation_protection')
          required final bool addFreeCancellationProtection}) =
      _$CalculateFareRequestModelImpl;

  factory _CalculateFareRequestModel.fromJson(Map<String, dynamic> json) =
      _$CalculateFareRequestModelImpl.fromJson;

  @override
  @JsonKey(name: 'batch_id')
  int? get batchId;
  @override
  @JsonKey(name: 'traveler_count')
  int get travelerCount;
  @override
  @JsonKey(name: 'coupon_code')
  String? get couponCode;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  String? get cancellationPolicyType;
  @override
  @JsonKey(name: 'add_insurance')
  bool get addInsurance;
  @override
  @JsonKey(name: 'add_cancellation_protection')
  bool get addFreeCancellationProtection;
  @override
  @JsonKey(ignore: true)
  _$$CalculateFareRequestModelImplCopyWith<_$CalculateFareRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CalculateFareResponseModel _$CalculateFareResponseModelFromJson(
    Map<String, dynamic> json) {
  return _CalculateFareResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CalculateFareResponseModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get fareToken => throw _privateConstructorUsedError;
  BreakDownDataModel? get breakdown => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_details')
  dynamic get couponDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  dynamic get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_cancellation')
  dynamic get allowCancellation => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_insurance')
  dynamic get allowInsurance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalculateFareResponseModelCopyWith<CalculateFareResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculateFareResponseModelCopyWith<$Res> {
  factory $CalculateFareResponseModelCopyWith(CalculateFareResponseModel value,
          $Res Function(CalculateFareResponseModel) then) =
      _$CalculateFareResponseModelCopyWithImpl<$Res,
          CalculateFareResponseModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      String? fareToken,
      BreakDownDataModel? breakdown,
      @JsonKey(name: 'coupon_details') dynamic couponDetails,
      @JsonKey(name: 'expires_at') dynamic expiresAt,
      @JsonKey(name: 'allow_cancellation') dynamic allowCancellation,
      @JsonKey(name: 'allow_insurance') dynamic allowInsurance});

  $BreakDownDataModelCopyWith<$Res>? get breakdown;
}

/// @nodoc
class _$CalculateFareResponseModelCopyWithImpl<$Res,
        $Val extends CalculateFareResponseModel>
    implements $CalculateFareResponseModelCopyWith<$Res> {
  _$CalculateFareResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? fareToken = freezed,
    Object? breakdown = freezed,
    Object? couponDetails = freezed,
    Object? expiresAt = freezed,
    Object? allowCancellation = freezed,
    Object? allowInsurance = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      fareToken: freezed == fareToken
          ? _value.fareToken
          : fareToken // ignore: cast_nullable_to_non_nullable
              as String?,
      breakdown: freezed == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as BreakDownDataModel?,
      couponDetails: freezed == couponDetails
          ? _value.couponDetails
          : couponDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      allowCancellation: freezed == allowCancellation
          ? _value.allowCancellation
          : allowCancellation // ignore: cast_nullable_to_non_nullable
              as dynamic,
      allowInsurance: freezed == allowInsurance
          ? _value.allowInsurance
          : allowInsurance // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BreakDownDataModelCopyWith<$Res>? get breakdown {
    if (_value.breakdown == null) {
      return null;
    }

    return $BreakDownDataModelCopyWith<$Res>(_value.breakdown!, (value) {
      return _then(_value.copyWith(breakdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalculateFareResponseModelImplCopyWith<$Res>
    implements $CalculateFareResponseModelCopyWith<$Res> {
  factory _$$CalculateFareResponseModelImplCopyWith(
          _$CalculateFareResponseModelImpl value,
          $Res Function(_$CalculateFareResponseModelImpl) then) =
      __$$CalculateFareResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      String? fareToken,
      BreakDownDataModel? breakdown,
      @JsonKey(name: 'coupon_details') dynamic couponDetails,
      @JsonKey(name: 'expires_at') dynamic expiresAt,
      @JsonKey(name: 'allow_cancellation') dynamic allowCancellation,
      @JsonKey(name: 'allow_insurance') dynamic allowInsurance});

  @override
  $BreakDownDataModelCopyWith<$Res>? get breakdown;
}

/// @nodoc
class __$$CalculateFareResponseModelImplCopyWithImpl<$Res>
    extends _$CalculateFareResponseModelCopyWithImpl<$Res,
        _$CalculateFareResponseModelImpl>
    implements _$$CalculateFareResponseModelImplCopyWith<$Res> {
  __$$CalculateFareResponseModelImplCopyWithImpl(
      _$CalculateFareResponseModelImpl _value,
      $Res Function(_$CalculateFareResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? fareToken = freezed,
    Object? breakdown = freezed,
    Object? couponDetails = freezed,
    Object? expiresAt = freezed,
    Object? allowCancellation = freezed,
    Object? allowInsurance = freezed,
  }) {
    return _then(_$CalculateFareResponseModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      fareToken: freezed == fareToken
          ? _value.fareToken
          : fareToken // ignore: cast_nullable_to_non_nullable
              as String?,
      breakdown: freezed == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as BreakDownDataModel?,
      couponDetails: freezed == couponDetails
          ? _value.couponDetails
          : couponDetails // ignore: cast_nullable_to_non_nullable
              as dynamic,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      allowCancellation: freezed == allowCancellation
          ? _value.allowCancellation
          : allowCancellation // ignore: cast_nullable_to_non_nullable
              as dynamic,
      allowInsurance: freezed == allowInsurance
          ? _value.allowInsurance
          : allowInsurance // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalculateFareResponseModelImpl implements _CalculateFareResponseModel {
  const _$CalculateFareResponseModelImpl(
      {this.success,
      this.message,
      this.fareToken,
      this.breakdown,
      @JsonKey(name: 'coupon_details') this.couponDetails,
      @JsonKey(name: 'expires_at') this.expiresAt,
      @JsonKey(name: 'allow_cancellation') this.allowCancellation,
      @JsonKey(name: 'allow_insurance') this.allowInsurance});

  factory _$CalculateFareResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CalculateFareResponseModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  @override
  final String? fareToken;
  @override
  final BreakDownDataModel? breakdown;
  @override
  @JsonKey(name: 'coupon_details')
  final dynamic couponDetails;
  @override
  @JsonKey(name: 'expires_at')
  final dynamic expiresAt;
  @override
  @JsonKey(name: 'allow_cancellation')
  final dynamic allowCancellation;
  @override
  @JsonKey(name: 'allow_insurance')
  final dynamic allowInsurance;

  @override
  String toString() {
    return 'CalculateFareResponseModel(success: $success, message: $message, fareToken: $fareToken, breakdown: $breakdown, couponDetails: $couponDetails, expiresAt: $expiresAt, allowCancellation: $allowCancellation, allowInsurance: $allowInsurance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculateFareResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.fareToken, fareToken) ||
                other.fareToken == fareToken) &&
            (identical(other.breakdown, breakdown) ||
                other.breakdown == breakdown) &&
            const DeepCollectionEquality()
                .equals(other.couponDetails, couponDetails) &&
            const DeepCollectionEquality().equals(other.expiresAt, expiresAt) &&
            const DeepCollectionEquality()
                .equals(other.allowCancellation, allowCancellation) &&
            const DeepCollectionEquality()
                .equals(other.allowInsurance, allowInsurance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      success,
      message,
      fareToken,
      breakdown,
      const DeepCollectionEquality().hash(couponDetails),
      const DeepCollectionEquality().hash(expiresAt),
      const DeepCollectionEquality().hash(allowCancellation),
      const DeepCollectionEquality().hash(allowInsurance));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculateFareResponseModelImplCopyWith<_$CalculateFareResponseModelImpl>
      get copyWith => __$$CalculateFareResponseModelImplCopyWithImpl<
          _$CalculateFareResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalculateFareResponseModelImplToJson(
      this,
    );
  }
}

abstract class _CalculateFareResponseModel
    implements CalculateFareResponseModel {
  const factory _CalculateFareResponseModel(
          {final bool? success,
          final String? message,
          final String? fareToken,
          final BreakDownDataModel? breakdown,
          @JsonKey(name: 'coupon_details') final dynamic couponDetails,
          @JsonKey(name: 'expires_at') final dynamic expiresAt,
          @JsonKey(name: 'allow_cancellation') final dynamic allowCancellation,
          @JsonKey(name: 'allow_insurance') final dynamic allowInsurance}) =
      _$CalculateFareResponseModelImpl;

  factory _CalculateFareResponseModel.fromJson(Map<String, dynamic> json) =
      _$CalculateFareResponseModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  String? get fareToken;
  @override
  BreakDownDataModel? get breakdown;
  @override
  @JsonKey(name: 'coupon_details')
  dynamic get couponDetails;
  @override
  @JsonKey(name: 'expires_at')
  dynamic get expiresAt;
  @override
  @JsonKey(name: 'allow_cancellation')
  dynamic get allowCancellation;
  @override
  @JsonKey(name: 'allow_insurance')
  dynamic get allowInsurance;
  @override
  @JsonKey(ignore: true)
  _$$CalculateFareResponseModelImplCopyWith<_$CalculateFareResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

BreakDownDataModel _$BreakDownDataModelFromJson(Map<String, dynamic> json) {
  return _BreakDownDataModel.fromJson(json);
}

/// @nodoc
mixin _$BreakDownDataModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_price')
  dynamic get basePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'traveler_count')
  dynamic get travelerCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_total')
  dynamic get baseTotal => throw _privateConstructorUsedError;
  dynamic get discount => throw _privateConstructorUsedError;
  @JsonKey(name: 'coupon_code')
  dynamic get couponCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_after_discount')
  dynamic get amountAfterDiscount => throw _privateConstructorUsedError;
  dynamic get taxes => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_tax')
  dynamic get totalTax => throw _privateConstructorUsedError;
  dynamic get gst => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform_fee')
  dynamic get platformFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'insurance_fee')
  dynamic get insuranceFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_fee')
  dynamic get cancellationFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_amount')
  dynamic get finalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellation_policy_type')
  dynamic get cancellationPolicyType => throw _privateConstructorUsedError;
  @JsonKey(name: 'advance_amount')
  dynamic get advanceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_to_pay_now')
  dynamic get amountToPayNow => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_amount')
  dynamic get remainingAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BreakDownDataModelCopyWith<BreakDownDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakDownDataModelCopyWith<$Res> {
  factory $BreakDownDataModelCopyWith(
          BreakDownDataModel value, $Res Function(BreakDownDataModel) then) =
      _$BreakDownDataModelCopyWithImpl<$Res, BreakDownDataModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'base_price') dynamic basePrice,
      @JsonKey(name: 'traveler_count') dynamic travelerCount,
      @JsonKey(name: 'base_total') dynamic baseTotal,
      dynamic discount,
      @JsonKey(name: 'coupon_code') dynamic couponCode,
      @JsonKey(name: 'amount_after_discount') dynamic amountAfterDiscount,
      dynamic taxes,
      @JsonKey(name: 'total_tax') dynamic totalTax,
      dynamic gst,
      @JsonKey(name: 'platform_fee') dynamic platformFee,
      @JsonKey(name: 'insurance_fee') dynamic insuranceFee,
      @JsonKey(name: 'cancellation_fee') dynamic cancellationFee,
      @JsonKey(name: 'final_amount') dynamic finalAmount,
      @JsonKey(name: 'cancellation_policy_type') dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount') dynamic advanceAmount,
      @JsonKey(name: 'amount_to_pay_now') dynamic amountToPayNow,
      @JsonKey(name: 'remaining_amount') dynamic remainingAmount});
}

/// @nodoc
class _$BreakDownDataModelCopyWithImpl<$Res, $Val extends BreakDownDataModel>
    implements $BreakDownDataModelCopyWith<$Res> {
  _$BreakDownDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? basePrice = freezed,
    Object? travelerCount = freezed,
    Object? baseTotal = freezed,
    Object? discount = freezed,
    Object? couponCode = freezed,
    Object? amountAfterDiscount = freezed,
    Object? taxes = freezed,
    Object? totalTax = freezed,
    Object? gst = freezed,
    Object? platformFee = freezed,
    Object? insuranceFee = freezed,
    Object? cancellationFee = freezed,
    Object? finalAmount = freezed,
    Object? cancellationPolicyType = freezed,
    Object? advanceAmount = freezed,
    Object? amountToPayNow = freezed,
    Object? remainingAmount = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as dynamic,
      travelerCount: freezed == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      baseTotal: freezed == baseTotal
          ? _value.baseTotal
          : baseTotal // ignore: cast_nullable_to_non_nullable
              as dynamic,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      couponCode: freezed == couponCode
          ? _value.couponCode
          : couponCode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountAfterDiscount: freezed == amountAfterDiscount
          ? _value.amountAfterDiscount
          : amountAfterDiscount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      taxes: freezed == taxes
          ? _value.taxes
          : taxes // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalTax: freezed == totalTax
          ? _value.totalTax
          : totalTax // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gst: freezed == gst
          ? _value.gst
          : gst // ignore: cast_nullable_to_non_nullable
              as dynamic,
      platformFee: freezed == platformFee
          ? _value.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      insuranceFee: freezed == insuranceFee
          ? _value.insuranceFee
          : insuranceFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationFee: freezed == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as dynamic,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountToPayNow: freezed == amountToPayNow
          ? _value.amountToPayNow
          : amountToPayNow // ignore: cast_nullable_to_non_nullable
              as dynamic,
      remainingAmount: freezed == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BreakDownDataModelImplCopyWith<$Res>
    implements $BreakDownDataModelCopyWith<$Res> {
  factory _$$BreakDownDataModelImplCopyWith(_$BreakDownDataModelImpl value,
          $Res Function(_$BreakDownDataModelImpl) then) =
      __$$BreakDownDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'base_price') dynamic basePrice,
      @JsonKey(name: 'traveler_count') dynamic travelerCount,
      @JsonKey(name: 'base_total') dynamic baseTotal,
      dynamic discount,
      @JsonKey(name: 'coupon_code') dynamic couponCode,
      @JsonKey(name: 'amount_after_discount') dynamic amountAfterDiscount,
      dynamic taxes,
      @JsonKey(name: 'total_tax') dynamic totalTax,
      dynamic gst,
      @JsonKey(name: 'platform_fee') dynamic platformFee,
      @JsonKey(name: 'insurance_fee') dynamic insuranceFee,
      @JsonKey(name: 'cancellation_fee') dynamic cancellationFee,
      @JsonKey(name: 'final_amount') dynamic finalAmount,
      @JsonKey(name: 'cancellation_policy_type') dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount') dynamic advanceAmount,
      @JsonKey(name: 'amount_to_pay_now') dynamic amountToPayNow,
      @JsonKey(name: 'remaining_amount') dynamic remainingAmount});
}

/// @nodoc
class __$$BreakDownDataModelImplCopyWithImpl<$Res>
    extends _$BreakDownDataModelCopyWithImpl<$Res, _$BreakDownDataModelImpl>
    implements _$$BreakDownDataModelImplCopyWith<$Res> {
  __$$BreakDownDataModelImplCopyWithImpl(_$BreakDownDataModelImpl _value,
      $Res Function(_$BreakDownDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? basePrice = freezed,
    Object? travelerCount = freezed,
    Object? baseTotal = freezed,
    Object? discount = freezed,
    Object? couponCode = freezed,
    Object? amountAfterDiscount = freezed,
    Object? taxes = freezed,
    Object? totalTax = freezed,
    Object? gst = freezed,
    Object? platformFee = freezed,
    Object? insuranceFee = freezed,
    Object? cancellationFee = freezed,
    Object? finalAmount = freezed,
    Object? cancellationPolicyType = freezed,
    Object? advanceAmount = freezed,
    Object? amountToPayNow = freezed,
    Object? remainingAmount = freezed,
  }) {
    return _then(_$BreakDownDataModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      basePrice: freezed == basePrice
          ? _value.basePrice
          : basePrice // ignore: cast_nullable_to_non_nullable
              as dynamic,
      travelerCount: freezed == travelerCount
          ? _value.travelerCount
          : travelerCount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      baseTotal: freezed == baseTotal
          ? _value.baseTotal
          : baseTotal // ignore: cast_nullable_to_non_nullable
              as dynamic,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      couponCode: freezed == couponCode
          ? _value.couponCode
          : couponCode // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountAfterDiscount: freezed == amountAfterDiscount
          ? _value.amountAfterDiscount
          : amountAfterDiscount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      taxes: freezed == taxes
          ? _value.taxes
          : taxes // ignore: cast_nullable_to_non_nullable
              as dynamic,
      totalTax: freezed == totalTax
          ? _value.totalTax
          : totalTax // ignore: cast_nullable_to_non_nullable
              as dynamic,
      gst: freezed == gst
          ? _value.gst
          : gst // ignore: cast_nullable_to_non_nullable
              as dynamic,
      platformFee: freezed == platformFee
          ? _value.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      insuranceFee: freezed == insuranceFee
          ? _value.insuranceFee
          : insuranceFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationFee: freezed == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as dynamic,
      finalAmount: freezed == finalAmount
          ? _value.finalAmount
          : finalAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      cancellationPolicyType: freezed == cancellationPolicyType
          ? _value.cancellationPolicyType
          : cancellationPolicyType // ignore: cast_nullable_to_non_nullable
              as dynamic,
      advanceAmount: freezed == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
      amountToPayNow: freezed == amountToPayNow
          ? _value.amountToPayNow
          : amountToPayNow // ignore: cast_nullable_to_non_nullable
              as dynamic,
      remainingAmount: freezed == remainingAmount
          ? _value.remainingAmount
          : remainingAmount // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BreakDownDataModelImpl implements _BreakDownDataModel {
  const _$BreakDownDataModelImpl(
      {this.id,
      @JsonKey(name: 'base_price') this.basePrice,
      @JsonKey(name: 'traveler_count') this.travelerCount,
      @JsonKey(name: 'base_total') this.baseTotal,
      this.discount,
      @JsonKey(name: 'coupon_code') this.couponCode,
      @JsonKey(name: 'amount_after_discount') this.amountAfterDiscount,
      this.taxes,
      @JsonKey(name: 'total_tax') this.totalTax,
      this.gst,
      @JsonKey(name: 'platform_fee') this.platformFee,
      @JsonKey(name: 'insurance_fee') this.insuranceFee,
      @JsonKey(name: 'cancellation_fee') this.cancellationFee,
      @JsonKey(name: 'final_amount') this.finalAmount,
      @JsonKey(name: 'cancellation_policy_type') this.cancellationPolicyType,
      @JsonKey(name: 'advance_amount') this.advanceAmount,
      @JsonKey(name: 'amount_to_pay_now') this.amountToPayNow,
      @JsonKey(name: 'remaining_amount') this.remainingAmount});

  factory _$BreakDownDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BreakDownDataModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'base_price')
  final dynamic basePrice;
  @override
  @JsonKey(name: 'traveler_count')
  final dynamic travelerCount;
  @override
  @JsonKey(name: 'base_total')
  final dynamic baseTotal;
  @override
  final dynamic discount;
  @override
  @JsonKey(name: 'coupon_code')
  final dynamic couponCode;
  @override
  @JsonKey(name: 'amount_after_discount')
  final dynamic amountAfterDiscount;
  @override
  final dynamic taxes;
  @override
  @JsonKey(name: 'total_tax')
  final dynamic totalTax;
  @override
  final dynamic gst;
  @override
  @JsonKey(name: 'platform_fee')
  final dynamic platformFee;
  @override
  @JsonKey(name: 'insurance_fee')
  final dynamic insuranceFee;
  @override
  @JsonKey(name: 'cancellation_fee')
  final dynamic cancellationFee;
  @override
  @JsonKey(name: 'final_amount')
  final dynamic finalAmount;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  final dynamic cancellationPolicyType;
  @override
  @JsonKey(name: 'advance_amount')
  final dynamic advanceAmount;
  @override
  @JsonKey(name: 'amount_to_pay_now')
  final dynamic amountToPayNow;
  @override
  @JsonKey(name: 'remaining_amount')
  final dynamic remainingAmount;

  @override
  String toString() {
    return 'BreakDownDataModel(id: $id, basePrice: $basePrice, travelerCount: $travelerCount, baseTotal: $baseTotal, discount: $discount, couponCode: $couponCode, amountAfterDiscount: $amountAfterDiscount, taxes: $taxes, totalTax: $totalTax, gst: $gst, platformFee: $platformFee, insuranceFee: $insuranceFee, cancellationFee: $cancellationFee, finalAmount: $finalAmount, cancellationPolicyType: $cancellationPolicyType, advanceAmount: $advanceAmount, amountToPayNow: $amountToPayNow, remainingAmount: $remainingAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BreakDownDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.basePrice, basePrice) &&
            const DeepCollectionEquality()
                .equals(other.travelerCount, travelerCount) &&
            const DeepCollectionEquality().equals(other.baseTotal, baseTotal) &&
            const DeepCollectionEquality().equals(other.discount, discount) &&
            const DeepCollectionEquality()
                .equals(other.couponCode, couponCode) &&
            const DeepCollectionEquality()
                .equals(other.amountAfterDiscount, amountAfterDiscount) &&
            const DeepCollectionEquality().equals(other.taxes, taxes) &&
            const DeepCollectionEquality().equals(other.totalTax, totalTax) &&
            const DeepCollectionEquality().equals(other.gst, gst) &&
            const DeepCollectionEquality()
                .equals(other.platformFee, platformFee) &&
            const DeepCollectionEquality()
                .equals(other.insuranceFee, insuranceFee) &&
            const DeepCollectionEquality()
                .equals(other.cancellationFee, cancellationFee) &&
            const DeepCollectionEquality()
                .equals(other.finalAmount, finalAmount) &&
            const DeepCollectionEquality()
                .equals(other.cancellationPolicyType, cancellationPolicyType) &&
            const DeepCollectionEquality()
                .equals(other.advanceAmount, advanceAmount) &&
            const DeepCollectionEquality()
                .equals(other.amountToPayNow, amountToPayNow) &&
            const DeepCollectionEquality()
                .equals(other.remainingAmount, remainingAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(basePrice),
      const DeepCollectionEquality().hash(travelerCount),
      const DeepCollectionEquality().hash(baseTotal),
      const DeepCollectionEquality().hash(discount),
      const DeepCollectionEquality().hash(couponCode),
      const DeepCollectionEquality().hash(amountAfterDiscount),
      const DeepCollectionEquality().hash(taxes),
      const DeepCollectionEquality().hash(totalTax),
      const DeepCollectionEquality().hash(gst),
      const DeepCollectionEquality().hash(platformFee),
      const DeepCollectionEquality().hash(insuranceFee),
      const DeepCollectionEquality().hash(cancellationFee),
      const DeepCollectionEquality().hash(finalAmount),
      const DeepCollectionEquality().hash(cancellationPolicyType),
      const DeepCollectionEquality().hash(advanceAmount),
      const DeepCollectionEquality().hash(amountToPayNow),
      const DeepCollectionEquality().hash(remainingAmount));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BreakDownDataModelImplCopyWith<_$BreakDownDataModelImpl> get copyWith =>
      __$$BreakDownDataModelImplCopyWithImpl<_$BreakDownDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BreakDownDataModelImplToJson(
      this,
    );
  }
}

abstract class _BreakDownDataModel implements BreakDownDataModel {
  const factory _BreakDownDataModel(
      {final int? id,
      @JsonKey(name: 'base_price') final dynamic basePrice,
      @JsonKey(name: 'traveler_count') final dynamic travelerCount,
      @JsonKey(name: 'base_total') final dynamic baseTotal,
      final dynamic discount,
      @JsonKey(name: 'coupon_code') final dynamic couponCode,
      @JsonKey(name: 'amount_after_discount') final dynamic amountAfterDiscount,
      final dynamic taxes,
      @JsonKey(name: 'total_tax') final dynamic totalTax,
      final dynamic gst,
      @JsonKey(name: 'platform_fee') final dynamic platformFee,
      @JsonKey(name: 'insurance_fee') final dynamic insuranceFee,
      @JsonKey(name: 'cancellation_fee') final dynamic cancellationFee,
      @JsonKey(name: 'final_amount') final dynamic finalAmount,
      @JsonKey(name: 'cancellation_policy_type')
      final dynamic cancellationPolicyType,
      @JsonKey(name: 'advance_amount') final dynamic advanceAmount,
      @JsonKey(name: 'amount_to_pay_now') final dynamic amountToPayNow,
      @JsonKey(name: 'remaining_amount')
      final dynamic remainingAmount}) = _$BreakDownDataModelImpl;

  factory _BreakDownDataModel.fromJson(Map<String, dynamic> json) =
      _$BreakDownDataModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'base_price')
  dynamic get basePrice;
  @override
  @JsonKey(name: 'traveler_count')
  dynamic get travelerCount;
  @override
  @JsonKey(name: 'base_total')
  dynamic get baseTotal;
  @override
  dynamic get discount;
  @override
  @JsonKey(name: 'coupon_code')
  dynamic get couponCode;
  @override
  @JsonKey(name: 'amount_after_discount')
  dynamic get amountAfterDiscount;
  @override
  dynamic get taxes;
  @override
  @JsonKey(name: 'total_tax')
  dynamic get totalTax;
  @override
  dynamic get gst;
  @override
  @JsonKey(name: 'platform_fee')
  dynamic get platformFee;
  @override
  @JsonKey(name: 'insurance_fee')
  dynamic get insuranceFee;
  @override
  @JsonKey(name: 'cancellation_fee')
  dynamic get cancellationFee;
  @override
  @JsonKey(name: 'final_amount')
  dynamic get finalAmount;
  @override
  @JsonKey(name: 'cancellation_policy_type')
  dynamic get cancellationPolicyType;
  @override
  @JsonKey(name: 'advance_amount')
  dynamic get advanceAmount;
  @override
  @JsonKey(name: 'amount_to_pay_now')
  dynamic get amountToPayNow;
  @override
  @JsonKey(name: 'remaining_amount')
  dynamic get remainingAmount;
  @override
  @JsonKey(ignore: true)
  _$$BreakDownDataModelImplCopyWith<_$BreakDownDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
