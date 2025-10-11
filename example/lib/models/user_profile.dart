import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:example/models/product.dart'; // 注意这里的 import 路径

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';
part 'user_profile.schema.g.dart';

@freezed
@generateSchema
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @JsonKey(name: 'user_id') required int userId,
    required String name,
    @JsonKey(name: 'is_active') required bool isActive,
    required List<String> tags,
    required Map<String, int> permissions,
    required Product mainProduct,
    required Map<String, String> metadata,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}