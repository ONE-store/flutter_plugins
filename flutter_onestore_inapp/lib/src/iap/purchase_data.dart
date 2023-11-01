import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'purchase_client_manager.dart';
import 'iap_enum.dart';
import 'iap_result.dart';

part 'purchase_data.g.dart';

/// 구매한 정보를 나타내는 구조체입니다.
/// ['com.gaa.sdk.iap.PurchaseData'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchasedata)
@JsonSerializable()
@PurchaseStateConverter()
@RecurringStateConverter()
@immutable
class PurchaseData {
  const PurchaseData(
      {required this.orderId,
      required this.productId,
      required this.packageName,
      required this.purchaseTime,
      required this.purchaseToken,
      required this.purchaseState,
      required this.recurringState,
      required this.quantity,
      required this.isAcknowledged,
      this.developerPayload,
      required this.originalJson,
      required this.signature
  });

  factory PurchaseData.fromJson(Map<String, dynamic> map) =>
      _$PurchaseDataFromJson(map);

  /// 구매에 대한 주문 아이디
  @JsonKey(defaultValue: '')
  final String orderId;

  /// 구매한 인앱 상품 아이디
  @JsonKey(defaultValue: '')
  final String productId;

  /// 구매를 시작한 어플리케이션의 packageName
  @JsonKey(defaultValue: '')
  final String packageName;

  /// 구매가 성공한 시간 (milliseconds)
  @JsonKey(defaultValue: 0)
  final int purchaseTime;

  /// 구매 데이터를 고유하게 식별하는 토큰
  @JsonKey(defaultValue: '')
  final String purchaseToken;

  /// acknowledge or consume 요청 때 지정했던 개발사의 페이로드 값
  @JsonKey(defaultValue: '')
  final String? developerPayload;

  /// 구매 상태
  final PurchaseState purchaseState;

  /// 정기 결제의 상태
  final RecurringState recurringState;

  /// 상품의 수량
  @JsonKey(defaultValue: 1)
  final int quantity;

  /// 구매 확인(acknowledge)가 되었는지 여부
  @JsonKey(defaultValue: false)
  final bool isAcknowledged;

  /// JSON 형식의 원본 구매 데이터
  @JsonKey(defaultValue: '')
  final String originalJson;

  /// [originalJson] 데이터의 서명된 파일
  /// 개발사에 발급된 공개키로 [originalJson]과 [signature]의 데이트를 가지고
  /// 구매 데이터의 유효성 검사를 진행할 수 있습니다.
  @JsonKey(defaultValue: '')
  final String? signature;

  @override
  String toString() {
    var pState = const PurchaseStateConverter().toJson(purchaseState);
    var rState = const RecurringStateConverter().toJson(recurringState);
    return 'PurchaseData(orderId=$orderId, productId=$productId, '
        'packageName=$packageName, purchaseTime=$purchaseTime, '
        'purchaseToken=$purchaseToken, purchaseState=$pState, '
        'recurringState=$rState, quantity=$quantity, isAcknowledged=$isAcknowledged)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is PurchaseData &&
        other.orderId == orderId &&
        other.productId == productId &&
        other.packageName == packageName &&
        other.purchaseTime == purchaseTime &&
        other.purchaseToken == purchaseToken &&
        other.purchaseState == purchaseState &&
        other.recurringState == recurringState &&
        other.quantity == quantity &&
        other.isAcknowledged == isAcknowledged &&
        other.signature == signature &&
        other.originalJson == originalJson;
  }

  @override
  int get hashCode => Object.hash(
      orderId,
      productId,
      packageName,
      purchaseTime,
      purchaseToken,
      purchaseState,
      recurringState,
      quantity,
      isAcknowledged,
      signature,
      originalJson);
}

@JsonSerializable()
@immutable
class PurchasesResultResponse implements HasPurchaseResponse {
  const PurchasesResultResponse(
      {required this.iapResult, required this.purchasesList});

  factory PurchasesResultResponse.fromJson(Map<String, dynamic> map) =>
      _$PurchasesResultResponseFromJson(map);

  @override
  PurchaseResponse get responseCode => iapResult.responseCode;

  final IapResult iapResult;

  @JsonKey(defaultValue: <PurchaseData>[])
  final List<PurchaseData> purchasesList;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is PurchasesResultResponse &&
        other.iapResult == iapResult &&
        other.purchasesList == purchasesList;
  }

  @override
  int get hashCode => Object.hash(iapResult, purchasesList);

  @override
  String toString() {
    return 'PurchasesResultResponse($iapResult, purchasesList=$purchasesList)';
  }
}
