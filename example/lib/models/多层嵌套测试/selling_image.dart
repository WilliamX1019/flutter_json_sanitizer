import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selling_image.freezed.dart';
part 'selling_image.g.dart';
part 'selling_image.schema.g.dart';


@unfreezed
@generateSchema
class SellingImage with _$SellingImage {
  factory SellingImage({
    @JsonKey(name: "url") String? url,
  }) = _SellingImage;

  factory SellingImage.fromJson(Map<String, dynamic> json) =>
      _$SellingImageFromJson(json);
}

@freezed
@generateSchema
class Video with _$Video {
  const factory Video({
    @JsonKey(name: "url") String? url,
    @JsonKey(name: "image") String? image,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}