// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      userId: (json['user_id'] as num).toInt(),
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      permissions: Map<String, int>.from(json['permissions'] as Map),
      mainProduct:
          Product.fromJson(json['mainProduct'] as Map<String, dynamic>),
      metadata: Map<String, String>.from(json['metadata'] as Map),
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
