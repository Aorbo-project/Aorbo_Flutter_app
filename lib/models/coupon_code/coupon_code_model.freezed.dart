// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CouponCodeModel _$CouponCodeModelFromJson(Map<String, dynamic> json) {
  return _CouponCodeModel.fromJson(json);
}

/// @nodoc
mixin _$CouponCodeModel {
  bool? get success => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<CouponCardData>? get data => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_info')
  VendorInfo? get vendorInfo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CouponCodeModelCopyWith<CouponCodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponCodeModelCopyWith<$Res> {
  factory $CouponCodeModelCopyWith(
          CouponCodeModel value, $Res Function(CouponCodeModel) then) =
      _$CouponCodeModelCopyWithImpl<$Res, CouponCodeModel>;
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<CouponCardData>? data,
      int? count,
      @JsonKey(name: 'vendor_info') VendorInfo? vendorInfo});

  $VendorInfoCopyWith<$Res>? get vendorInfo;
}

/// @nodoc
class _$CouponCodeModelCopyWithImpl<$Res, $Val extends CouponCodeModel>
    implements $CouponCodeModelCopyWith<$Res> {
  _$CouponCodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
    Object? vendorInfo = freezed,
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
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<CouponCardData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorInfo: freezed == vendorInfo
          ? _value.vendorInfo
          : vendorInfo // ignore: cast_nullable_to_non_nullable
              as VendorInfo?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VendorInfoCopyWith<$Res>? get vendorInfo {
    if (_value.vendorInfo == null) {
      return null;
    }

    return $VendorInfoCopyWith<$Res>(_value.vendorInfo!, (value) {
      return _then(_value.copyWith(vendorInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CouponCodeModelImplCopyWith<$Res>
    implements $CouponCodeModelCopyWith<$Res> {
  factory _$$CouponCodeModelImplCopyWith(_$CouponCodeModelImpl value,
          $Res Function(_$CouponCodeModelImpl) then) =
      __$$CouponCodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? success,
      String? message,
      List<CouponCardData>? data,
      int? count,
      @JsonKey(name: 'vendor_info') VendorInfo? vendorInfo});

  @override
  $VendorInfoCopyWith<$Res>? get vendorInfo;
}

/// @nodoc
class __$$CouponCodeModelImplCopyWithImpl<$Res>
    extends _$CouponCodeModelCopyWithImpl<$Res, _$CouponCodeModelImpl>
    implements _$$CouponCodeModelImplCopyWith<$Res> {
  __$$CouponCodeModelImplCopyWithImpl(
      _$CouponCodeModelImpl _value, $Res Function(_$CouponCodeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? message = freezed,
    Object? data = freezed,
    Object? count = freezed,
    Object? vendorInfo = freezed,
  }) {
    return _then(_$CouponCodeModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<CouponCardData>?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      vendorInfo: freezed == vendorInfo
          ? _value.vendorInfo
          : vendorInfo // ignore: cast_nullable_to_non_nullable
              as VendorInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponCodeModelImpl implements _CouponCodeModel {
  const _$CouponCodeModelImpl(
      {this.success,
      this.message,
      final List<CouponCardData>? data,
      this.count,
      @JsonKey(name: 'vendor_info') this.vendorInfo})
      : _data = data;

  factory _$CouponCodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponCodeModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final String? message;
  final List<CouponCardData>? _data;
  @override
  List<CouponCardData>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? count;
  @override
  @JsonKey(name: 'vendor_info')
  final VendorInfo? vendorInfo;

  @override
  String toString() {
    return 'CouponCodeModel(success: $success, message: $message, data: $data, count: $count, vendorInfo: $vendorInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponCodeModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.vendorInfo, vendorInfo) ||
                other.vendorInfo == vendorInfo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message,
      const DeepCollectionEquality().hash(_data), count, vendorInfo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponCodeModelImplCopyWith<_$CouponCodeModelImpl> get copyWith =>
      __$$CouponCodeModelImplCopyWithImpl<_$CouponCodeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponCodeModelImplToJson(
      this,
    );
  }
}

abstract class _CouponCodeModel implements CouponCodeModel {
  const factory _CouponCodeModel(
          {final bool? success,
          final String? message,
          final List<CouponCardData>? data,
          final int? count,
          @JsonKey(name: 'vendor_info') final VendorInfo? vendorInfo}) =
      _$CouponCodeModelImpl;

  factory _CouponCodeModel.fromJson(Map<String, dynamic> json) =
      _$CouponCodeModelImpl.fromJson;

  @override
  bool? get success;
  @override
  String? get message;
  @override
  List<CouponCardData>? get data;
  @override
  int? get count;
  @override
  @JsonKey(name: 'vendor_info')
  VendorInfo? get vendorInfo;
  @override
  @JsonKey(ignore: true)
  _$$CouponCodeModelImplCopyWith<_$CouponCodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CouponCardData _$CouponCardDataFromJson(Map<String, dynamic> json) {
  return _CouponCardData.fromJson(json);
}

/// @nodoc
mixin _$CouponCardData {
  int? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imagePath => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_type')
  String? get discountType => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_value')
  String? get discountValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_amount')
  String? get minAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_discount_amount')
  String? get maxDiscountAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_uses')
  String? get maxUses => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_uses')
  int? get currentUses => throw _privateConstructorUsedError;
  @JsonKey(name: 'valid_from')
  String? get validFrom => throw _privateConstructorUsedError;
  @JsonKey(name: 'valid_until')
  String? get validUntil => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'approval_status')
  String? get approvalStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'admin_notes')
  String? get adminNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'terms_and_conditions')
  List<String>? get termsAndConditions => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_id')
  int? get vendorId => throw _privateConstructorUsedError;
  Vendor? get vendor => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_expired')
  bool? get isExpired => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'usage_percentage')
  int? get usagePercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_uses')
  String? get remainingUses => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CouponCardDataCopyWith<CouponCardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CouponCardDataCopyWith<$Res> {
  factory $CouponCardDataCopyWith(
          CouponCardData value, $Res Function(CouponCardData) then) =
      _$CouponCardDataCopyWithImpl<$Res, CouponCardData>;
  @useResult
  $Res call(
      {int? id,
      String? title,
      @JsonKey(name: 'image_url') String? imagePath,
      String? code,
      String? description,
      String? color,
      @JsonKey(name: 'discount_type') String? discountType,
      @JsonKey(name: 'discount_value') String? discountValue,
      @JsonKey(name: 'min_amount') String? minAmount,
      @JsonKey(name: 'max_discount_amount') String? maxDiscountAmount,
      @JsonKey(name: 'max_uses') String? maxUses,
      @JsonKey(name: 'current_uses') int? currentUses,
      @JsonKey(name: 'valid_from') String? validFrom,
      @JsonKey(name: 'valid_until') String? validUntil,
      String? status,
      @JsonKey(name: 'approval_status') String? approvalStatus,
      @JsonKey(name: 'admin_notes') String? adminNotes,
      @JsonKey(name: 'terms_and_conditions') List<String>? termsAndConditions,
      @JsonKey(name: 'vendor_id') int? vendorId,
      Vendor? vendor,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'is_expired') bool? isExpired,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'usage_percentage') int? usagePercentage,
      @JsonKey(name: 'remaining_uses') String? remainingUses});

  $VendorCopyWith<$Res>? get vendor;
}

/// @nodoc
class _$CouponCardDataCopyWithImpl<$Res, $Val extends CouponCardData>
    implements $CouponCardDataCopyWith<$Res> {
  _$CouponCardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? imagePath = freezed,
    Object? code = freezed,
    Object? description = freezed,
    Object? color = freezed,
    Object? discountType = freezed,
    Object? discountValue = freezed,
    Object? minAmount = freezed,
    Object? maxDiscountAmount = freezed,
    Object? maxUses = freezed,
    Object? currentUses = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? status = freezed,
    Object? approvalStatus = freezed,
    Object? adminNotes = freezed,
    Object? termsAndConditions = freezed,
    Object? vendorId = freezed,
    Object? vendor = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isExpired = freezed,
    Object? isActive = freezed,
    Object? usagePercentage = freezed,
    Object? remainingUses = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as String?,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      maxDiscountAmount: freezed == maxDiscountAmount
          ? _value.maxDiscountAmount
          : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as String?,
      currentUses: freezed == currentUses
          ? _value.currentUses
          : currentUses // ignore: cast_nullable_to_non_nullable
              as int?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      approvalStatus: freezed == approvalStatus
          ? _value.approvalStatus
          : approvalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      termsAndConditions: freezed == termsAndConditions
          ? _value.termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isExpired: freezed == isExpired
          ? _value.isExpired
          : isExpired // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      usagePercentage: freezed == usagePercentage
          ? _value.usagePercentage
          : usagePercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingUses: freezed == remainingUses
          ? _value.remainingUses
          : remainingUses // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VendorCopyWith<$Res>? get vendor {
    if (_value.vendor == null) {
      return null;
    }

    return $VendorCopyWith<$Res>(_value.vendor!, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CouponCardDataImplCopyWith<$Res>
    implements $CouponCardDataCopyWith<$Res> {
  factory _$$CouponCardDataImplCopyWith(_$CouponCardDataImpl value,
          $Res Function(_$CouponCardDataImpl) then) =
      __$$CouponCardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String? title,
      @JsonKey(name: 'image_url') String? imagePath,
      String? code,
      String? description,
      String? color,
      @JsonKey(name: 'discount_type') String? discountType,
      @JsonKey(name: 'discount_value') String? discountValue,
      @JsonKey(name: 'min_amount') String? minAmount,
      @JsonKey(name: 'max_discount_amount') String? maxDiscountAmount,
      @JsonKey(name: 'max_uses') String? maxUses,
      @JsonKey(name: 'current_uses') int? currentUses,
      @JsonKey(name: 'valid_from') String? validFrom,
      @JsonKey(name: 'valid_until') String? validUntil,
      String? status,
      @JsonKey(name: 'approval_status') String? approvalStatus,
      @JsonKey(name: 'admin_notes') String? adminNotes,
      @JsonKey(name: 'terms_and_conditions') List<String>? termsAndConditions,
      @JsonKey(name: 'vendor_id') int? vendorId,
      Vendor? vendor,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'is_expired') bool? isExpired,
      @JsonKey(name: 'is_active') bool? isActive,
      @JsonKey(name: 'usage_percentage') int? usagePercentage,
      @JsonKey(name: 'remaining_uses') String? remainingUses});

  @override
  $VendorCopyWith<$Res>? get vendor;
}

/// @nodoc
class __$$CouponCardDataImplCopyWithImpl<$Res>
    extends _$CouponCardDataCopyWithImpl<$Res, _$CouponCardDataImpl>
    implements _$$CouponCardDataImplCopyWith<$Res> {
  __$$CouponCardDataImplCopyWithImpl(
      _$CouponCardDataImpl _value, $Res Function(_$CouponCardDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? imagePath = freezed,
    Object? code = freezed,
    Object? description = freezed,
    Object? color = freezed,
    Object? discountType = freezed,
    Object? discountValue = freezed,
    Object? minAmount = freezed,
    Object? maxDiscountAmount = freezed,
    Object? maxUses = freezed,
    Object? currentUses = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? status = freezed,
    Object? approvalStatus = freezed,
    Object? adminNotes = freezed,
    Object? termsAndConditions = freezed,
    Object? vendorId = freezed,
    Object? vendor = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isExpired = freezed,
    Object? isActive = freezed,
    Object? usagePercentage = freezed,
    Object? remainingUses = freezed,
  }) {
    return _then(_$CouponCardDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      discountType: freezed == discountType
          ? _value.discountType
          : discountType // ignore: cast_nullable_to_non_nullable
              as String?,
      discountValue: freezed == discountValue
          ? _value.discountValue
          : discountValue // ignore: cast_nullable_to_non_nullable
              as String?,
      minAmount: freezed == minAmount
          ? _value.minAmount
          : minAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      maxDiscountAmount: freezed == maxDiscountAmount
          ? _value.maxDiscountAmount
          : maxDiscountAmount // ignore: cast_nullable_to_non_nullable
              as String?,
      maxUses: freezed == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as String?,
      currentUses: freezed == currentUses
          ? _value.currentUses
          : currentUses // ignore: cast_nullable_to_non_nullable
              as int?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      approvalStatus: freezed == approvalStatus
          ? _value.approvalStatus
          : approvalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      termsAndConditions: freezed == termsAndConditions
          ? _value._termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int?,
      vendor: freezed == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as Vendor?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isExpired: freezed == isExpired
          ? _value.isExpired
          : isExpired // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      usagePercentage: freezed == usagePercentage
          ? _value.usagePercentage
          : usagePercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingUses: freezed == remainingUses
          ? _value.remainingUses
          : remainingUses // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CouponCardDataImpl implements _CouponCardData {
  const _$CouponCardDataImpl(
      {this.id,
      this.title,
      @JsonKey(name: 'image_url') this.imagePath,
      this.code,
      this.description,
      this.color,
      @JsonKey(name: 'discount_type') this.discountType,
      @JsonKey(name: 'discount_value') this.discountValue,
      @JsonKey(name: 'min_amount') this.minAmount,
      @JsonKey(name: 'max_discount_amount') this.maxDiscountAmount,
      @JsonKey(name: 'max_uses') this.maxUses,
      @JsonKey(name: 'current_uses') this.currentUses,
      @JsonKey(name: 'valid_from') this.validFrom,
      @JsonKey(name: 'valid_until') this.validUntil,
      this.status,
      @JsonKey(name: 'approval_status') this.approvalStatus,
      @JsonKey(name: 'admin_notes') this.adminNotes,
      @JsonKey(name: 'terms_and_conditions')
      final List<String>? termsAndConditions,
      @JsonKey(name: 'vendor_id') this.vendorId,
      this.vendor,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'is_expired') this.isExpired,
      @JsonKey(name: 'is_active') this.isActive,
      @JsonKey(name: 'usage_percentage') this.usagePercentage,
      @JsonKey(name: 'remaining_uses') this.remainingUses})
      : _termsAndConditions = termsAndConditions;

  factory _$CouponCardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CouponCardDataImplFromJson(json);

  @override
  final int? id;
  @override
  final String? title;
  @override
  @JsonKey(name: 'image_url')
  final String? imagePath;
  @override
  final String? code;
  @override
  final String? description;
  @override
  final String? color;
  @override
  @JsonKey(name: 'discount_type')
  final String? discountType;
  @override
  @JsonKey(name: 'discount_value')
  final String? discountValue;
  @override
  @JsonKey(name: 'min_amount')
  final String? minAmount;
  @override
  @JsonKey(name: 'max_discount_amount')
  final String? maxDiscountAmount;
  @override
  @JsonKey(name: 'max_uses')
  final String? maxUses;
  @override
  @JsonKey(name: 'current_uses')
  final int? currentUses;
  @override
  @JsonKey(name: 'valid_from')
  final String? validFrom;
  @override
  @JsonKey(name: 'valid_until')
  final String? validUntil;
  @override
  final String? status;
  @override
  @JsonKey(name: 'approval_status')
  final String? approvalStatus;
  @override
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  final List<String>? _termsAndConditions;
  @override
  @JsonKey(name: 'terms_and_conditions')
  List<String>? get termsAndConditions {
    final value = _termsAndConditions;
    if (value == null) return null;
    if (_termsAndConditions is EqualUnmodifiableListView)
      return _termsAndConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'vendor_id')
  final int? vendorId;
  @override
  final Vendor? vendor;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  @JsonKey(name: 'is_expired')
  final bool? isExpired;
  @override
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @override
  @JsonKey(name: 'usage_percentage')
  final int? usagePercentage;
  @override
  @JsonKey(name: 'remaining_uses')
  final String? remainingUses;

  @override
  String toString() {
    return 'CouponCardData(id: $id, title: $title, imagePath: $imagePath, code: $code, description: $description, color: $color, discountType: $discountType, discountValue: $discountValue, minAmount: $minAmount, maxDiscountAmount: $maxDiscountAmount, maxUses: $maxUses, currentUses: $currentUses, validFrom: $validFrom, validUntil: $validUntil, status: $status, approvalStatus: $approvalStatus, adminNotes: $adminNotes, termsAndConditions: $termsAndConditions, vendorId: $vendorId, vendor: $vendor, createdAt: $createdAt, updatedAt: $updatedAt, isExpired: $isExpired, isActive: $isActive, usagePercentage: $usagePercentage, remainingUses: $remainingUses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CouponCardDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.discountValue, discountValue) ||
                other.discountValue == discountValue) &&
            (identical(other.minAmount, minAmount) ||
                other.minAmount == minAmount) &&
            (identical(other.maxDiscountAmount, maxDiscountAmount) ||
                other.maxDiscountAmount == maxDiscountAmount) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.currentUses, currentUses) ||
                other.currentUses == currentUses) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            const DeepCollectionEquality()
                .equals(other._termsAndConditions, _termsAndConditions) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isExpired, isExpired) ||
                other.isExpired == isExpired) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.usagePercentage, usagePercentage) ||
                other.usagePercentage == usagePercentage) &&
            (identical(other.remainingUses, remainingUses) ||
                other.remainingUses == remainingUses));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        imagePath,
        code,
        description,
        color,
        discountType,
        discountValue,
        minAmount,
        maxDiscountAmount,
        maxUses,
        currentUses,
        validFrom,
        validUntil,
        status,
        approvalStatus,
        adminNotes,
        const DeepCollectionEquality().hash(_termsAndConditions),
        vendorId,
        vendor,
        createdAt,
        updatedAt,
        isExpired,
        isActive,
        usagePercentage,
        remainingUses
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CouponCardDataImplCopyWith<_$CouponCardDataImpl> get copyWith =>
      __$$CouponCardDataImplCopyWithImpl<_$CouponCardDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CouponCardDataImplToJson(
      this,
    );
  }
}

