// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetail _$ProductDetailFromJson(Map json) => ProductDetail(
      productId: json['productId'] as String? ?? '',
      productType:
          const ProductTypeConverter().fromJson(json['productType'] as String?),
      title: json['title'] as String? ?? '',
      price: json['price'] as String? ?? '',
      priceCurrencyCode: json['priceCurrencyCode'] as String? ?? '',
      priceAmountMicros: json['priceAmountMicros'] as String? ?? '',
      subscriptionPeriod: json['subscriptionPeriod'] as String? ?? '',
      subscriptionPeriodUnitCode:
          json['subscriptionPeriodUnitCode'] as String? ?? '',
      freeTrialPeriod: json['freeTrialPeriod'] as String? ?? '',
      promotionPrice: json['promotionPrice'] as String? ?? '',
      promotionPriceMicros: json['promotionPriceMicros'] as String? ?? '',
      promotionUsePeriod: json['promotionUsePeriod'] as String? ?? '',
      paymentGracePeriod: json['paymentGracePeriod'] as String? ?? '',
    );

ProductDetailsResponse _$ProductDetailsResponseFromJson(Map json) =>
    ProductDetailsResponse(
      iapResult: IapResult.fromJson((json['iapResult'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      productDetailsList: (json['productDetailsList'] as List<dynamic>?)
              ?.map((e) =>
                  ProductDetail.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
