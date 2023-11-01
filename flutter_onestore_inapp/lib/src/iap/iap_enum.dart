import 'package:json_annotation/json_annotation.dart';

part 'iap_enum.g.dart';

@JsonEnum()
enum ConnectionStatus { disconnected, connecting, connected }

/// 상품의 타입을 정의합니다.
/// ['PurchaseClient.ProductType'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-annotations/en-purchaseclient.producttype)
/// 상수의 자세한 설명은 링크를 참조하세요.
@JsonEnum(alwaysCreate: true)
enum ProductType {
  /// 관리형 상품. 구매후 소비를 하지 않으면 재 구매할 수 없습니다.
  @JsonValue('inapp')
  inapp,

  /// 구독 상품. 등록된 상품의 정해진 기간에 따라 자동 결제 및 연장되는 상품 타입입니다.
  @JsonValue('subscription')
  subs,

  /// WARNING! 상품 상세 조회 ['PurchaseClient.queryProductDetails()'] API에서만 사용할 수 있는 타입입니다.
  /// 상품 상세 정보를 요청할 때 한 번에 요청하기 위한 타입입니다.
  @JsonValue('all')
  all,
}

class ProductTypeConverter implements JsonConverter<ProductType, String?> {
  const ProductTypeConverter();

  @override
  ProductType fromJson(String? json) {
    if (json == null) return ProductType.inapp;

    return $enumDecode(_$ProductTypeEnumMap, json);
  }

  @override
  String toJson(ProductType object) => _$ProductTypeEnumMap[object]!;
}

/// 구매한 상품의 구매 상태를 정의합니다.
/// ['PurchaseData.PurchaseState'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-annotations/en-purchasedata.purchasestate)
/// 상수의 자세한 설명은 링크를 참조하세요.
@JsonEnum(alwaysCreate: true)
enum PurchaseState {
  @JsonValue(0)
  purchased,
  @JsonValue(1)
  cancel,
  @JsonValue(2)
  refund,
}

class PurchaseStateConverter implements JsonConverter<PurchaseState, int?> {
  const PurchaseStateConverter();

  @override
  PurchaseState fromJson(int? json) {
    if (json == null) return PurchaseState.purchased;

    return $enumDecode(_$PurchaseStateEnumMap, json);
  }

  @override
  int toJson(PurchaseState object) => _$PurchaseStateEnumMap[object]!;
}

/// 구매한 상품의 확인 값을 정의합니다.
/// [PurchaseData.isAcknowledged] 통해 확인할 수 있습니다.
/// ['PurchaseData.AcknowledgeState'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-annotations/en-purchasedata.acknowledgestate)
/// 상수의 자세한 설명은 링크를 참조하세요.
@JsonEnum(alwaysCreate: true)
enum AcknowledgeState {

  @JsonValue(0)
  notAcknowledged,

  @JsonValue(1)
  acknowledged,
}

class AcknowledgeStateConverter
    implements JsonConverter<AcknowledgeState, int?> {
  const AcknowledgeStateConverter();

  @override
  AcknowledgeState fromJson(int? json) {
    if (json == null) return AcknowledgeState.notAcknowledged;

    return $enumDecode(_$AcknowledgeStateEnumMap, json);
  }

  @override
  int toJson(AcknowledgeState object) => _$AcknowledgeStateEnumMap[object]!;
}

// @JsonEnum(alwaysCreate: true)
// enum RecurringAction {
//   @JsonValue('cancel')
//   cancel,
//   @JsonValue('reactivate')
//   reactivate,
// }
//
// class RecurringActionConverter
//     implements JsonConverter<RecurringAction, String?> {
//   const RecurringActionConverter();
//
//   @override
//   RecurringAction fromJson(String? json) {
//     if (json == null) return RecurringAction.cancel;
//
//     return $enumDecode(_$RecurringActionEnumMap, json);
//   }
//
//   @override
//   String toJson(RecurringAction object) => _$RecurringActionEnumMap[object]!;
// }

