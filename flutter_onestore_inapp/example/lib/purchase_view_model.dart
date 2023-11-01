import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';

import 'config/app_config.dart';

/// 이 클래스는 PurchaseClient 클래스의 사용법을 나타냅니다.
/// '''
/// [PurchaseClientManager.initialize]
class PurchaseViewModel extends ChangeNotifier {
  static const consumableIds = ['p500', 'p510'];
  static const subscriptionIds = ['week', 'month', 'three_month'];

  final _authClient = OneStoreAuthClient();
  final PurchaseClientManager _clientManager = PurchaseClientManager.instance;

  late StreamSubscription<List<PurchaseData>> _purchaseDataStream;

  // 소비 가능한 구매 데이터
  final List<PurchaseData> _consumables = [];

  // 구매한 구독 상품
  final List<PurchaseData> _subscriptions = [];

  // UI에서 접근하는 구매 데이터
  List<PurchaseData> get consumables => _consumables;

  List<PurchaseData> get subscriptions => _subscriptions;

  // 상품의 상세 정보
  final List<ProductDetail> _products = [];

  // 상품 상세 정보에서 ProductType.inapp 인 것만 필터링된 데이터
  List<ProductDetail> get consumableProducts => _products
      .where((element) => element.productType == ProductType.inapp)
      .toList();

  // 상품 상세 정보에서 ProductType.subs 인 것만 필터링된 데이터
  List<ProductDetail> get subscriptionProducts => _products
      .where((element) => element.productType == ProductType.subs)
      .toList();

  final _logger = Logger();

  PurchaseViewModel() {
    // 최초 한 번 꼭 실행을 해야합니다.
    // publicKey는 원스토어 개발자센터에
    _clientManager.initialize(AppConfig.publicKey);

    // 구매 완료 후 Stream을 통해 데이터가 전달됩니다.
    _purchaseDataStream = _clientManager.purchasesUpdatedStream.listen(
        (List<PurchaseData> purchasesList) {
      _listenToPurchasesUpdated(purchasesList);
    }, onError: (error) {
      // 구매가 실패 되었거나 유저가 취소가 되었을 때 응답 됩니다.
      _logger.d('purchaseStream error: $error');
    }, onDone: () {
      _purchaseDataStream.cancel();
    });
  }

  /// 구매한 상품을 소비합니다.
  /// [ProductType.inapp] 타입의 상품만 사용할 수 있습니다.
  ///
  /// WARNING! 구매 후 3일 이내에 consume 또는 acknowledge 를 하지 않으면 환불됩니다.
  Future<void> consumePurchase(PurchaseData purchaseData) async {
    await _clientManager
        .consumePurchase(purchaseData: purchaseData)
        .then((iapResult) {
      _logger.d('consumePurchase response: ${iapResult.toString()}');
      // iapResult 를 통해 해당 API의 성공 여부를 판단할 수 있습니다.
      if (iapResult.isSuccess()) {
        fetchPurchases([ProductType.inapp]);
      }
    });
  }

  /// 구매한 상품을 인정합니다.
  /// [ProductType.inapp] or [ProductType.subs] 둘다 사용 가능합니다.
  ///
  /// [ProductType.inapp] 같은 경우 소비를 하지 않으면 재구매가 되지 않습니다.
  /// 구매 -> [acknowledgePurchase] -> 일정 기간이 지난 후 -> [consumePurchase] (기간제 상품처럼 활용)
  ///
  /// [ProductType.subs]는 구매 완료 후 [acknowledgePurchase] 메서드를 실행해야 합니다.
  ///
  /// WARNING! 구매 후 3일 이내에 consume 또는 acknowledge 를 하지 않으면 환불됩니다.
  Future<void> acknowledgePurchase(PurchaseData purchaseData) async {
    await _clientManager
        .acknowledgePurchase(purchaseData: purchaseData)
        .then((iapResult) {
      _logger.d('acknowledgePurchase response: ${iapResult.toString()}');
      // iapResult 를 통해 해당 API의 성공 여부를 판단할 수 있습니다.
      if (iapResult.isSuccess()) {
        fetchPurchases([ProductType.subs]);
      }
    });
  }

