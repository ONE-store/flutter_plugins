// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_enum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$ProductTypeEnumMap = {
  ProductType.inapp: 'inapp',
  ProductType.subs: 'subscription',
  ProductType.all: 'all',
};

const _$PurchaseStateEnumMap = {
  PurchaseState.purchased: 0,
  PurchaseState.cancel: 1,
  PurchaseState.refund: 2,
};

const _$AcknowledgeStateEnumMap = {
  AcknowledgeState.notAcknowledged: 0,
  AcknowledgeState.acknowledged: 1,
};

const _$RecurringStateEnumMap = {
  RecurringState.notAutoProduct: -1,
  RecurringState.recurring: 0,
  RecurringState.cancel: 1,
};

const _$ProrationModeEnumMap = {
  ProrationMode.unknownSubscriptionUpgradeDowngradePolicy: 0,
  ProrationMode.immediateWithTimeProration: 1,
  ProrationMode.immediateAndChargeProratedPrice: 2,
  ProrationMode.immediateWithoutProration: 3,
  ProrationMode.deferred: 4,
};

const _$PurchaseResponseEnumMap = {
  PurchaseResponse.ok: 0,
  PurchaseResponse.userCanceled: 1,
  PurchaseResponse.serviceUnavailable: 2,
  PurchaseResponse.billingUnavailable: 3,
  PurchaseResponse.itemUnavailable: 4,
  PurchaseResponse.developerError: 5,
  PurchaseResponse.error: 6,
  PurchaseResponse.itemAlreadyOwned: 7,
  PurchaseResponse.itemNotOwned: 8,
  PurchaseResponse.fail: 9,
  PurchaseResponse.needLogin: 10,
  PurchaseResponse.needUpdate: 11,
  PurchaseResponse.securityError: 12,
  PurchaseResponse.blockedApp: 13,
  PurchaseResponse.notSupportSandbox: 14,
  PurchaseResponse.emergencyError: 99999,
  PurchaseResponse.dataParsing: 1001,
  PurchaseResponse.signatureVerification: 1002,
  PurchaseResponse.illegalArgument: 1003,
  PurchaseResponse.undefinedCode: 1004,
  PurchaseResponse.signatureNotValidation: 1005,
  PurchaseResponse.updateOrInstall: 1006,
  PurchaseResponse.serviceDisconnected: 1007,
  PurchaseResponse.featureNotSupported: 1008,
  PurchaseResponse.serviceTimeout: 1009,
  PurchaseResponse.clientNotEnabled: 1010,
};
