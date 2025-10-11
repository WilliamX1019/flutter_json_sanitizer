// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      isActive: json['is_active'] as bool?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      permissions: json['permissions'] == null
          ? null
          : Permissions.fromJson(json['permissions'] as Map<String, dynamic>),
      mainProduct: json['mainProduct'] == null
          ? null
          : MainProduct.fromJson(json['mainProduct'] as Map<String, dynamic>),
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'is_active': instance.isActive,
      'tags': instance.tags,
      'permissions': instance.permissions,
      'mainProduct': instance.mainProduct,
      'metadata': instance.metadata,
    };

_$MainProductImpl _$$MainProductImplFromJson(Map<String, dynamic> json) =>
    _$MainProductImpl(
      productId: (json['product_id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$MainProductImplToJson(_$MainProductImpl instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
    };

_$MetadataImpl _$$MetadataImplFromJson(Map<String, dynamic> json) =>
    _$MetadataImpl();

Map<String, dynamic> _$$MetadataImplToJson(_$MetadataImpl instance) =>
    <String, dynamic>{};

_$PermissionsImpl _$$PermissionsImplFromJson(Map<String, dynamic> json) =>
    _$PermissionsImpl(
      read: (json['read'] as num?)?.toInt(),
      write: (json['write'] as num?)?.toInt(),
      admin: (json['admin'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PermissionsImplToJson(_$PermissionsImpl instance) =>
    <String, dynamic>{
      'read': instance.read,
      'write': instance.write,
      'admin': instance.admin,
    };
