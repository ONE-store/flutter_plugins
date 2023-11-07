import 'package:flutter/material.dart';

import 'purchase_client_manager.dart';
import 'iap_enum.dart';
import 'iap_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_detail.g.dart';

/// 등록된 상품의 세부정보를 나타냅니다.
/// ['com.gaa.sdk.iap.ProductDetail'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-productdetail)
@JsonSerializable()
@ProductTypeConverter()
@immutable
class ProductDetail {
  const ProductDetail({
    required this.productId,
    required this.productType,
    required this.title,
    required this.price,
    required this.priceCurrencyCode,
    required this.priceAmountMicros,
    required this.subscriptionPeriod,
    this.subscriptionPeriodUnitCode,
    required this.freeTrialPeriod,
    required this.promotionPrice,
    required this.promotionPriceMicros,
    required this.promotionUsePeriod,
    required this.paymentGracePeriod,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> map) =>
      _$ProductDetailFromJson(map);

  /// 상품의 아이디
  @JsonKey(defaultValue: '')
  final String productId;

  /// 상품의 타입
  final ProductType productType;

  /// 상품의 이름
  @JsonKey(defaultValue: '')
  final String title;

  /// 상품의 가격
  @JsonKey(defaultValue: '')
  final String price;

  /// 가격에 대한 ISO 4217 통화 코드
  @JsonKey(defaultValue: '')
  final String priceCurrencyCode;

  /// 가격을 마이크로 단위로 환산. 1,000,000 마이크로 단위는 통화의 한 단위와 같습니다.
  @JsonKey(defaultValue: '')
  final String priceAmountMicros;

  /// 구독 기간 단위 코드
  @JsonKey(defaultValue: '')
  final String? subscriptionPeriodUnitCode;

  /// 구독 기간
  @JsonKey(defaultValue: '')
  final String subscriptionPeriod;

  /// 무료 이용 기간
  @JsonKey(defaultValue: '')
  final String freeTrialPeriod;

  /// 프로모션 가격
  @JsonKey(defaultValue: '')
  final String promotionPrice;

  /// 프로모션 가격을 마이크로 단위로 환산. 1,000,000 마이크로 단위는 통화의 한 단위와 같습니다.
  @JsonKey(defaultValue: '')
  final String promotionPriceMicros;

  /// 프로모션 적용 회차
  @JsonKey(defaultValue: '')
  final String promotionUsePeriod;

  /// 결제 유예기간(일단위)
  @JsonKey(defaultValue: '')
  final String paymentGracePeriod;

  @override
  String toString() {
    return 'ProductDetail(productId=$productId, productType=$productType, '
        'title=$title, price=$price, priceCurrencyCode=$priceCurrencyCode, '
        'priceAmountMicros=$priceAmountMicros, '
        'subscriptionPeriodUnitCode=$subscriptionPeriodUnitCode, '
        'subscriptionPeriod=$subscriptionPeriod, '
        'freeTrialPeriod=$freeTrialPeriod, promotionPrice=$promotionPrice, '
        'promotionPriceMicros=$promotionPriceMicros, '
        'promotionUsePeriod=$promotionUsePeriod, '
        'paymentGracePeriod=$paymentGracePeriod)';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;

    return other is ProductDetail &&
        other.productId == productId &&
        other.productType == productType &&
        other.title == title &&
        other.price == price &&
        other.priceCurrencyCode == priceCurrencyCode &&
        other.priceAmountMicros == priceAmountMicros;
  }

  @override
  int get hashCode => Object.hash(productId, productType, title, price,
      priceCurrencyCode, priceAmountMicros);
}

@JsonSerializable()
@immutable
class ProductDetailsResponse implements HasPurchaseResponse {
  const ProductDetailsResponse(
      {required this.iapResult, required this.productDetailsList});

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> map) =>
      _$ProductDetailsResponseFromJson(map);

  final IapResult iapResult;

  @JsonKey(defaultValue: <ProductDetail>[])
  final List<ProductDetail> productDetailsList;

  @override
  PurchaseResponse get responseCode => iapResult.responseCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;

    return other is ProductDetailsResponse &&
        other.iapResult == iapResult &&
        other.productDetailsList == productDetailsList;
  }

  @override
  int get hashCode => Object.hash(iapResult, productDetailsList);
}
