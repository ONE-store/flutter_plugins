import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'iap_enum.dart';
import 'iap_result.dart';
import 'product_detail.dart';
import 'purchase_client_wrapper.dart';
import 'purchase_data.dart';

/// [PurchaseClient]의 응답 결과의 추상 클래스입니다.
abstract class HasPurchaseResponse {
  abstract final PurchaseResponse responseCode;
}

/// [PurchaseClient] 연결 및 API 요청을 관리하는 유틸리티 클래스입니다.
///
/// 사용이 용이 하도록 Singleton 방식으로 제공되며
/// 최초 한번 [initialize]를 호출해야 [PurchaseClient] 객체를 생성합니다.
///
/// 앱을 종료 하거나 더 이상 [PurchaseClient]가 필요하지 않을 경우 [dispose]를 호출합니다.
class PurchaseClientManager {
  static PurchaseClientManager? _instance;

  static PurchaseClientManager get instance => _getOrCreateInstance();

  late final PurchaseClient _client;
  Future<void>? _readyFuture;

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _isDisposed = false;
  String storeCode = '';

  final StreamController<List<PurchaseData>> _purchasesUpdatedController =
      StreamController<List<PurchaseData>>.broadcast();

  /// [PurchaseClient]에서 "onPurchasesUpdated" 이벤트를 전달 받습니다.
  /// [dispose]가 호출되면 "onDone" 이벤트가 호출됩니다.
  late final Stream<List<PurchaseData>> purchasesUpdatedStream =
      _purchasesUpdatedController.stream;

  static PurchaseClientManager _getOrCreateInstance() {
    if (_instance != null) return _instance!;

    if (!Platform.isAndroid) {
      throw PlatformException(
        code: '-1',
        message: 'Not supported platform.',
      );
    }
    _instance = PurchaseClientManager._();
    return _instance!;
  }

  PurchaseClientManager._();

  void initialize([String? publicKey]) {
    _client = PurchaseClient(publicKey, _onPurchasesUpdated);
  }

  void _onPurchasesUpdated(PurchasesResultResponse response) {
    if (_isDisposed) return;
    if (response.iapResult.isSuccess()) {
      _purchasesUpdatedController.add(response.purchasesList);
    } else {
      _purchasesUpdatedController.addError(response.iapResult);
    }
  }

  /// [PurchaseClient]에 대한 연결을 종료합니다.
  /// [PurchaseClient]가 더 이상 필요하지 않을 경우 호출합니다.
  ///
  /// [dispose]를 호출한 경우:
  /// - 더 이상 연결을 시도하지 않습니다.
  /// - [purchasesUpdatedStream]이 닫힙니다.
  void dispose() {
    _assertNotDisposed();
    _isDisposed = true;
    _client.endConnection();
    _purchasesUpdatedController.close();
  }

  /// API 호출 시 연결이 끊어졌을 경우 재 연결을 시도하여 요청한 API를 끝까지 수행합니다.
  Future<R> _execute<R extends HasPurchaseResponse>(
      Future<R> Function(PurchaseClient client) action) async {
    _assertNotDisposed();
    await _connection();
    final R result = await action(_client);
    if (result.responseCode == PurchaseResponse.serviceDisconnected &&
        !_isDisposed) {
      await _connection();
      return _execute(action);
    } else {
      return result;
    }
  }

  /// 재연결이 필요없는 작업에 대한 처리를 수행합니다.
  Future<R> _executeNonRetryable<R>(
      Future<R> Function(PurchaseClient client) action) async {
    _assertNotDisposed();
    if (_readyFuture == null) {
      await _connection();
      return action(_client);
    } else {
      await _readyFuture;
      return action(_client);
    }
  }