  /// 상품의 상세 정보를 요청합니다.
  ///
  /// 아래의 예시처럼 각각 타입별로 요청을 해도 되고
  /// [ProductType.all]을 통해 여러 타입의 상품을 한 번에 요청할 수도 있습니다.
  Future<void> fetchProductDetails() async {
    var responses = await Future.wait(<Future<ProductDetailsResponse>>[
      _clientManager.queryProductDetails(
          productIds: consumableIds, productType: ProductType.inapp),
      _clientManager.queryProductDetails(
          productIds: subscriptionIds, productType: ProductType.subs)
    ]);

    /// WARNING! 요청할 데이터가 많을 경우 한 번에 요청하게 되면 응답 지연이 발생할 수 있습니다.
    ///          그러나 요청할 데이터가 적다면 한 번에 요청하는 것이 효율적입니다.
    // var allResponse = await _clientManager.queryProductDetails(
    //     productIds: (consumableIds + subscriptionIds),
    //     productType: ProductType.all);

    _logger.d(
        'fetchProductDetails response: ${responses.first.iapResult.toString()}');
    if (responses.first.iapResult.isSuccess()) {
      final List<ProductDetail> result =
          responses.expand((element) => element.productDetailsList).toList();
      _products.clear();
      _products.addAll(result);
      notifyListeners();
    } else {
      _handleError('fetchProductDetails', responses.first.iapResult);
    }
  }

  /// 구매 내역을 조회합니다.
  /// 소비되지 않은 관리형 상품과 구독된 상품의 구매 정보를 가져옵니다.
  /// @param [types] [ProductType]
  Future<void> fetchPurchases([List<ProductType>? types]) async {
    types ??= <ProductType>[ProductType.inapp, ProductType.subs];
    for (var element in types) {
      await _clientManager
          .queryPurchases(productType: element)
          .then((response) {
        _logger.d(
            'fetchPurchases($element) response: ${response.iapResult.toString()}');
        if (response.iapResult.isSuccess()) {
          if (element == ProductType.inapp) {
            _consumables.clear();
            _consumables.addAll(response.purchasesList);
          } else if (element == ProductType.subs) {
            for (var purchaseData in response.purchasesList) {
              if (!purchaseData.isAcknowledged) {
                acknowledgePurchase(purchaseData);
              }
            }

            _subscriptions.clear();
            _subscriptions.addAll(response.purchasesList);
          }
          notifyListeners();
        } else {
          _handleError('fetchPurchases($element)', response.iapResult);
        }
      });
    }
  }

  /// 구매한 상품의 응답 데이터를 [PurchaseClientManager.purchasesUpdatedStream]으로
  /// 받아 개발사에 맞게 정리합니다.
  void _listenToPurchasesUpdated(List<PurchaseData> purchasesList) {
    _logger.d('purchaseStream success');
    if (purchasesList.isNotEmpty) {
      for (var element in purchasesList) {
        _logger.d(element.toString());
        if (consumableProducts.any((p) => p.productId == element.productId)) {
          /// [ProductType.inapp] 상품은 [consumePurchase]을 하기 위해 리스트에 보관합니다.
          _updateOrAddItem(_consumables, element);
        } else if (subscriptionProducts
            .any((p) => p.productId == element.productId)) {
          /// [ProductType.subs] 상품은 [acknowledgePurchase] 호출을 하여 확인을 해야합니다.
          acknowledgePurchase(element);
        }
      }
      notifyListeners();
    }
  }

  void _updateOrAddItem(List<PurchaseData> list, PurchaseData newItem) {
    final index =
        list.indexWhere((element) => element.productId == newItem.productId);
    if (index != -1) {
      list[index] = newItem;
    } else {
      list.add(newItem);
    }
  }

