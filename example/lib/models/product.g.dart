// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ProductImpl',
      json,
      ($checkedConvert) {
        final val = _$ProductImpl(
          productId: $checkedConvert('product_id', (v) => (v as num).toInt()),
          name: $checkedConvert('name', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'productId': 'product_id'},
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
    };