/// 구독 상품의 대한 구독 상태를 정의합니다.
/// [ProductType.subs] 경우 상태 확인이 가능합니다.
/// ['PurchaseData.RecurringState'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-annotations/en-purchasedata.recurringstate)
/// 상수의 자세한 설명은 링크를 참조하세요.
@JsonEnum(alwaysCreate: true)
enum RecurringState {
  /// 구독 상품이 아닙니다.
  @JsonValue(-1)
  notAutoProduct,

  /// 자동 결제 중
  @JsonValue(0)
  recurring,

  /// 해지 예약 중
  @JsonValue(1)
  cancel,
}

class RecurringStateConverter implements JsonConverter<RecurringState, int?> {
  const RecurringStateConverter();

  @override
  RecurringState fromJson(int? json) {
    if (json == null) return RecurringState.notAutoProduct;

    return $enumDecode(_$RecurringStateEnumMap, json);
  }

  @override
  int toJson(RecurringState object) => _$RecurringStateEnumMap[object]!;
}

/// 구독 상품의 업그레이드 또는 다운그레이드를 위한 비례 배분 모드입니다.
/// [Change the Subscription](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/subscriptions#subscriptions-changethesubscription)
/// ['PurchaseFlowParams.ProrationMode'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-annotations/en-purchaseflowparams.prorationmode)
/// 상수의 자세한 설명은 링크를 참조하세요.
@JsonEnum(alwaysCreate: true)
enum ProrationMode {
  @JsonValue(0)
  unknownSubscriptionUpgradeDowngradePolicy,
  @JsonValue(1)
  immediateWithTimeProration,
  @JsonValue(2)
  immediateAndChargeProratedPrice,
  @JsonValue(3)
  immediateWithoutProration,
  @JsonValue(4)
  deferred,
}

class ProrationModeConverter implements JsonConverter<ProrationMode, int?> {
  const ProrationModeConverter();

  @override
  ProrationMode fromJson(int? json) {
    if (json == null) {
      return ProrationMode.unknownSubscriptionUpgradeDowngradePolicy;
    }

    return $enumDecode(_$ProrationModeEnumMap, json);
  }

  @override
  int toJson(ProrationMode object) => _$ProrationModeEnumMap[object]!;
}

/// [PurchaseClient]의 API 응답 상태를 정의합니다.
/// ['PurchaseClient.ResponseCode'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-annotations/en-purchaseclient.responsecode)
/// 상수의 자세한 설명은 링크를 참조하세요.
@JsonEnum(alwaysCreate: true)
enum PurchaseResponse {
  @JsonValue(0)
  ok,
  @JsonValue(1)
  userCanceled,
  @JsonValue(2)
  serviceUnavailable,
  @JsonValue(3)
  billingUnavailable,
  @JsonValue(4)
  itemUnavailable,
  @JsonValue(5)
  developerError,
  @JsonValue(6)
  error,
  @JsonValue(7)
  itemAlreadyOwned,
  @JsonValue(8)
  itemNotOwned,
  @JsonValue(9)
  fail,
  @JsonValue(10)
  needLogin,
  @JsonValue(11)
  needUpdate,
  @JsonValue(12)
  securityError,
  @JsonValue(13)
  blockedApp,
  @JsonValue(14)
  notSupportSandbox,
  @JsonValue(99999)
  emergencyError,
  @JsonValue(1001)
  dataParsing,
  @JsonValue(1002)
  signatureVerification,
  @JsonValue(1003)
  illegalArgument,
  @JsonValue(1004)
  undefinedCode,
  @JsonValue(1005)
  signatureNotValidation,
  @JsonValue(1006)
  updateOrInstall,
  @JsonValue(1007)
  serviceDisconnected,
  @JsonValue(1008)
  featureNotSupported,
  @JsonValue(1009)
  serviceTimeout,
  @JsonValue(1010)
  clientNotEnabled,
}

class PurchaseResponseConverter implements JsonConverter<PurchaseResponse, int?> {
  const PurchaseResponseConverter();

  @override
  PurchaseResponse fromJson(int? json) {
    if (json == null) return PurchaseResponse.error;

    return $enumDecode(_$PurchaseResponseEnumMap, json);
  }

  @override
  int toJson(PurchaseResponse object) => _$PurchaseResponseEnumMap[object]!;
}