  /// [dispose] 되면 아무 것도 하지 않습니다.
  /// 연결중이면 완료될 때까지 기다리고, 그렇지 않으면 새 연결을 시작합니다.
  Future<void> _connection() {
    if (_isDisposed) {
      return Future<void>.value();
    }

    if (_connectionStatus == ConnectionStatus.connecting) {
      return _readyFuture!;
    }

    _connectionStatus = ConnectionStatus.connecting;
    _readyFuture = Future<void>.sync(() async {
      await _client.startConnection(onDisconnected: () {
        _connectionStatus = ConnectionStatus.disconnected;
      }).then((iapResult) {
        if (iapResult.isSuccess()) {
          _connectionStatus = ConnectionStatus.connected;
          if (storeCode.isEmpty) {
            _client.getStoreInfo().then((value) => storeCode = value);
          }
        } else {
          // 연결 되었지만 연결 도중 문제가 발생했을 때 해당 에러코드를 전달합니다.
          _connectionStatus = ConnectionStatus.disconnected;
          throw PlatformException(
              code: const PurchaseResponseConverter()
                  .toJson(iapResult.responseCode)
                  .toString(),
              message: iapResult.message);
        }
      });
    });

    return _readyFuture!;
  }

  void _assertNotDisposed() {
    assert(
      !_isDisposed,
      'A PurchaseClientManager was used after being disposed. Once you have '
      'called dispose() on a PurchaseClientManager, it can no longer be used.',
    );
  }

  /// [PurchaseClient]의 준비 상태를 가져옵니다.
  ///
  /// ['PurchaseClient#isReady()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-isready)
  Future<bool> isReady() async {
    return _executeNonRetryable((client) => client.isReady());
  }

  /// 구매한 상품을 소비합니다.
  /// 소유한 상품만 소비할 수 있으며, 소비를 진행했던 상품의 경우 재 구매를 진행해야 합니다.
  /// 이 API는 관리형 상품([ProductType.inapp])만 호출 가능합니다.
  ///
  /// WARNING! 구매 후 3일 이내에 소비(consume) 또는 확인(acknowledge)을 하지 않으면 환불됩니다.
  ///
  /// ['PurchaseClient#consumeAsync()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-consumeasync)
  Future<IapResult> consumePurchase(
      {required PurchaseData purchaseData}) async {
    return await _execute((client) => client.consumeAsync(purchaseData));
  }

  /// 구매한 상품을 확인합니다.
  /// 이 API는 관리형 상품([ProductType.inapp])과 구독 상품([ProductType.subs]) 모두 호출 가능합니다.
  /// 특히 관리형 상품의 경우 확인(acknowledge)하고 일정 기간후에 소비(consume)을 진행하여 기간제 상품으로 활용할 수 있습니다.
  ///
  /// WARNING! 구매 후 3일 이내에 소비(consume) 또는 확인(acknowledge)을 하지 않으면 환불됩니다.
  ///
  /// ['PurchaseClient#acknowledgeAsync()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-acknowledgeasync)
  Future<IapResult> acknowledgePurchase(
      {required PurchaseData purchaseData}) async {
    return await _execute((client) => client.acknowledgeAsync(purchaseData));
  }

  /// 상품의 상세정보를 요청합니다.
  ///
  /// ['PurchaseClient#queryProductDetailsAsync()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-queryproductdetailsasync)
  Future<ProductDetailsResponse> queryProductDetails(
      {required List<String> productIds,
      required ProductType productType}) async {
    ProductDetailsResponse response;
    try {
      response = await _execute((client) => client.queryProductDetails(
          productIds: productIds, type: productType));
    } on PlatformException catch (e) {
      response = ProductDetailsResponse(
          iapResult: IapResult(
              responseCode: PurchaseResponse.error,
              message: '${e.message}(${e.code})'),
          productDetailsList: const <ProductDetail>[]);
    }
    return response;
  }

  /// 소비되지 않은 구매정보를 가져옵니다.
  ///
  /// [consumePurchase]을 요청하였을 경우 해당 상품의 구매정보는 더 이상 응답을 받지 못합니다.
  /// ['PurchaseClient#queryPurchasesAsync()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-querypurchasesasync)
  ///
  /// 소비된 구매 정보를 포함한 모든 구매 정보를 원할 경우 Server API를 통해 확인할 수 있습니다.
  /// (https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/one-store-iap-server-api-api-v7#onestoreiapserverapi-apiv7-getpurchasedetails-checkpurchasedin-appproductdetails)
  Future<PurchasesResultResponse> queryPurchases(
      {required ProductType productType}) async {
    PurchasesResultResponse response;
    try {
      response = await _execute((client) => client.queryPurchases(productType));
    } on PlatformException catch (e) {
      response = PurchasesResultResponse(
          iapResult: IapResult(
              responseCode: PurchaseResponse.error,
              message: '${e.message}(${e.code})'),
          purchasesList: const <PurchaseData>[]);
    }
    return response;
  }