abstract class _CouponCardData implements CouponCardData {
  const factory _CouponCardData(
          {final int? id,
          final String? title,
          @JsonKey(name: 'image_url') final String? imagePath,
          final String? code,
          final String? description,
          final String? color,
          @JsonKey(name: 'discount_type') final String? discountType,
          @JsonKey(name: 'discount_value') final String? discountValue,
          @JsonKey(name: 'min_amount') final String? minAmount,
          @JsonKey(name: 'max_discount_amount') final String? maxDiscountAmount,
          @JsonKey(name: 'max_uses') final String? maxUses,
          @JsonKey(name: 'current_uses') final int? currentUses,
          @JsonKey(name: 'valid_from') final String? validFrom,
          @JsonKey(name: 'valid_until') final String? validUntil,
          final String? status,
          @JsonKey(name: 'approval_status') final String? approvalStatus,
          @JsonKey(name: 'admin_notes') final String? adminNotes,
          @JsonKey(name: 'terms_and_conditions')
          final List<String>? termsAndConditions,
          @JsonKey(name: 'vendor_id') final int? vendorId,
          final Vendor? vendor,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt,
          @JsonKey(name: 'is_expired') final bool? isExpired,
          @JsonKey(name: 'is_active') final bool? isActive,
          @JsonKey(name: 'usage_percentage') final int? usagePercentage,
          @JsonKey(name: 'remaining_uses') final String? remainingUses}) =
      _$CouponCardDataImpl;

