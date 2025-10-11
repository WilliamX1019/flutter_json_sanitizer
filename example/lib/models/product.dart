import 'package:freezed_annotation/freezed_annotation.dart';
// 导入来自你的包的注解
import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

part 'product.freezed.dart';
part 'product.g.dart';
part 'product.schema.g.dart';

@freezed
@generateSchema
class Product with _$Product {
  const factory Product({
    @JsonKey(name: 'product_id') required int productId,
    required String name,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}