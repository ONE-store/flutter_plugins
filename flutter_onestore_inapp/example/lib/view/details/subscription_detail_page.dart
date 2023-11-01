import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/onestore_in_app_wrappers.dart';
import 'package:provider/provider.dart';

import '../../purchase_view_model.dart';
import '../../res/colors.dart';
import '../../res/theme.dart';
import '../widget/custom_view_pager.dart';
import '../widget/custom_widget.dart';

class SubscriptionDetailPage extends StatefulWidget {
  final String productId;

  const SubscriptionDetailPage({super.key, required this.productId});

  @override
  State<StatefulWidget> createState() => _SubscriptionDetailState();
}

class _SubscriptionDetailState extends State<SubscriptionDetailPage> {
  late final PurchaseViewModel _viewModel =
      Provider.of<PurchaseViewModel>(context, listen: false);

  ProrationMode _selectedProrationMode =
      ProrationMode.immediateWithTimeProration;
  late String productId;

  @override
  void initState() {
    super.initState();
    productId = widget.productId;
  }

  @override
  Widget build(BuildContext context) {
    final products = _viewModel.subscriptionProducts;
    final purchases = _viewModel.subscriptions;

    final selectedProduct =
        products.singleWhere((element) => element.productId == productId);
    final selectedPurchase =
        purchases.singleWhere((element) => element.productId == productId);

    return Scaffold(
        appBar: AppBar(
          title: Text(selectedProduct.title),
          backgroundColor: AppColors.primaryColor,
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
            padding: const EdgeInsets.all(10),
            // 스크롤뷰
            child: SingleChildScrollView(
              child: Column(children: [
                _buildSubscriptionInfo(selectedProduct),
                _buildRowButtons(selectedPurchase),
                _buildAnotherSubscription(selectedPurchase),
                _buildOptionButtons()
              ]),
            )));
  }

  /// 현재 구독 중인 상품에 대한 정보
  _buildSubscriptionInfo(ProductDetail item) {
    final items = <Pair<String>>[
      Pair(
          key: 'Subscription period',
          value:
              '${item.subscriptionPeriod} (${item.subscriptionPeriodUnitCode})'),
      Pair(key: 'Free period of use', value: item.freeTrialPeriod),
      Pair(key: 'Price', value: '${item.priceCurrencyCode} ${item.price}'),
      Pair(
          key: 'Promotional price',
          value: '${item.priceCurrencyCode} ${item.promotionPrice}'),
    ];

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(items[index].key),
                      Text(items[index].value),
                    ]),
              );
            }),
      ),
    );
  }

  // 구독 관리 메뉴로 이동
  _buildRowButtons(PurchaseData item) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: buildButton(
            title: 'Open the Subscription Menu',
            action: () {
              _viewModel.launchManageSubscription(item);
            }));
  }

  // 현재 구독한 상품 이외의 상품 노출
  _buildAnotherSubscription(PurchaseData oldPurchaseData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: CustomViewPager(
        title: 'Upgrade or downgrade products',
        type: Type.buy,
        items: _getDifferenceSubscriptions(),
        onPressed: (item) {
          _viewModel.launchUpdateSubscription(
              item, oldPurchaseData, _selectedProrationMode);
        },
      ),
    );
  }

  /// 구매한 구독 상품 이외의 상세 정보를 바탕으로 PagerItem을 만듬.
  List<PageItem<ProductDetail>> _getDifferenceSubscriptions() {
    return _viewModel.subscriptionProducts
        .where((element) =>
            _viewModel.subscriptions
                .indexWhere((item) => item.productId == element.productId) ==
            -1)
        .map((e) => PageItem<ProductDetail>(
            title: e.title,
            description:
                '${e.subscriptionPeriod.toString()} '
                '(${e.subscriptionPeriodUnitCode})',
            data: e))
        .toList();
  }

  // 비례 배분 옵션
  _buildOptionButtons() {
    final items = <Pair<ProrationMode>>[
      Pair(
          key: 'IMMEDIATE_WITH_TIME_PRORATION',
          value: ProrationMode.immediateWithTimeProration),
      Pair(
          key: 'IMMEDIATE_AND_CHARGE_PRORATED_PRICE',
          value: ProrationMode.immediateAndChargeProratedPrice),
      Pair(
          key: 'IMMEDIATE_WITHOUT_PRORATION',
          value: ProrationMode.immediateWithoutProration),
      Pair(key: 'DEFERRED', value: ProrationMode.deferred),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proration mode options',
            style: AppThemes.titleTextTheme,
          ),
          Container(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: _buildRadioButton(items[index], _selectedProrationMode,
                    (prorationMode) {
                  setState(() {
                    _selectedProrationMode = prorationMode;
                  });
                }),
              );
            },
            itemCount: items.length,
          )
        ],
      ),
    );
  }

  _buildRadioButton(Pair item, ProrationMode selectedMode, Function action) {
    return OutlinedButton(
      onPressed: () => action(item.value),
      style: ElevatedButton.styleFrom(
        backgroundColor: (selectedMode == item.value)
            ? AppColors.primaryAccentColor
            : AppColors.primaryColor,
        minimumSize: const Size.fromHeight(50), // NEW
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      child: Text(item.key,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          )),
    );
  }
}

class Pair<T> {
  Pair({required this.key, required this.value});

  final String key;
  final T value;
}
