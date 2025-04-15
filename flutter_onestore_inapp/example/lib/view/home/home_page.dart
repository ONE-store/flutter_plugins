import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../purchase_view_model.dart';
import '../../res/colors.dart';
import '../../res/theme.dart';
import '../details/purchase_details_page.dart';
import '../widget/custom_view_pager.dart';
import '../widget/custom_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _logger = Logger();

  final _pageController = PageController();
  int _bottomNaviSelectedIndex = 0;

  late final PurchaseViewModel _viewModel =
  Provider.of<PurchaseViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    // 앱 개발시 필요에 의해 SDK & Plugin의 로그 레벨을 변경하면 좀 더 자세한 정보를 얻을 수 있습니다.
    // WARNING! Release Build 시엔 로그 레벨 세팅을 제거 바랍니다. (default: Level.info)
    OneStoreLogger.setLogLevel(LogLevel.verbose);

    // 해당 기능을 이용하기위해 AndroidMainfast의 onestore:dev_option을 달아야 합니다.
    getStoreType();

    // Sign in to ONEstore.
    _launchSignInFlow();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ONEstore In-app Example'),
        backgroundColor: AppColors.primaryColor,
        // app bar 오른쪽 부분에 메뉴 설정.
        // 현재 setting icon 버튼은 ALC 화면 이동 처리 Navigator.pushNamed 사용
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, '/check/license'),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: _buildBody(),
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  _buildBody() {
    return SizedBox.expand(
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _bottomNaviSelectedIndex = index;
          });
        },
        children: [
          RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              await _viewModel.fetchPurchases([ProductType.subs]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Consumer<PurchaseViewModel>(
                  builder: (context, model, child) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(left: 15, top: 15, right: 15),
                      child: CustomViewPager<ProductDetail>(
                          title: 'My Subscriptions',
                          type: Type.move,
                          items: _getIntersectionSubscriptions(),
                          onPressed: (item) {
                            // 구독 상품 클릭시 구독상세 페이지로 이동
                            // arguments는 위 설정한 onGenerateRoute 에 의해 전달
                            Navigator.pushNamed(context, '/subscription/detail',
                                arguments: {
                                  'productId': item.productId,
                                });
                          }),
                    );
                  },
                ),
                Consumer<PurchaseViewModel>(
                  builder: (context, model, child) {
                    return _buildProducts(
                        'Consumables', model.consumableProducts);
                  },
                ),
                Consumer<PurchaseViewModel>(
                  builder: (context, model, child) {
                    return _buildProducts(
                        'Subscriptions', model.subscriptionProducts);
                  },
                ),
              ]),
            ),
          ),
          const PurchaseDetailsPage(),
        ],
      ),
    );
  }

  /// 구매한 구독 상품의 상세 정보를 바탕으로 PagerItem을 만듬.
  List<PageItem<ProductDetail>> _getIntersectionSubscriptions() {
    Set<String> purchaseIds =
    _viewModel.subscriptions.map((p) => p.productId).toSet();
    return _viewModel.subscriptionProducts
        .where((product) => purchaseIds.contains(product.productId))
        .map((e) =>
        PageItem<ProductDetail>(
            title: e.title,
            description: '${e.subscriptionPeriod.toString()} '
                '(${e.subscriptionPeriodUnitCode})',
            data: e))
        .toList();
  }

  _buildBottomNavigationBar() {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.format_list_bulleted_rounded), label: 'My Purchases')
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      selectedFontSize: 13,
      unselectedFontSize: 13,
      unselectedItemColor: AppColors.unselectedItemColor,
      currentIndex: _bottomNaviSelectedIndex,
      iconSize: 20,
      items: items,
      onTap: (int index) {
        // body 변경.
        setState(() {
          _logger.d('bottom navigation => $index');
          _bottomNaviSelectedIndex = index;
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn);
        });
      },
    );
  }

  // 상품 리스트 생성
  _buildProducts(String title, List<ProductDetail> items) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 15),
            Text(title, style: AppThemes.titleTextTheme),
            Container(height: 10),
            _buildListView(items)
          ],
        ));
  }

  _buildListView(List<ProductDetail> items) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No items',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: buildButton(
              title: items[index].title,
              action: () {
                _buyProduct(items[index]);
              }),
        );
      },
      itemCount: items.length,
    );
  }

  // 상품 구매
  void _buyProduct(ProductDetail item) {
    _logger.d('buyProduct => ${item.toString()}');
    switch (item.productType) {
      case ProductType.inapp:
      // 관리형 상품 구매
        showDialog(
            context: context,
            builder: buildConsumableDialog(
                title: 'How many are you going to buy this product?',
                action: (quantity) {
                  _launchPurchase(item, quantity);
                }));
        break;

      case ProductType.subs:
      // 구독 상품 구매
        showDialog(
            context: context,
            builder: buildSubscriptionDialog(
                title: 'Do you want to subscribe this product?',
                action: () {
                  _launchPurchase(item, 1);
                }));
        break;

      default:
        _logger.d('This product is not supported.');
    }
  }

  // 구매 실행
  Future<void> _launchPurchase(ProductDetail item, int quantity) async {
    await _viewModel.launchPurchaseFlow(item, quantity, null).then((iapResult) {
      _logger.d('_launchPurchase request complete!\n${iapResult.toString()}');
    });
  }

  // 로그인 시도
  void _launchSignInFlow() {
    _logger.d('launchSignInFlow');
    _viewModel.launchSignInFlow().then((signInResult) {
      if (signInResult.isSuccess()) {
        _logger.d('launchSignInFlow - sign in success.');
        _fetchData();
      } else {
        _logger.d('launchSignInFlow - sign in fail: '
            '${signInResult.message} (${signInResult.code})');
      }
    });
  }

  Future<void> _fetchData() async {
    await _viewModel.fetchProductDetails();
    await _viewModel.fetchPurchases();
  }


  Future getStoreType() async {
    StoreType storeType = await OneStoreEnvironment.getStoreType();

    switch (storeType) {
      case StoreType.unknown:
        debugPrint("스토어 정보를 알 수 없습니다.");
        break;
      case StoreType.oneStore:
        debugPrint("ONE Store에서 설치된 앱입니다.");
        break;
      case StoreType.vending:
        debugPrint("Google Play Store에서 설치된 앱입니다.");
        break;
      case StoreType.etc:
        debugPrint("기타 스토어에서 설치된 앱입니다.");
        break;
    }
  }
}