  factory _CouponCardData.fromJson(Map<String, dynamic> json) =
      _$CouponCardDataImpl.fromJson;

  @override
  int? get id;
  @override
  String? get title;
  @override
  @JsonKey(name: 'image_url')
  String? get imagePath;
  @override
  String? get code;
  @override
  String? get description;
  @override
  String? get color;
  @override
  @JsonKey(name: 'discount_type')
  String? get discountType;
  @override
  @JsonKey(name: 'discount_value')
  String? get discountValue;
  @override
  @JsonKey(name: 'min_amount')
  String? get minAmount;
  @override
  @JsonKey(name: 'max_discount_amount')
  String? get maxDiscountAmount;
  @override
  @JsonKey(name: 'max_uses')
  String? get maxUses;
  @override
  @JsonKey(name: 'current_uses')
  int? get currentUses;
  @override
  @JsonKey(name: 'valid_from')
  String? get validFrom;
  @override
  @JsonKey(name: 'valid_until')
  String? get validUntil;
  @override
  String? get status;
  @override
  @JsonKey(name: 'approval_status')
  String? get approvalStatus;
  @override
  @JsonKey(name: 'admin_notes')
  String? get adminNotes;
  @override
  @JsonKey(name: 'terms_and_conditions')
  List<String>? get termsAndConditions;
  @override
  @JsonKey(name: 'vendor_id')
  int? get vendorId;
  @override
  Vendor? get vendor;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(name: 'is_expired')
  bool? get isExpired;
  @override
  @JsonKey(name: 'is_active')
  bool? get isActive;
  @override
  @JsonKey(name: 'usage_percentage')
  int? get usagePercentage;
  @override
  @JsonKey(name: 'remaining_uses')
  String? get remainingUses;
  @override
  @JsonKey(ignore: true)
  _$$CouponCardDataImplCopyWith<_$CouponCardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return _Vendor.fromJson(json);
}

