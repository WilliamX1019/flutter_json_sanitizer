// To parse this JSON data, do
//
//     final estimatedDeliveryTimeModel = estimatedDeliveryTimeModelFromJson(jsonString);

import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'selling_image.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';
part 'product_model.schema.g.dart';

@unfreezed
@generateSchema
class ProductModel with _$ProductModel {
  factory ProductModel({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "sku") String? sku,
    @JsonKey(name: "has_options") int? hasOptions,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "short_description") String? shortDescription,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "video") String? video,
    @JsonKey(name: "all_video") List<String>? allVideo,
    @JsonKey(name: "videos") List<Video>? videos,
    @JsonKey(name: "small_image") String? smallImage,
    @JsonKey(name: "thumbnail_image") String? thumbnailImage,
    @JsonKey(name: "images") List<Image>? images,
    @JsonKey(name: "stock_data_qty") int? stockDataQty,
    @JsonKey(name: "qty_limit") int? qtyLimit,
    @JsonKey(name: "is_in_stock") int? isInStock,
    @JsonKey(name: "redeem_points") int? redeemPoints,
    @JsonKey(name: "goods_tags") String? goodsTags,
    @JsonKey(name: "detail_video_is_show") int? detailVideoIsShow,
    @JsonKey(name: "video_auto_play") int? videoAutoPlay,
    @JsonKey(name: "selling_tag") List<String>? sellingTag,
    @JsonKey(name: "selling_images") List<SellingImage>? sellingImages,
    @JsonKey(name: "review_count") int? reviewCount,
    @JsonKey(name: "review_summary") String? reviewSummary,
    @JsonKey(name: "option_footer_text") String? optionFooterText,
    @JsonKey(name: "original_price") String? originalPrice,
    @JsonKey(name: "final_price") String? finalPrice,
    @JsonKey(name: "save_price") String? savePrice,
    @JsonKey(name: "discount_percentage") String? discountPercentage,
    @JsonKey(name: "options") List<Option>? options,
    @JsonKey(name: "preview_prime_member_card_price")
    String? previewPrimeMemberCardPrice,
    @JsonKey(name: "has_plus") bool? hasPlus,
    @JsonKey(name: "url_path") String? urlPath,
    @JsonKey(name: "all_option_variants")
    List<AllOptionVariant>? allOptionVariants,
    @JsonKey(name: "frame_image") String? frameImage,
    @JsonKey(name: "down_description") String? downDescription,
    @JsonKey(name: "top_description") String? topDescription,
    @JsonKey(name: "is_redeem_point") int? isRedeemPoint,
    @JsonKey(name: "share_url") String? shareUrl,
    @JsonKey(name: "is_sec_kill") int? isSecKill,
    @JsonKey(name: "show_qty_rate") int? showQtyRate,
    @JsonKey(name: "is_wishlistsed") bool? isWishlistsed,
    @JsonKey(name: "is_recommend_flag") bool? isRecommendFlag,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@unfreezed
@generateSchema
class AllOptionVariant with _$AllOptionVariant {
  factory AllOptionVariant({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "sorted_option_value_id") String? sortedOptionValueId,
    @JsonKey(name: "option_value_image") dynamic optionValueImage,
    @JsonKey(name: "option_value_name") String? optionValueName,
    @JsonKey(name: "option_variant_qty") int? optionVariantQty,
    @JsonKey(name: "original_price") String? originalPrice,
    @JsonKey(name: "final_price") String? finalPrice,
    @JsonKey(name: "save_price") String? savePrice,
    @JsonKey(name: "full_sku") String? fullSku,
    @JsonKey(name: "parent_id") int? parentId,
    @JsonKey(name: "display") String? display,
  }) = _AllOptionVariant;

  factory AllOptionVariant.fromJson(Map<String, dynamic> json) =>
      _$AllOptionVariantFromJson(json);
}

@unfreezed
@generateSchema
class Image with _$Image {
  factory Image({
    @JsonKey(name: "url") String? url,
    @JsonKey(name: "img_tag") String? imgTag,
    @JsonKey(name: "alt_tag") String? altTag,
    @JsonKey(name: "position") String? position,
    @JsonKey(name: "utm_source") dynamic utmSource,
    @JsonKey(name: "video") dynamic video,
  }) = _Image;

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}

@unfreezed
@generateSchema
class Option with _$Option {
  factory Option({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "product_id") int? productId,
    @JsonKey(name: "option_name") String? optionName,
    @JsonKey(name: "is_require") int? isRequire,
    @JsonKey(name: "values") List<Value>? values,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}

@unfreezed
@generateSchema
class Value with _$Value {
  factory Value({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "product_id") int? productId,
    @JsonKey(name: "option_id") int? optionId,
    @JsonKey(name: "option_value_title") String? optionValueTitle,
    @JsonKey(name: "sku") String? sku,
    @JsonKey(name: "qty") int? qty,
    @JsonKey(name: "price") String? price,
    @JsonKey(name: "discount_icon") String? discountIcon,
    @JsonKey(name: "discount_content") String? discountContent,
    @JsonKey(name: "is_promote") int? isPromote,
    @JsonKey(name: "is_default") int? isDefault,
    @JsonKey(name: "is_show_gift_icon") int? isShowGiftIcon,
    @JsonKey(name: "guide") String? guide,
    @JsonKey(name: "is_recommend") bool? isRecommend,
    @JsonKey(name: "price_format") String? priceFormat,
    @JsonKey(name: "sort_order_by_sync") int? sortOrderBySync,
    @JsonKey(name: "sort_order") int? sortOrder,
    @JsonKey(name: "virtual_order") int? virtualOrder,
  }) = _Value;

  factory Value.fromJson(Map<String, dynamic> json) => _$ValueFromJson(json);
}


