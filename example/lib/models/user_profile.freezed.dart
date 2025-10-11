// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  @JsonKey(name: "user_id")
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "is_active")
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: "tags")
  List<String>? get tags => throw _privateConstructorUsedError;
  @JsonKey(name: "permissions")
  Permissions? get permissions => throw _privateConstructorUsedError;
  @JsonKey(name: "mainProduct")
  MainProduct? get mainProduct => throw _privateConstructorUsedError;
  @JsonKey(name: "metadata")
  Metadata? get metadata => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {@JsonKey(name: "user_id") int? userId,
      @JsonKey(name: "name") String? name,
      @JsonKey(name: "is_active") bool? isActive,
      @JsonKey(name: "tags") List<String>? tags,
      @JsonKey(name: "permissions") Permissions? permissions,
      @JsonKey(name: "mainProduct") MainProduct? mainProduct,
      @JsonKey(name: "metadata") Metadata? metadata});

  $PermissionsCopyWith<$Res>? get permissions;
  $MainProductCopyWith<$Res>? get mainProduct;
  $MetadataCopyWith<$Res>? get metadata;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? name = freezed,
    Object? isActive = freezed,
    Object? tags = freezed,
    Object? permissions = freezed,
    Object? mainProduct = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      permissions: freezed == permissions
          ? _value.permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as Permissions?,
      mainProduct: freezed == mainProduct
          ? _value.mainProduct
          : mainProduct // ignore: cast_nullable_to_non_nullable
              as MainProduct?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Metadata?,
    ) as $Val);
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PermissionsCopyWith<$Res>? get permissions {
    if (_value.permissions == null) {
      return null;
    }

    return $PermissionsCopyWith<$Res>(_value.permissions!, (value) {
      return _then(_value.copyWith(permissions: value) as $Val);
    });
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MainProductCopyWith<$Res>? get mainProduct {
    if (_value.mainProduct == null) {
      return null;
    }

    return $MainProductCopyWith<$Res>(_value.mainProduct!, (value) {
      return _then(_value.copyWith(mainProduct: value) as $Val);
    });
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MetadataCopyWith<$Res>? get metadata {
    if (_value.metadata == null) {
      return null;
    }

    return $MetadataCopyWith<$Res>(_value.metadata!, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "user_id") int? userId,
      @JsonKey(name: "name") String? name,
      @JsonKey(name: "is_active") bool? isActive,
      @JsonKey(name: "tags") List<String>? tags,
      @JsonKey(name: "permissions") Permissions? permissions,
      @JsonKey(name: "mainProduct") MainProduct? mainProduct,
      @JsonKey(name: "metadata") Metadata? metadata});

  @override
  $PermissionsCopyWith<$Res>? get permissions;
  @override
  $MainProductCopyWith<$Res>? get mainProduct;
  @override
  $MetadataCopyWith<$Res>? get metadata;
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? name = freezed,
    Object? isActive = freezed,
    Object? tags = freezed,
    Object? permissions = freezed,
    Object? mainProduct = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$UserProfileImpl(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      permissions: freezed == permissions
          ? _value.permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as Permissions?,
      mainProduct: freezed == mainProduct
          ? _value.mainProduct
          : mainProduct // ignore: cast_nullable_to_non_nullable
              as MainProduct?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Metadata?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {@JsonKey(name: "user_id") this.userId,
      @JsonKey(name: "name") this.name,
      @JsonKey(name: "is_active") this.isActive,
      @JsonKey(name: "tags") final List<String>? tags,
      @JsonKey(name: "permissions") this.permissions,
      @JsonKey(name: "mainProduct") this.mainProduct,
      @JsonKey(name: "metadata") this.metadata})
      : _tags = tags;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  @JsonKey(name: "user_id")
  final int? userId;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "is_active")
  final bool? isActive;
  final List<String>? _tags;
  @override
  @JsonKey(name: "tags")
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "permissions")
  final Permissions? permissions;
  @override
  @JsonKey(name: "mainProduct")
  final MainProduct? mainProduct;
  @override
  @JsonKey(name: "metadata")
  final Metadata? metadata;

  @override
  String toString() {
    return 'UserProfile(userId: $userId, name: $name, isActive: $isActive, tags: $tags, permissions: $permissions, mainProduct: $mainProduct, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.permissions, permissions) ||
                other.permissions == permissions) &&
            (identical(other.mainProduct, mainProduct) ||
                other.mainProduct == mainProduct) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      name,
      isActive,
      const DeepCollectionEquality().hash(_tags),
      permissions,
      mainProduct,
      metadata);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {@JsonKey(name: "user_id") final int? userId,
      @JsonKey(name: "name") final String? name,
      @JsonKey(name: "is_active") final bool? isActive,
      @JsonKey(name: "tags") final List<String>? tags,
      @JsonKey(name: "permissions") final Permissions? permissions,
      @JsonKey(name: "mainProduct") final MainProduct? mainProduct,
      @JsonKey(name: "metadata") final Metadata? metadata}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  @JsonKey(name: "user_id")
  int? get userId;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "is_active")
  bool? get isActive;
  @override
  @JsonKey(name: "tags")
  List<String>? get tags;
  @override
  @JsonKey(name: "permissions")
  Permissions? get permissions;
  @override
  @JsonKey(name: "mainProduct")
  MainProduct? get mainProduct;
  @override
  @JsonKey(name: "metadata")
  Metadata? get metadata;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MainProduct _$MainProductFromJson(Map<String, dynamic> json) {
  return _MainProduct.fromJson(json);
}