  /// 입력된 [ProductDetail]상품에 대한 구매 요청을 시도합니다.
  /// [ProductDetail] 정보는 [queryProductDetails]를 통해 미리 가져 와야합니다.
  ///
  /// 이 API에서 반환 하는 [IapResult]는 구매 흐름에 대한 응답입니다.
  /// 실제 구매 요청에 대한 응답 결과는 [purchasesUpdatedStream] 통해 전달 받을 수 있습니다.
  ///
  /// ['PurchaseClient#launchPurchaseFlow()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-launchpurchaseflow)
  /// [Request a Purchase](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/implementing-one-store-iap-sdk#implementingonestoreiapsdk-requestapurchase)
  Future<IapResult> launchPurchaseFlow(
      {required ProductDetail productDetail,
      int? quantity,
      String? developerPayload}) async {
    return await _execute((client) => client.launchPurchaseFlow(
        productId: productDetail.productId,
        productType: productDetail.productType,
        quantity: quantity ?? 1,
        developerPayload: developerPayload));
  }

  /// 구매한 구독 상품을 다른 상품으로 업그레이드 또는 다운그레이드를 시도합니다.
  ///
  /// 변경할 [ProductDetail]상품과 구매한 [PurchaseData] 정보가 필수로 요구됩니다.
  /// [ProductDetail] 정보는 [queryProductDetails]를 통해 가져올 수 있습니다.
  /// [PurchaseData] 정보는 [queryPurchases]를 통해 가져올 수 있습니다.
  /// [ProrationMode]의 기본값은 [ProrationMode.immediateWithTimeProration] 입니다.
  /// [Change the Subscription](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/subscriptions#subscriptions-changethesubscription)
  ///
  /// 이 API에서 반환 하는 [IapResult]는 구매 흐름에 대한 응답입니다.
  /// 실제 구매 요청에 대한 응답 결과는 [purchasesUpdatedStream] 통해 전달 받을 수 있습니다.
  ///
  /// ['PurchaseClient#launchPurchaseFlow()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-launchpurchaseflow)
  /// [Request a Purchase](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/implementing-one-store-iap-sdk#implementingonestoreiapsdk-requestapurchase)
  Future<IapResult> launchUpdateSubscription({
    required ProductDetail productDetail,
    required PurchaseData oldPurchaseData,
    ProrationMode? prorationMode,
    String? developerPayload,
  }) async {
    return await _execute((client) => client.launchPurchaseFlow(
        productId: productDetail.productId,
        productType: productDetail.productType,
        quantity: 1,
        developerPayload: developerPayload,
        oldPurchaseToken: oldPurchaseData.purchaseToken,
        prorationMode: prorationMode));
  }

  /// 구매한 구독 상품[PurchaseData]의 정보를 가지고 해당 상품의 관리 메뉴로 이동합니다.
  /// 만약, 상품의 정보가 없다면 정기 결제 리스트 화면으로 이동합니다.
  ///
  /// ['PurchaseClient#launchManageSubscription()'](https://onestore-dev.gitbook.io/dev/v/eng/tools/tools/v21/references/en-classes/en-purchaseclient#id-en-purchaseclient-launchmanagesubscription)
  Future<void> launchManageSubscription([PurchaseData? purchaseData]) async {
    return _executeNonRetryable(
        (client) => client.launchManageSubscription(purchaseData));
  }

  /// 원스토어 서비스를 최신버전으로 설치합니다.
  /// 원스토어 서비스의 버전이 낮거나 없을 경우 [_connection]으로 연결 시도시 [PurchaseResponse.needUpdate] 응답을 받을 수 있습니다.
  /// 이 때, 이 API를 호출해야 합니다.
  Future<IapResult> launchUpdateOrInstall() async {
    return await _executeNonRetryable(
        (client) => client.launchUpdateOrInstallFlow());
  }
}
