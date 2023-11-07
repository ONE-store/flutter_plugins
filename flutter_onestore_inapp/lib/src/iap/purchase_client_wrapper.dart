import 'package:flutter/services.dart';

import '../onestore_channel.dart';
import 'iap_enum.dart';
import 'iap_result.dart';
import 'product_detail.dart';
import 'purchase_data.dart';

typedef OnServiceDisconnected = void Function();
typedef OnPurchasesUpdatedListener = void Function(
    PurchasesResultResponse result);

const String _kOnPurchasesUpdated = 'onPurchasesUpdated';
const String _kOnServiceDisconnected = 'onServiceDisconnected';

class PurchaseClient extends OneStoreChannel {
  String? _publicKey; // 'input your key'

  final Map<String, List<Function>> _callbacks = <String, List<Function>>{};

  PurchaseClient(
      String? publicKey, OnPurchasesUpdatedListener onPurchasesUpdated)
      : super('purchase') {
    _publicKey = publicKey;
    _callbacks[_kOnPurchasesUpdated] = <OnPurchasesUpdatedListener>[
      onPurchasesUpdated
    ];
    channel.setMethodCallHandler(methodCallHandler);
  }

  Future<bool> isReady() async {
    final bool? ready = await channel.invokeMethod('isReady');
    return ready ?? false;
  }

  Future<IapResult> startConnection(
      {required OnServiceDisconnected onDisconnected}) async {
    final List<Function> disconnectedCallbacks =
        _callbacks[_kOnServiceDisconnected] ??= <Function>[];
    disconnectedCallbacks.add(onDisconnected);
    return IapResult.fromJson((await channel.invokeMapMethod<String, dynamic>(
            'startConnection', {
          'publicKey': _publicKey,
          'handle': disconnectedCallbacks.length - 1
        })) ??
        <String, dynamic>{});
  }

  Future<void> endConnection() async {
    return channel.invokeMethod<void>('endConnection');
  }

  Future<ProductDetailsResponse> queryProductDetails(
      {required List<String> productIds, required ProductType type}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'productIds': productIds,
      'productType': const ProductTypeConverter().toJson(type)
    };
    return ProductDetailsResponse.fromJson(
        (await channel.invokeMapMethod<String, dynamic>(
                'queryProductDetailsAsync', arguments)) ??
            <String, dynamic>{});
  }

  Future<IapResult> launchUpdateOrInstallFlow() async {
    return IapResult.fromJson((await channel
            .invokeMapMethod<String, dynamic>('launchUpdateOrInstallFlow')) ??
        <String, dynamic>{});
  }

  Future<IapResult> consumeAsync(PurchaseData purchaseData) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'originalJson': purchaseData.originalJson,
      'signature': purchaseData.signature
    };
    return IapResult.fromJson((await channel.invokeMapMethod<String, dynamic>(
            'consumeAsync', arguments)) ??
        <String, dynamic>{});
  }

  Future<IapResult> acknowledgeAsync(PurchaseData purchaseData) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'originalJson': purchaseData.originalJson,
      'signature': purchaseData.signature
    };
    return IapResult.fromJson((await channel.invokeMapMethod<String, dynamic>(
            'acknowledgeAsync', arguments)) ??
        <String, dynamic>{});
  }

  Future<PurchasesResultResponse> queryPurchases(ProductType type) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'productType': const ProductTypeConverter().toJson(type)
    };
    return PurchasesResultResponse.fromJson(
        (await channel.invokeMapMethod<String, dynamic>(
                'queryPurchasesAsync', arguments)) ??
            <String, dynamic>{});
  }

  Future<IapResult> launchPurchaseFlow({
    required String productId,
    required ProductType productType,
    int? quantity,
    String? developerPayload,
    String? productName,
    String? gameUserId,
    bool? promotionApplicable,
    String? oldPurchaseToken,
    ProrationMode? prorationMode,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'productId': productId,
      'productType': const ProductTypeConverter().toJson(productType),
      'quantity': quantity,
      'developerPayload': developerPayload,
      'gameUserId': gameUserId,
      'promotionApplicable': promotionApplicable,
      'oldPurchaseToken': oldPurchaseToken,
      'prorationMode': const ProrationModeConverter().toJson(prorationMode ??
          ProrationMode.unknownSubscriptionUpgradeDowngradePolicy)
    };
    return IapResult.fromJson((await channel.invokeMapMethod<String, dynamic>(
            'launchPurchaseFlow', arguments)) ??
        <String, dynamic>{});
  }

  Future<void> launchManageSubscription([PurchaseData? purchaseData]) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    if (purchaseData != null) {
      arguments['originalJson'] = purchaseData.originalJson;
      arguments['signature'] = purchaseData.signature;
    }
    return channel.invokeMethod<void>('launchManageSubscription', arguments);
  }

  Future<String> getStoreInfo() async {
    return await channel
        .invokeMethod('getStoreInfoAsync')
        .then((json) => json['storeCode'] ?? '');
  }

  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case _kOnPurchasesUpdated:
        assert(_callbacks[_kOnPurchasesUpdated]!.length == 1);
        final OnPurchasesUpdatedListener onPurchasesUpdated =
            _callbacks[_kOnPurchasesUpdated]!.first
                as OnPurchasesUpdatedListener;

        onPurchasesUpdated(PurchasesResultResponse.fromJson(
            (call.arguments as Map<dynamic, dynamic>).cast<String, dynamic>()));
        break;

      case _kOnServiceDisconnected:
        final int handle =
            (call.arguments as Map<Object?, Object?>)['handle']! as int;
        final List<OnServiceDisconnected> onDisconnected =
            _callbacks[_kOnServiceDisconnected]!.cast<OnServiceDisconnected>();
        onDisconnected[handle]();
        break;
    }
  }
}