/// @nodoc
mixin _$Vendor {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_info')
  String? get companyInfo => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VendorCopyWith<Vendor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorCopyWith<$Res> {
  factory $VendorCopyWith(Vendor value, $Res Function(Vendor) then) =
      _$VendorCopyWithImpl<$Res, Vendor>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'company_info') String? companyInfo,
      String? status,
      User? user});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$VendorCopyWithImpl<$Res, $Val extends Vendor>
    implements $VendorCopyWith<$Res> {
  _$VendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? companyInfo = freezed,
    Object? status = freezed,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      companyInfo: freezed == companyInfo
          ? _value.companyInfo
          : companyInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VendorImplCopyWith<$Res> implements $VendorCopyWith<$Res> {
  factory _$$VendorImplCopyWith(
          _$VendorImpl value, $Res Function(_$VendorImpl) then) =
      __$$VendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'company_info') String? companyInfo,
      String? status,
      User? user});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$VendorImplCopyWithImpl<$Res>
    extends _$VendorCopyWithImpl<$Res, _$VendorImpl>
    implements _$$VendorImplCopyWith<$Res> {
  __$$VendorImplCopyWithImpl(
      _$VendorImpl _value, $Res Function(_$VendorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? companyInfo = freezed,
    Object? status = freezed,
    Object? user = freezed,
  }) {
    return _then(_$VendorImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      companyInfo: freezed == companyInfo
          ? _value.companyInfo
          : companyInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorImpl implements _Vendor {
  const _$VendorImpl(
      {this.id,
      @JsonKey(name: 'company_info') this.companyInfo,
      this.status,
      this.user});

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'company_info')
  final String? companyInfo;
  @override
  final String? status;
  @override
  final User? user;

  @override
  String toString() {
    return 'Vendor(id: $id, companyInfo: $companyInfo, status: $status, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyInfo, companyInfo) ||
                other.companyInfo == companyInfo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, companyInfo, status, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      __$$VendorImplCopyWithImpl<_$VendorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorImplToJson(
      this,
    );
  }
}

abstract class _Vendor implements Vendor {
  const factory _Vendor(
      {final int? id,
      @JsonKey(name: 'company_info') final String? companyInfo,
      final String? status,
      final User? user}) = _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'company_info')
  String? get companyInfo;
  @override
  String? get status;
  @override
  User? get user;
  @override
  @JsonKey(ignore: true)
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({int? id, String? name, String? email, String? phone});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? name, String? email, String? phone});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_$UserImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({this.id, this.name, this.email, this.phone});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? phone;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, phone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {final int? id,
      final String? name,
      final String? email,
      final String? phone}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VendorInfo _$VendorInfoFromJson(Map<String, dynamic> json) {
  return _VendorInfo.fromJson(json);
}

