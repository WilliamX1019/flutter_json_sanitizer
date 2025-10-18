// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selling_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SellingImageImpl _$$SellingImageImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$SellingImageImpl',
      json,
      ($checkedConvert) {
        final val = _$SellingImageImpl(
          url: $checkedConvert('url', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SellingImageImplToJson(_$SellingImageImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

_$VideoImpl _$$VideoImplFromJson(Map<String, dynamic> json) => $checkedCreate(
      r'_$VideoImpl',
      json,
      ($checkedConvert) {
        final val = _$VideoImpl(
          url: $checkedConvert('url', (v) => v as String?),
          image: $checkedConvert('image', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$VideoImplToJson(_$VideoImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'image': instance.image,
    };