/// @nodoc
mixin _$MainProduct {
  @JsonKey(name: "product_id")
  int? get productId => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this MainProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MainProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MainProductCopyWith<MainProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainProductCopyWith<$Res> {
  factory $MainProductCopyWith(
          MainProduct value, $Res Function(MainProduct) then) =
      _$MainProductCopyWithImpl<$Res, MainProduct>;
  @useResult
  $Res call(
      {@JsonKey(name: "product_id") int? productId,
      @JsonKey(name: "name") String? name});
}

/// @nodoc
class _$MainProductCopyWithImpl<$Res, $Val extends MainProduct>
    implements $MainProductCopyWith<$Res> {
  _$MainProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MainProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MainProductImplCopyWith<$Res>
    implements $MainProductCopyWith<$Res> {
  factory _$$MainProductImplCopyWith(
          _$MainProductImpl value, $Res Function(_$MainProductImpl) then) =
      __$$MainProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "product_id") int? productId,
      @JsonKey(name: "name") String? name});
}

/// @nodoc
class __$$MainProductImplCopyWithImpl<$Res>
    extends _$MainProductCopyWithImpl<$Res, _$MainProductImpl>
    implements _$$MainProductImplCopyWith<$Res> {
  __$$MainProductImplCopyWithImpl(
      _$MainProductImpl _value, $Res Function(_$MainProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of MainProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? name = freezed,
  }) {
    return _then(_$MainProductImpl(
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MainProductImpl implements _MainProduct {
  const _$MainProductImpl(
      {@JsonKey(name: "product_id") this.productId,
      @JsonKey(name: "name") this.name});

  factory _$MainProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$MainProductImplFromJson(json);

  @override
  @JsonKey(name: "product_id")
  final int? productId;
  @override
  @JsonKey(name: "name")
  final String? name;

  @override
  String toString() {
    return 'MainProduct(productId: $productId, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainProductImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, name);

  /// Create a copy of MainProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MainProductImplCopyWith<_$MainProductImpl> get copyWith =>
      __$$MainProductImplCopyWithImpl<_$MainProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MainProductImplToJson(
      this,
    );
  }
}

abstract class _MainProduct implements MainProduct {
  const factory _MainProduct(
      {@JsonKey(name: "product_id") final int? productId,
      @JsonKey(name: "name") final String? name}) = _$MainProductImpl;

  factory _MainProduct.fromJson(Map<String, dynamic> json) =
      _$MainProductImpl.fromJson;

  @override
  @JsonKey(name: "product_id")
  int? get productId;
  @override
  @JsonKey(name: "name")
  String? get name;

  /// Create a copy of MainProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MainProductImplCopyWith<_$MainProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Metadata _$MetadataFromJson(Map<String, dynamic> json) {
  return _Metadata.fromJson(json);
}

/// @nodoc
mixin _$Metadata {
  /// Serializes this Metadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetadataCopyWith<$Res> {
  factory $MetadataCopyWith(Metadata value, $Res Function(Metadata) then) =
      _$MetadataCopyWithImpl<$Res, Metadata>;
}

/// @nodoc
class _$MetadataCopyWithImpl<$Res, $Val extends Metadata>
    implements $MetadataCopyWith<$Res> {
  _$MetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$MetadataImplCopyWith<$Res> {
  factory _$$MetadataImplCopyWith(
          _$MetadataImpl value, $Res Function(_$MetadataImpl) then) =
      __$$MetadataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MetadataImplCopyWithImpl<$Res>
    extends _$MetadataCopyWithImpl<$Res, _$MetadataImpl>
    implements _$$MetadataImplCopyWith<$Res> {
  __$$MetadataImplCopyWithImpl(
      _$MetadataImpl _value, $Res Function(_$MetadataImpl) _then)
      : super(_value, _then);

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$MetadataImpl implements _Metadata {
  const _$MetadataImpl();

  factory _$MetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetadataImplFromJson(json);

  @override
  String toString() {
    return 'Metadata()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MetadataImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return _$$MetadataImplToJson(
      this,
    );
  }
}

abstract class _Metadata implements Metadata {
  const factory _Metadata() = _$MetadataImpl;

  factory _Metadata.fromJson(Map<String, dynamic> json) =
      _$MetadataImpl.fromJson;
}

Permissions _$PermissionsFromJson(Map<String, dynamic> json) {
  return _Permissions.fromJson(json);
}

/// @nodoc
mixin _$Permissions {
  @JsonKey(name: "read")
  int? get read => throw _privateConstructorUsedError;
  @JsonKey(name: "write")
  int? get write => throw _privateConstructorUsedError;
  @JsonKey(name: "admin")
  int? get admin => throw _privateConstructorUsedError;

  /// Serializes this Permissions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Permissions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionsCopyWith<Permissions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionsCopyWith<$Res> {
  factory $PermissionsCopyWith(
          Permissions value, $Res Function(Permissions) then) =
      _$PermissionsCopyWithImpl<$Res, Permissions>;
  @useResult
  $Res call(
      {@JsonKey(name: "read") int? read,
      @JsonKey(name: "write") int? write,
      @JsonKey(name: "admin") int? admin});
}

/// @nodoc
class _$PermissionsCopyWithImpl<$Res, $Val extends Permissions>
    implements $PermissionsCopyWith<$Res> {
  _$PermissionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Permissions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? read = freezed,
    Object? write = freezed,
    Object? admin = freezed,
  }) {
    return _then(_value.copyWith(
      read: freezed == read
          ? _value.read
          : read // ignore: cast_nullable_to_non_nullable
              as int?,
      write: freezed == write
          ? _value.write
          : write // ignore: cast_nullable_to_non_nullable
              as int?,
      admin: freezed == admin
          ? _value.admin
          : admin // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PermissionsImplCopyWith<$Res>
    implements $PermissionsCopyWith<$Res> {
  factory _$$PermissionsImplCopyWith(
          _$PermissionsImpl value, $Res Function(_$PermissionsImpl) then) =
      __$$PermissionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "read") int? read,
      @JsonKey(name: "write") int? write,
      @JsonKey(name: "admin") int? admin});
}

/// @nodoc
class __$$PermissionsImplCopyWithImpl<$Res>
    extends _$PermissionsCopyWithImpl<$Res, _$PermissionsImpl>
    implements _$$PermissionsImplCopyWith<$Res> {
  __$$PermissionsImplCopyWithImpl(
      _$PermissionsImpl _value, $Res Function(_$PermissionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Permissions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? read = freezed,
    Object? write = freezed,
    Object? admin = freezed,
  }) {
    return _then(_$PermissionsImpl(
      read: freezed == read
          ? _value.read
          : read // ignore: cast_nullable_to_non_nullable
              as int?,
      write: freezed == write
          ? _value.write
          : write // ignore: cast_nullable_to_non_nullable
              as int?,
      admin: freezed == admin
          ? _value.admin
          : admin // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PermissionsImpl implements _Permissions {
  const _$PermissionsImpl(
      {@JsonKey(name: "read") this.read,
      @JsonKey(name: "write") this.write,
      @JsonKey(name: "admin") this.admin});

  factory _$PermissionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PermissionsImplFromJson(json);

  @override
  @JsonKey(name: "read")
  final int? read;
  @override
  @JsonKey(name: "write")
  final int? write;
  @override
  @JsonKey(name: "admin")
  final int? admin;

  @override
  String toString() {
    return 'Permissions(read: $read, write: $write, admin: $admin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionsImpl &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.write, write) || other.write == write) &&
            (identical(other.admin, admin) || other.admin == admin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, read, write, admin);

  /// Create a copy of Permissions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionsImplCopyWith<_$PermissionsImpl> get copyWith =>
      __$$PermissionsImplCopyWithImpl<_$PermissionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PermissionsImplToJson(
      this,
    );
  }
}

abstract class _Permissions implements Permissions {
  const factory _Permissions(
      {@JsonKey(name: "read") final int? read,
      @JsonKey(name: "write") final int? write,
      @JsonKey(name: "admin") final int? admin}) = _$PermissionsImpl;

  factory _Permissions.fromJson(Map<String, dynamic> json) =
      _$PermissionsImpl.fromJson;

  @override
  @JsonKey(name: "read")
  int? get read;
  @override
  @JsonKey(name: "write")
  int? get write;
  @override
  @JsonKey(name: "admin")
  int? get admin;

  /// Create a copy of Permissions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionsImplCopyWith<_$PermissionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