/// @nodoc
mixin _$VendorInfo {
  @JsonKey(name: 'vendor_id')
  String? get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_coupons')
  int? get totalCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_coupons')
  int? get activeCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_coupons')
  int? get pendingCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'approved_coupons')
  int? get approvedCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejected_coupons')
  int? get rejectedCoupons => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_coupons')
  int? get expiredCoupons => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VendorInfoCopyWith<VendorInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorInfoCopyWith<$Res> {
  factory $VendorInfoCopyWith(
          VendorInfo value, $Res Function(VendorInfo) then) =
      _$VendorInfoCopyWithImpl<$Res, VendorInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'vendor_id') String? vendorId,
      @JsonKey(name: 'total_coupons') int? totalCoupons,
      @JsonKey(name: 'active_coupons') int? activeCoupons,
      @JsonKey(name: 'pending_coupons') int? pendingCoupons,
      @JsonKey(name: 'approved_coupons') int? approvedCoupons,
      @JsonKey(name: 'rejected_coupons') int? rejectedCoupons,
      @JsonKey(name: 'expired_coupons') int? expiredCoupons});
}

/// @nodoc
class _$VendorInfoCopyWithImpl<$Res, $Val extends VendorInfo>
    implements $VendorInfoCopyWith<$Res> {
  _$VendorInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = freezed,
    Object? totalCoupons = freezed,
    Object? activeCoupons = freezed,
    Object? pendingCoupons = freezed,
    Object? approvedCoupons = freezed,
    Object? rejectedCoupons = freezed,
    Object? expiredCoupons = freezed,
  }) {
    return _then(_value.copyWith(
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupons: freezed == totalCoupons
          ? _value.totalCoupons
          : totalCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      activeCoupons: freezed == activeCoupons
          ? _value.activeCoupons
          : activeCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      pendingCoupons: freezed == pendingCoupons
          ? _value.pendingCoupons
          : pendingCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      approvedCoupons: freezed == approvedCoupons
          ? _value.approvedCoupons
          : approvedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      rejectedCoupons: freezed == rejectedCoupons
          ? _value.rejectedCoupons
          : rejectedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      expiredCoupons: freezed == expiredCoupons
          ? _value.expiredCoupons
          : expiredCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VendorInfoImplCopyWith<$Res>
    implements $VendorInfoCopyWith<$Res> {
  factory _$$VendorInfoImplCopyWith(
          _$VendorInfoImpl value, $Res Function(_$VendorInfoImpl) then) =
      __$$VendorInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'vendor_id') String? vendorId,
      @JsonKey(name: 'total_coupons') int? totalCoupons,
      @JsonKey(name: 'active_coupons') int? activeCoupons,
      @JsonKey(name: 'pending_coupons') int? pendingCoupons,
      @JsonKey(name: 'approved_coupons') int? approvedCoupons,
      @JsonKey(name: 'rejected_coupons') int? rejectedCoupons,
      @JsonKey(name: 'expired_coupons') int? expiredCoupons});
}

