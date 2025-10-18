// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'package:example/models/product.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';
part 'user_profile.schema.g.dart';

UserProfile userProfileFromJson(String str) => UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

@freezed
@generateSchema
class UserProfile with _$UserProfile {
    const factory UserProfile({
        @JsonKey(name: "user_id")
        int? userId,
        @JsonKey(name: "name")
        String? name,
        @JsonKey(name: "is_active")
        bool? isActive,
        @JsonKey(name: "tags")
        List<String>? tags,
        @JsonKey(name: "permissions")
        Permissions? permissions,
        @JsonKey(name: "mainProduct")
        Product? mainProduct,
        @JsonKey(name: "metadata")
        Metadata? metadata,
    }) = _UserProfile;

    factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

// @freezed
// @generateSchema
// class MainProduct with _$MainProduct {
//     const factory MainProduct({
//         @JsonKey(name: "product_id")
//         int? productId,
//         @JsonKey(name: "name")
//         String? name,
//     }) = _MainProduct;

//     factory MainProduct.fromJson(Map<String, dynamic> json) => _$MainProductFromJson(json);
// }

@freezed
@generateSchema
class Metadata with _$Metadata {
    const factory Metadata(
      @JsonKey(name: "meta_data")
        String? metaData,
    ) = _Metadata;

    factory Metadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);
}

@freezed
@generateSchema
class Permissions with _$Permissions {
    const factory Permissions({
        @JsonKey(name: "read")
        int? read,
        @JsonKey(name: "write")
        int? write,
        @JsonKey(name: "admin")
        int? admin,
    }) = _Permissions;

    factory Permissions.fromJson(Map<String, dynamic> json) => _$PermissionsFromJson(json);
}
