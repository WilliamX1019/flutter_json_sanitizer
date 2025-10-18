// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ProductModelImpl',
      json,
      ($checkedConvert) {
        final val = _$ProductModelImpl(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          sku: $checkedConvert('sku', (v) => v as String?),
          hasOptions:
              $checkedConvert('has_options', (v) => (v as num?)?.toInt()),
          name: $checkedConvert('name', (v) => v as String?),
          shortDescription:
              $checkedConvert('short_description', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          video: $checkedConvert('video', (v) => v as String?),
          allVideo: $checkedConvert('all_video',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          videos: $checkedConvert(
              'videos',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
                  .toList()),
          smallImage: $checkedConvert('small_image', (v) => v as String?),
          thumbnailImage:
              $checkedConvert('thumbnail_image', (v) => v as String?),
          images: $checkedConvert(
              'images',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
                  .toList()),
          stockDataQty:
              $checkedConvert('stock_data_qty', (v) => (v as num?)?.toInt()),
          qtyLimit: $checkedConvert('qty_limit', (v) => (v as num?)?.toInt()),
          isInStock:
              $checkedConvert('is_in_stock', (v) => (v as num?)?.toInt()),
          redeemPoints:
              $checkedConvert('redeem_points', (v) => (v as num?)?.toInt()),
          goodsTags: $checkedConvert('goods_tags', (v) => v as String?),
          detailVideoIsShow: $checkedConvert(
              'detail_video_is_show', (v) => (v as num?)?.toInt()),
          videoAutoPlay:
              $checkedConvert('video_auto_play', (v) => (v as num?)?.toInt()),
          sellingTag: $checkedConvert('selling_tag',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          sellingImages: $checkedConvert(
              'selling_images',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => SellingImage.fromJson(e as Map<String, dynamic>))
                  .toList()),
          reviewCount:
              $checkedConvert('review_count', (v) => (v as num?)?.toInt()),
          reviewSummary: $checkedConvert('review_summary', (v) => v as String?),
          optionFooterText:
              $checkedConvert('option_footer_text', (v) => v as String?),
          originalPrice: $checkedConvert('original_price', (v) => v as String?),
          finalPrice: $checkedConvert('final_price', (v) => v as String?),
          savePrice: $checkedConvert('save_price', (v) => v as String?),
          discountPercentage:
              $checkedConvert('discount_percentage', (v) => v as String?),
          options: $checkedConvert(
              'options',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
                  .toList()),
          previewPrimeMemberCardPrice: $checkedConvert(
              'preview_prime_member_card_price', (v) => v as String?),
          hasPlus: $checkedConvert('has_plus', (v) => v as bool?),
          urlPath: $checkedConvert('url_path', (v) => v as String?),
          allOptionVariants: $checkedConvert(
              'all_option_variants',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      AllOptionVariant.fromJson(e as Map<String, dynamic>))
                  .toList()),
          frameImage: $checkedConvert('frame_image', (v) => v as String?),
          downDescription:
              $checkedConvert('down_description', (v) => v as String?),
          topDescription:
              $checkedConvert('top_description', (v) => v as String?),
          isRedeemPoint:
              $checkedConvert('is_redeem_point', (v) => (v as num?)?.toInt()),
          shareUrl: $checkedConvert('share_url', (v) => v as String?),
          isSecKill:
              $checkedConvert('is_sec_kill', (v) => (v as num?)?.toInt()),
          showQtyRate:
              $checkedConvert('show_qty_rate', (v) => (v as num?)?.toInt()),
          isWishlistsed: $checkedConvert('is_wishlistsed', (v) => v as bool?),
          isRecommendFlag:
              $checkedConvert('is_recommend_flag', (v) => v as bool?),
        );
        return val;
      },
      fieldKeyMap: const {
        'hasOptions': 'has_options',
        'shortDescription': 'short_description',
        'allVideo': 'all_video',
        'smallImage': 'small_image',
        'thumbnailImage': 'thumbnail_image',
        'stockDataQty': 'stock_data_qty',
        'qtyLimit': 'qty_limit',
        'isInStock': 'is_in_stock',
        'redeemPoints': 'redeem_points',
        'goodsTags': 'goods_tags',
        'detailVideoIsShow': 'detail_video_is_show',
        'videoAutoPlay': 'video_auto_play',
        'sellingTag': 'selling_tag',
        'sellingImages': 'selling_images',
        'reviewCount': 'review_count',
        'reviewSummary': 'review_summary',
        'optionFooterText': 'option_footer_text',
        'originalPrice': 'original_price',
        'finalPrice': 'final_price',
        'savePrice': 'save_price',
        'discountPercentage': 'discount_percentage',
        'previewPrimeMemberCardPrice': 'preview_prime_member_card_price',
        'hasPlus': 'has_plus',
        'urlPath': 'url_path',
        'allOptionVariants': 'all_option_variants',
        'frameImage': 'frame_image',
        'downDescription': 'down_description',
        'topDescription': 'top_description',
        'isRedeemPoint': 'is_redeem_point',
        'shareUrl': 'share_url',
        'isSecKill': 'is_sec_kill',
        'showQtyRate': 'show_qty_rate',
        'isWishlistsed': 'is_wishlistsed',
        'isRecommendFlag': 'is_recommend_flag'
      },
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'has_options': instance.hasOptions,
      'name': instance.name,
      'short_description': instance.shortDescription,
      'description': instance.description,
      'video': instance.video,
      'all_video': instance.allVideo,
      'videos': instance.videos,
      'small_image': instance.smallImage,
      'thumbnail_image': instance.thumbnailImage,
      'images': instance.images,
      'stock_data_qty': instance.stockDataQty,
      'qty_limit': instance.qtyLimit,
      'is_in_stock': instance.isInStock,
      'redeem_points': instance.redeemPoints,
      'goods_tags': instance.goodsTags,
      'detail_video_is_show': instance.detailVideoIsShow,
      'video_auto_play': instance.videoAutoPlay,
      'selling_tag': instance.sellingTag,
      'selling_images': instance.sellingImages,
      'review_count': instance.reviewCount,
      'review_summary': instance.reviewSummary,
      'option_footer_text': instance.optionFooterText,
      'original_price': instance.originalPrice,
      'final_price': instance.finalPrice,
      'save_price': instance.savePrice,
      'discount_percentage': instance.discountPercentage,
      'options': instance.options,
      'preview_prime_member_card_price': instance.previewPrimeMemberCardPrice,
      'has_plus': instance.hasPlus,
      'url_path': instance.urlPath,
      'all_option_variants': instance.allOptionVariants,
      'frame_image': instance.frameImage,
      'down_description': instance.downDescription,
      'top_description': instance.topDescription,
      'is_redeem_point': instance.isRedeemPoint,
      'share_url': instance.shareUrl,
      'is_sec_kill': instance.isSecKill,
      'show_qty_rate': instance.showQtyRate,
      'is_wishlistsed': instance.isWishlistsed,
      'is_recommend_flag': instance.isRecommendFlag,
    };