/// @nodoc
class __$$VendorInfoImplCopyWithImpl<$Res>
    extends _$VendorInfoCopyWithImpl<$Res, _$VendorInfoImpl>
    implements _$$VendorInfoImplCopyWith<$Res> {
  __$$VendorInfoImplCopyWithImpl(
      _$VendorInfoImpl _value, $Res Function(_$VendorInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = freezed,
    Object? totalCoupons = freezed,
    Object? activeCoupons = freezed,
    Object? pendingCoupons = freezed,
    Object? approvedCoupons = freezed,
    Object? rejectedCoupons = freezed,
    Object? expiredCoupons = freezed,
  }) {
    return _then(_$VendorInfoImpl(
      vendorId: freezed == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalCoupons: freezed == totalCoupons
          ? _value.totalCoupons
          : totalCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      activeCoupons: freezed == activeCoupons
          ? _value.activeCoupons
          : activeCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      pendingCoupons: freezed == pendingCoupons
          ? _value.pendingCoupons
          : pendingCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      approvedCoupons: freezed == approvedCoupons
          ? _value.approvedCoupons
          : approvedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      rejectedCoupons: freezed == rejectedCoupons
          ? _value.rejectedCoupons
          : rejectedCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
      expiredCoupons: freezed == expiredCoupons
          ? _value.expiredCoupons
          : expiredCoupons // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorInfoImpl implements _VendorInfo {
  const _$VendorInfoImpl(
      {@JsonKey(name: 'vendor_id') this.vendorId,
      @JsonKey(name: 'total_coupons') this.totalCoupons,
      @JsonKey(name: 'active_coupons') this.activeCoupons,
      @JsonKey(name: 'pending_coupons') this.pendingCoupons,
      @JsonKey(name: 'approved_coupons') this.approvedCoupons,
      @JsonKey(name: 'rejected_coupons') this.rejectedCoupons,
      @JsonKey(name: 'expired_coupons') this.expiredCoupons});

  factory _$VendorInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorInfoImplFromJson(json);

  @override
  @JsonKey(name: 'vendor_id')
  final String? vendorId;
  @override
  @JsonKey(name: 'total_coupons')
  final int? totalCoupons;
  @override
  @JsonKey(name: 'active_coupons')
  final int? activeCoupons;
  @override
  @JsonKey(name: 'pending_coupons')
  final int? pendingCoupons;
  @override
  @JsonKey(name: 'approved_coupons')
  final int? approvedCoupons;
  @override
  @JsonKey(name: 'rejected_coupons')
  final int? rejectedCoupons;
  @override
  @JsonKey(name: 'expired_coupons')
  final int? expiredCoupons;

  @override
  String toString() {
    return 'VendorInfo(vendorId: $vendorId, totalCoupons: $totalCoupons, activeCoupons: $activeCoupons, pendingCoupons: $pendingCoupons, approvedCoupons: $approvedCoupons, rejectedCoupons: $rejectedCoupons, expiredCoupons: $expiredCoupons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorInfoImpl &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.totalCoupons, totalCoupons) ||
                other.totalCoupons == totalCoupons) &&
            (identical(other.activeCoupons, activeCoupons) ||
                other.activeCoupons == activeCoupons) &&
            (identical(other.pendingCoupons, pendingCoupons) ||
                other.pendingCoupons == pendingCoupons) &&
            (identical(other.approvedCoupons, approvedCoupons) ||
                other.approvedCoupons == approvedCoupons) &&
            (identical(other.rejectedCoupons, rejectedCoupons) ||
                other.rejectedCoupons == rejectedCoupons) &&
            (identical(other.expiredCoupons, expiredCoupons) ||
                other.expiredCoupons == expiredCoupons));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      vendorId,
      totalCoupons,
      activeCoupons,
      pendingCoupons,
      approvedCoupons,
      rejectedCoupons,
      expiredCoupons);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorInfoImplCopyWith<_$VendorInfoImpl> get copyWith =>
      __$$VendorInfoImplCopyWithImpl<_$VendorInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorInfoImplToJson(
      this,
    );
  }
}

