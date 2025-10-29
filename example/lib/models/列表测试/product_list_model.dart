// To parse this JSON data, do
//
//     final productListModel = productListModelFromJson(jsonString);

import 'package:example/models/%E5%A4%9A%E5%B1%82%E5%B5%8C%E5%A5%97%E6%B5%8B%E8%AF%95/product_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';
// 导入来自你的包的注解
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
part 'product_list_model.freezed.dart';
part 'product_list_model.g.dart';
part 'product_list_model.schema.g.dart';
ProductListModel productListModelFromJson(String str) => ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) => json.encode(data.toJson());

@freezed
@generateSchema
class ProductListModel with _$ProductListModel {
    const factory ProductListModel({
        @JsonKey(name: "list")
        List<ProductModel>? list,
        @JsonKey(name: "paginate")
        Paginate? paginate,
    }) = _ProductListModel;

    factory ProductListModel.fromJson(Map<String, dynamic> json) => _$ProductListModelFromJson(json);
}

@freezed
@generateSchema
class Paginate with _$Paginate {
    const factory Paginate({
        @JsonKey(name: "page")
        int? page,
        @JsonKey(name: "total_page")
        int? totalPage,
        @JsonKey(name: "total")
        int? total,
        @JsonKey(name: "limit")
        int? limit,
    }) = _Paginate;

    factory Paginate.fromJson(Map<String, dynamic> json) => _$PaginateFromJson(json);
}
