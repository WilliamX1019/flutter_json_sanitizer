// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_model.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

const Map<String, dynamic> $ProductListModelSchema = {
  'list': ListSchema(
    itemType: ProductModel,
    itemSchema: $ProductModelSchema,
  ),
  'paginate': $PaginateSchema,
};

const Map<String, dynamic> $PaginateSchema = {
  'page': int,
  'total_page': int,
  'total': int,
  'limit': int,
};