  /// 상품을 구매합니다.
  ///
  /// @param [productDetail] : 구매할 상품 데이터
  /// @param [quantity] : 상품의 수량 default: 1 (optional)
  /// @param [developerPayload] : 개발사에서 추가로 넣고 싶은 데이터
  ///        developerPayload는 개발사에서 필요한 데이터를 같이 보낼 수 있습니다.
  ///        이 데이터는 구매 완료 응답 결과에 동일하게 반환합니다.
  ///        [PurchaseData.developerPayload]
  Future<IapResult> launchPurchaseFlow(ProductDetail productDetail,
      int? quantity, String? developerPayload) async {
    return await _clientManager.launchPurchaseFlow(
        productDetail: productDetail,
        quantity: quantity,
        developerPayload: developerPayload);
  }

  /// 구독 상품의 업그레이드 또는 다운그레이드를 제공합니다.
  ///
  /// @param [productDetail] : 변경할 구독 상품 데이터
  /// @param [oldPurchaseData] : 이전 구매한 구독 상품 데이터
  /// @param [prorationMode] : 변경할 때 적용할 비례 배분 옵션
  Future<IapResult> launchUpdateSubscription(ProductDetail productDetail,
      PurchaseData oldPurchaseData, ProrationMode prorationMode) async {
    return await _clientManager.launchUpdateSubscription(
        productDetail: productDetail,
        oldPurchaseData: oldPurchaseData,
        prorationMode: prorationMode);
  }

  /// 구독 관리 메뉴로 이동합니다.
  ///
  /// PurchaseData의 유무에 따라 이동되는 화면이 달라집니다.
  ///  - null일 경우 구독 관리 메뉴 리스트 화면으로 이동합니다.
  ///  - null이 아닐 경우 구매 데이터의 상세 화면으로 이동합니다.
  ///
  /// @param [purchaseData] : 구매한 구독 상품
  Future<void> launchManageSubscription(PurchaseData? purchaseData) async {
    await _clientManager.launchManageSubscription(purchaseData);
  }

  /// 원스토어 서비스의 버전이 현재 이 SDK에서 사용할 수 있는 최소 버전이 아니거나 설치되어 있지 않는 경우
  /// [PurchaseResponse.needUpdate] 응답을 받을 수 있습니다.
  ///
  /// 해당 에러를 받았을 경우 이 메서드를 실행하여 업데이트 or 설치를 해야합니다.
  Future<void> launchUpdateOfInstall() async {
    await _clientManager.launchUpdateOrInstall().then((iapResult) {
      if (iapResult.isSuccess()) {
        fetchPurchases();
        fetchProductDetails();
      }
    });
  }

  void _handleError(String tag, IapResult iapResult) {
    _logger.d('[$tag]: $iapResult');
    switch (iapResult.responseCode) {
      case PurchaseResponse.needUpdate:
        launchUpdateOfInstall();
        break;
      case PurchaseResponse.needLogin:
        launchSignInFlow().then((signInResult) {
          if (signInResult.isSuccess()) {
            fetchProductDetails();
            fetchPurchases();
          }
        });
        break;
      default:
        break;
    }
  }

  /// 원스토어의 모든 서비스는 인증 기반이며 앱 구동시 최초에 [OneStoreAuthClient] 통해 인증 해야합니다.
  /// 토큰 만료 등에 따라 구매 API 사용시 [PurchaseResponse.needLogin] 에러가 발생할 수 있습니다.
  Future<SignInResult> launchSignInFlow() async {
    return await _authClient.launchSignInFlow();
  }

  /// 앱을 종료할 때 [PurchaseClientManager.dispose] 를 호출해 주세요.
  @override
  void dispose() {
    _purchaseDataStream.cancel();
    _clientManager.dispose();
    super.dispose();
  }
}