_$AllOptionVariantImpl _$$AllOptionVariantImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$AllOptionVariantImpl',
      json,
      ($checkedConvert) {
        final val = _$AllOptionVariantImpl(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          sortedOptionValueId:
              $checkedConvert('sorted_option_value_id', (v) => v as String?),
          optionValueImage: $checkedConvert('option_value_image', (v) => v),
          optionValueName:
              $checkedConvert('option_value_name', (v) => v as String?),
          optionVariantQty: $checkedConvert(
              'option_variant_qty', (v) => (v as num?)?.toInt()),
          originalPrice: $checkedConvert('original_price', (v) => v as String?),
          finalPrice: $checkedConvert('final_price', (v) => v as String?),
          savePrice: $checkedConvert('save_price', (v) => v as String?),
          fullSku: $checkedConvert('full_sku', (v) => v as String?),
          parentId: $checkedConvert('parent_id', (v) => (v as num?)?.toInt()),
          display: $checkedConvert('display', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'sortedOptionValueId': 'sorted_option_value_id',
        'optionValueImage': 'option_value_image',
        'optionValueName': 'option_value_name',
        'optionVariantQty': 'option_variant_qty',
        'originalPrice': 'original_price',
        'finalPrice': 'final_price',
        'savePrice': 'save_price',
        'fullSku': 'full_sku',
        'parentId': 'parent_id'
      },
    );

Map<String, dynamic> _$$AllOptionVariantImplToJson(
        _$AllOptionVariantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sorted_option_value_id': instance.sortedOptionValueId,
      'option_value_image': instance.optionValueImage,
      'option_value_name': instance.optionValueName,
      'option_variant_qty': instance.optionVariantQty,
      'original_price': instance.originalPrice,
      'final_price': instance.finalPrice,
      'save_price': instance.savePrice,
      'full_sku': instance.fullSku,
      'parent_id': instance.parentId,
      'display': instance.display,
    };

_$ImageImpl _$$ImageImplFromJson(Map<String, dynamic> json) => $checkedCreate(
      r'_$ImageImpl',
      json,
      ($checkedConvert) {
        final val = _$ImageImpl(
          url: $checkedConvert('url', (v) => v as String?),
          imgTag: $checkedConvert('img_tag', (v) => v as String?),
          altTag: $checkedConvert('alt_tag', (v) => v as String?),
          position: $checkedConvert('position', (v) => v as String?),
          utmSource: $checkedConvert('utm_source', (v) => v),
          video: $checkedConvert('video', (v) => v),
        );
        return val;
      },
      fieldKeyMap: const {
        'imgTag': 'img_tag',
        'altTag': 'alt_tag',
        'utmSource': 'utm_source'
      },
    );

Map<String, dynamic> _$$ImageImplToJson(_$ImageImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'img_tag': instance.imgTag,
      'alt_tag': instance.altTag,
      'position': instance.position,
      'utm_source': instance.utmSource,
      'video': instance.video,
    };

_$OptionImpl _$$OptionImplFromJson(Map<String, dynamic> json) => $checkedCreate(
      r'_$OptionImpl',
      json,
      ($checkedConvert) {
        final val = _$OptionImpl(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          productId: $checkedConvert('product_id', (v) => (v as num?)?.toInt()),
          optionName: $checkedConvert('option_name', (v) => v as String?),
          isRequire: $checkedConvert('is_require', (v) => (v as num?)?.toInt()),
          values: $checkedConvert(
              'values',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Value.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
      fieldKeyMap: const {
        'productId': 'product_id',
        'optionName': 'option_name',
        'isRequire': 'is_require'
      },
    );

Map<String, dynamic> _$$OptionImplToJson(_$OptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'option_name': instance.optionName,
      'is_require': instance.isRequire,
      'values': instance.values,
    };

_$ValueImpl _$$ValueImplFromJson(Map<String, dynamic> json) => $checkedCreate(
      r'_$ValueImpl',
      json,
      ($checkedConvert) {
        final val = _$ValueImpl(
          id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
          productId: $checkedConvert('product_id', (v) => (v as num?)?.toInt()),
          optionId: $checkedConvert('option_id', (v) => (v as num?)?.toInt()),
          optionValueTitle:
              $checkedConvert('option_value_title', (v) => v as String?),
          sku: $checkedConvert('sku', (v) => v as String?),
          qty: $checkedConvert('qty', (v) => (v as num?)?.toInt()),
          price: $checkedConvert('price', (v) => v as String?),
          discountIcon: $checkedConvert('discount_icon', (v) => v as String?),
          discountContent:
              $checkedConvert('discount_content', (v) => v as String?),
          isPromote: $checkedConvert('is_promote', (v) => (v as num?)?.toInt()),
          isDefault: $checkedConvert('is_default', (v) => (v as num?)?.toInt()),
          isShowGiftIcon:
              $checkedConvert('is_show_gift_icon', (v) => (v as num?)?.toInt()),
          guide: $checkedConvert('guide', (v) => v as String?),
          isRecommend: $checkedConvert('is_recommend', (v) => v as bool?),
          priceFormat: $checkedConvert('price_format', (v) => v as String?),
          sortOrderBySync: $checkedConvert(
              'sort_order_by_sync', (v) => (v as num?)?.toInt()),
          sortOrder: $checkedConvert('sort_order', (v) => (v as num?)?.toInt()),
          virtualOrder:
              $checkedConvert('virtual_order', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'productId': 'product_id',
        'optionId': 'option_id',
        'optionValueTitle': 'option_value_title',
        'discountIcon': 'discount_icon',
        'discountContent': 'discount_content',
        'isPromote': 'is_promote',
        'isDefault': 'is_default',
        'isShowGiftIcon': 'is_show_gift_icon',
        'isRecommend': 'is_recommend',
        'priceFormat': 'price_format',
        'sortOrderBySync': 'sort_order_by_sync',
        'sortOrder': 'sort_order',
        'virtualOrder': 'virtual_order'
      },
    );

Map<String, dynamic> _$$ValueImplToJson(_$ValueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'option_id': instance.optionId,
      'option_value_title': instance.optionValueTitle,
      'sku': instance.sku,
      'qty': instance.qty,
      'price': instance.price,
      'discount_icon': instance.discountIcon,
      'discount_content': instance.discountContent,
      'is_promote': instance.isPromote,
      'is_default': instance.isDefault,
      'is_show_gift_icon': instance.isShowGiftIcon,
      'guide': instance.guide,
      'is_recommend': instance.isRecommend,
      'price_format': instance.priceFormat,
      'sort_order_by_sync': instance.sortOrderBySync,
      'sort_order': instance.sortOrder,
      'virtual_order': instance.virtualOrder,
    };
