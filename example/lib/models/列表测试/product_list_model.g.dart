// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductListModelImpl _$$ProductListModelImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ProductListModelImpl',
      json,
      ($checkedConvert) {
        final val = _$ProductListModelImpl(
          list: $checkedConvert(
              'list',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                  .toList()),
          paginate: $checkedConvert(
              'paginate',
              (v) => v == null
                  ? null
                  : Paginate.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ProductListModelImplToJson(
        _$ProductListModelImpl instance) =>
    <String, dynamic>{
      'list': instance.list,
      'paginate': instance.paginate,
    };

_$PaginateImpl _$$PaginateImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$PaginateImpl',
      json,
      ($checkedConvert) {
        final val = _$PaginateImpl(
          page: $checkedConvert('page', (v) => (v as num?)?.toInt()),
          totalPage: $checkedConvert('total_page', (v) => (v as num?)?.toInt()),
          total: $checkedConvert('total', (v) => (v as num?)?.toInt()),
          limit: $checkedConvert('limit', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
      fieldKeyMap: const {'totalPage': 'total_page'},
    );

Map<String, dynamic> _$$PaginateImplToJson(_$PaginateImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'total_page': instance.totalPage,
      'total': instance.total,
      'limit': instance.limit,
    };
