// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$UserProfileImpl',
      json,
      ($checkedConvert) {
        final val = _$UserProfileImpl(
          userId: $checkedConvert('user_id', (v) => (v as num?)?.toInt()),
          name: $checkedConvert('name', (v) => v as String?),
          isActive: $checkedConvert('is_active', (v) => v as bool?),
          tags: $checkedConvert('tags',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          permissions: $checkedConvert(
              'permissions',
              (v) => v == null
                  ? null
                  : Permissions.fromJson(v as Map<String, dynamic>)),
          mainProduct: $checkedConvert(
              'mainProduct',
              (v) => v == null
                  ? null
                  : MainProduct.fromJson(v as Map<String, dynamic>)),
          metadata: $checkedConvert(
              'metadata',
              (v) => v == null
                  ? null
                  : Metadata.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
      fieldKeyMap: const {'userId': 'user_id', 'isActive': 'is_active'},
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
    $checkedCreate(
      r'_$MainProductImpl',
      json,
      ($checkedConvert) {
        final val = _$MainProductImpl(
          productId: $checkedConvert('product_id', (v) => (v as num?)?.toInt()),
          name: $checkedConvert('name', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'productId': 'product_id'},
    );

Map<String, dynamic> _$$MainProductImplToJson(_$MainProductImpl instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
    };

_$MetadataImpl _$$MetadataImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$MetadataImpl',
      json,
      ($checkedConvert) {
        final val = _$MetadataImpl();
        return val;
      },
    );

Map<String, dynamic> _$$MetadataImplToJson(_$MetadataImpl instance) =>
    <String, dynamic>{};

_$PermissionsImpl _$$PermissionsImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PermissionsImpl',
      json,
      ($checkedConvert) {
        final val = _$PermissionsImpl(
          read: $checkedConvert('read', (v) => (v as num?)?.toInt()),
          write: $checkedConvert('write', (v) => (v as num?)?.toInt()),
          admin: $checkedConvert('admin', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$PermissionsImplToJson(_$PermissionsImpl instance) =>
    <String, dynamic>{
      'read': instance.read,
      'write': instance.write,
      'admin': instance.admin,
    };