abstract class _VendorInfo implements VendorInfo {
  const factory _VendorInfo(
          {@JsonKey(name: 'vendor_id') final String? vendorId,
          @JsonKey(name: 'total_coupons') final int? totalCoupons,
          @JsonKey(name: 'active_coupons') final int? activeCoupons,
          @JsonKey(name: 'pending_coupons') final int? pendingCoupons,
          @JsonKey(name: 'approved_coupons') final int? approvedCoupons,
          @JsonKey(name: 'rejected_coupons') final int? rejectedCoupons,
          @JsonKey(name: 'expired_coupons') final int? expiredCoupons}) =
      _$VendorInfoImpl;

  factory _VendorInfo.fromJson(Map<String, dynamic> json) =
      _$VendorInfoImpl.fromJson;

  @override
  @JsonKey(name: 'vendor_id')
  String? get vendorId;
  @override
  @JsonKey(name: 'total_coupons')
  int? get totalCoupons;
  @override
  @JsonKey(name: 'active_coupons')
  int? get activeCoupons;
  @override
  @JsonKey(name: 'pending_coupons')
  int? get pendingCoupons;
  @override
  @JsonKey(name: 'approved_coupons')
  int? get approvedCoupons;
  @override
  @JsonKey(name: 'rejected_coupons')
  int? get rejectedCoupons;
  @override
  @JsonKey(name: 'expired_coupons')
  int? get expiredCoupons;
  @override
  @JsonKey(ignore: true)
  _$$VendorInfoImplCopyWith<_$VendorInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
