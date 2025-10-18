// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

const Map<String, dynamic> $ProductModelSchema = {
  'id': int,
  'sku': String,
  'has_options': int,
  'name': String,
  'short_description': String,
  'description': String,
  'video': String,
  'all_video': ListSchema(String),
  'videos': ListSchema($VideoSchema),
  'small_image': String,
  'thumbnail_image': String,
  'images': ListSchema($ImageSchema),
  'stock_data_qty': int,
  'qty_limit': int,
  'is_in_stock': int,
  'redeem_points': int,
  'goods_tags': String,
  'detail_video_is_show': int,
  'video_auto_play': int,
  'selling_tag': ListSchema(String),
  'selling_images': ListSchema($SellingImageSchema),
  'review_count': int,
  'review_summary': String,
  'option_footer_text': String,
  'original_price': String,
  'final_price': String,
  'save_price': String,
  'discount_percentage': String,
  'options': ListSchema($OptionSchema),
  'preview_prime_member_card_price': String,
  'has_plus': bool,
  'url_path': String,
  'all_option_variants': ListSchema($AllOptionVariantSchema),
  'frame_image': String,
  'down_description': String,
  'top_description': String,
  'is_redeem_point': int,
  'share_url': String,
  'is_sec_kill': int,
  'show_qty_rate': int,
  'is_wishlistsed': bool,
  'is_recommend_flag': bool,
};

const Map<String, dynamic> $AllOptionVariantSchema = {
  'id': int,
  'sorted_option_value_id': String,
  'option_value_image': dynamic,
  'option_value_name': String,
  'option_variant_qty': int,
  'original_price': String,
  'final_price': String,
  'save_price': String,
  'full_sku': String,
  'parent_id': int,
  'display': String,
};

const Map<String, dynamic> $ImageSchema = {
  'url': String,
  'img_tag': String,
  'alt_tag': String,
  'position': String,
  'utm_source': dynamic,
  'video': dynamic,
};

const Map<String, dynamic> $OptionSchema = {
  'id': int,
  'product_id': int,
  'option_name': String,
  'is_require': int,
  'values': ListSchema($ValueSchema),
};

const Map<String, dynamic> $ValueSchema = {
  'id': int,
  'product_id': int,
  'option_id': int,
  'option_value_title': String,
  'sku': String,
  'qty': int,
  'price': String,
  'discount_icon': String,
  'discount_content': String,
  'is_promote': int,
  'is_default': int,
  'is_show_gift_icon': int,
  'guide': String,
  'is_recommend': bool,
  'price_format': String,
  'sort_order_by_sync': int,
  'sort_order': int,
  'virtual_order': int,
};
