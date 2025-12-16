# OneStore 인앱결제 코드랩

이 예제에서는 OneStore 인앱결제 Flutter 플러그인의 기본 사용법을 배울 수 있습니다. OneStore의 인앱 결제 기능을 Flutter 앱에 얼마나 쉽게 통합할 수 있는지 확인하고, 이 플러그인이 해결하는 문제들을 이해할 수 있습니다.

OneStore 인앱결제 플러그인은 한국 시장을 선도하는 OneStore의 결제 시스템을 Flutter 애플리케이션에 통합하는 포괄적인 솔루션을 제공합니다. 이 플러그인은 복잡한 결제 작업, 구독 관리, 구매 검증을 원활하게 처리합니다.

## OneStore 인앱결제란?

OneStore는 한국의 대표적인 대안 앱스토어로, Google Play Store와 경쟁하는 강력한 인앱결제 시스템을 제공합니다. OneStore 인앱결제 시스템은 다음을 제공합니다:

- **관리형 상품 (소비형)**: 사용자가 여러 번 구매하고 소비할 수 있는 아이템
- **구독 상품**: 프리미엄 멤버십과 같은 서비스의 정기 결제
- **보안 결제 처리**: 내장된 사기 방지 및 보안 거래 처리
- **실시간 구매 업데이트**: 스트림 기반 구매 알림
- **유연한 상품 관리**: OneStore 개발자센터를 통한 쉬운 상품 카탈로그 관리

## 주요 기능

- **간단한 통합**: 공개키만으로 초기화
- **반응형 구매 업데이트**: 스트림을 통한 실시간 구매 알림
- **포괄적인 오류 처리**: 내장된 오류 복구 및 사용자 안내
- **구독 관리**: 완전한 구독 생명주기 관리
- **보안 우선**: 안전한 구매 검증 및 확인
- **개발자 친화적**: 광범위한 문서와 함께 제공되는 명확한 API

## 빠른 시작

OneStore 인앱결제를 사용하는 가장 간단한 방법부터 시작해보겠습니다. 먼저 `PurchaseClientManager`를 초기화하고 상품 정보를 가져오겠습니다:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';

void main() {
  runApp(MaterialApp(home: SimpleInAppExample()));
}

class SimpleInAppExample extends StatefulWidget {
  @override
  _SimpleInAppExampleState createState() => _SimpleInAppExampleState();
}

class _SimpleInAppExampleState extends State<SimpleInAppExample> {
  final PurchaseClientManager _clientManager = PurchaseClientManager.instance;
  List<ProductDetail> products = [];

  @override
  void initState() {
    super.initState();
    // OneStore 공개키로 초기화 (개발자센터에서 확인 가능)
    _clientManager.initialize('your_public_key_here');
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await _clientManager.queryProductDetails(
      productIds: ['p500', 'p510'], 
      productType: ProductType.inapp
    );
    
    if (response.iapResult.isSuccess()) {
      setState(() {
        products = response.productDetailsList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OneStore IAP Example')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.price),
            onTap: () => _purchaseProduct(product),
          );
        },
      ),
    );
  }

  Future<void> _purchaseProduct(ProductDetail product) async {
    final result = await _clientManager.launchPurchaseFlow(
      productDetail: product,
    );
    
    if (result.isSuccess()) {
      // 구매 성공 처리
      print('구매 성공: ${product.productId}');
    }
  }
}
```

이 간단한 예제는 OneStore 인앱결제의 핵심 개념을 보여줍니다. 하지만 프로덕션 앱에서는 더 정교한 상태 관리, 구매 데이터 처리, 구독 관리가 필요합니다.

## 전체 기능을 활용한 고급 예제

실제 프로덕션 앱에는 상태 관리, 구매 데이터 처리, 구독 관리 및 더 복잡한 기능이 필요합니다. 이 예제는 Provider 패턴을 사용하여 비즈니스 로직을 분리하고 모든 기능을 보여줍니다.

### OneStore 인앱결제 아키텍처 이해

고급 예제를 살펴보기 전에 아키텍처를 이해하는 것이 중요합니다:

1. **PurchaseClientManager**: 모든 구매 작업의 주요 진입점
2. **OneStoreAuthClient**: OneStore 서비스와의 사용자 인증 처리
3. **구매 스트림**: 구매 상태 변경에 대한 실시간 업데이트
4. **상품 유형**: 소비형과 구독형의 다른 처리 방식
5. **구매 생명주기**: 구매 → 확인/소비 → 검증

### 1. PurchaseViewModel 설정

`PurchaseViewModel`은 모든 구매 관련 작업을 처리하는 중앙 집중식 상태 관리자 역할을 합니다. 비즈니스 로직을 UI 구성 요소와 분리하여 관심사의 분리를 보여줍니다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';

class PurchaseViewModel extends ChangeNotifier {
  // 상품 ID는 OneStore 개발자센터에 등록된 것과 일치해야 합니다
  static const consumableIds = ['p500', 'p510'];
  static const subscriptionIds = ['week', 'month', 'three_month'];

  final PurchaseClientManager _clientManager = PurchaseClientManager.instance;
  final OneStoreAuthClient _authClient = OneStoreAuthClient();
  
  // 내부 상태 관리
  List<PurchaseData> _consumables = [];
  List<PurchaseData> _subscriptions = [];
  List<ProductDetail> _products = [];

  // UI 사용을 위한 공개 getter
  List<PurchaseData> get consumables => _consumables;
  List<PurchaseData> get subscriptions => _subscriptions;
  List<ProductDetail> get consumableProducts => 
    _products.where((p) => p.productType == ProductType.inapp).toList();
  List<ProductDetail> get subscriptionProducts => 
    _products.where((p) => p.productType == ProductType.subs).toList();

  PurchaseViewModel() {
    _initialize();
  }

  void _initialize() {
    // 공개키로 초기화 (안전하게 저장되어야 함)
    _clientManager.initialize('your_public_key_here');
    
    // 실시간 구매 알림을 위한 구매 업데이트 스트림 리스닝
    // 앱 플로우 외부에서 완료되는 구매를 처리하는 데 중요합니다
    _clientManager.purchasesUpdatedStream.listen(
      (purchasesList) => _handlePurchaseUpdates(purchasesList),
      onError: (error) => print('구매 오류: $error'),
    );
  }
}
```

### 2. 상품 정보 조회

상품 정보에는 가격, 설명, 구독 기간과 같은 필수 정보가 포함됩니다. OneStore는 여러 상품 유형을 효율적으로 조회하는 것을 지원합니다.

```dart
/// OneStore에서 상품 정보를 조회합니다.
/// 앱이 시작될 때나 상점 섹션에 진입할 때 호출되어야 합니다.
/// 
/// OneStore는 효율성을 위해 배치 쿼리를 지원하지만, 
/// 대규모 상품 카탈로그의 경우 응답 시간에 주의해야 합니다.
Future<void> fetchProductDetails() async {
  // 다양한 상품 유형에 대한 배치 쿼리
  // 소규모 상품 세트의 경우 개별 쿼리보다 효율적입니다
  var responses = await Future.wait([
    _clientManager.queryProductDetails(
      productIds: consumableIds, 
      productType: ProductType.inapp
    ),
    _clientManager.queryProductDetails(
      productIds: subscriptionIds, 
      productType: ProductType.subs
    )
  ]);

  // 혼합 상품 유형에 대한 대안적 단일 쿼리 접근법:
  // var response = await _clientManager.queryProductDetails(
  //   productIds: [...consumableIds, ...subscriptionIds],
  //   productType: ProductType.all
  // );

  if (responses.first.iapResult.isSuccess()) {
    final allProducts = responses
      .expand((response) => response.productDetailsList)
      .toList();
    
    _products.clear();
    _products.addAll(allProducts);
    notifyListeners();
  }
}
```

### 3. 구매 처리

OneStore의 구매 플로우는 특정 패턴을 따릅니다: 구매 시작 → 콜백 수신 → 확인/소비 처리. 이 플로우를 이해하는 것은 적절한 구현에 중요합니다.

```dart
/// 지정된 상품에 대한 구매 플로우를 시작합니다.
/// 
/// @param product: 구매할 상품 (fetchProductDetails에서 획득)
/// @param quantity: 구매할 아이템 수 (기본값: 1, 선택사항)
/// @param developerPayload: 구매 데이터와 함께 반환될 사용자 정의 데이터
/// 
/// developerPayload는 다음과 같은 용도로 유용합니다:
/// - 구매 컨텍스트 추적
/// - 사용자 식별자 저장
/// - 사용자 정의 메타데이터 추가
Future<IapResult> purchaseProduct(ProductDetail product) async {
  return await _clientManager.launchPurchaseFlow(
    productDetail: product,
    quantity: 1,
    developerPayload: 'custom_data_here', // 선택적 사용자 정의 데이터
  );
}

/// OneStore로부터 실시간 구매 업데이트를 처리합니다.
/// 이 메서드는 구매가 완료될 때 자동으로 호출되며,
/// 현재 앱 세션 외부에서 발생하는 구매도 포함합니다.
/// 
/// 다음 상황을 처리하는 데 필수적입니다:
/// - 구매 중 네트워크 중단
/// - 다중 기기 시나리오
/// - 백그라운드 구매 완료
void _handlePurchaseUpdates(List<PurchaseData> purchasesList) {
  for (var purchase in purchasesList) {
    if (consumableIds.contains(purchase.productId)) {
      // 소비형 상품 처리 - 소비를 위해 목록에 추가
      _consumables.add(purchase);
    } else if (subscriptionIds.contains(purchase.productId)) {
      // 구독 상품 처리 - 자동으로 확인
      acknowledgePurchase(purchase);
    }
  }
  notifyListeners();
}
```

### 4. 구매 후 처리

OneStore는 자동 환불을 방지하기 위해 3일 이내에 구매에 대한 명시적 확인 또는 소비를 요구합니다. 이는 중요한 보안 기능입니다.

```dart
/// 구매한 상품을 소비합니다 (소비형 상품만 해당).
/// 
/// 중요: 3일 이내에 구매를 소비하거나 확인하지 않으면
/// OneStore에서 자동으로 환불됩니다.
/// 
/// 소비 워크플로우:
/// 1. 사용자가 소비형 아이템 구매
/// 2. 앱이 사용자에게 혜택 제공
/// 3. 앱이 consumePurchase를 호출하여 아이템을 소비됨으로 표시
/// 4. 아이템이 재구매 가능해짐
/// 
/// @param purchaseData: 구매 완료 또는 쿼리에서 얻은 구매 데이터
Future<void> consumePurchase(PurchaseData purchaseData) async {
  final result = await _clientManager.consumePurchase(
    purchaseData: purchaseData
  );
  
  if (result.isSuccess()) {
    // 성공적인 소비 후 구매 목록 새로고침
    fetchPurchases([ProductType.inapp]);
  }
}

/// 구매한 상품을 확인합니다 (소비형 및 구독 상품 모두 해당).
/// 
/// 소비형 상품의 경우: 특정 기간이 지날 때까지 재구매를 방지하려는
/// 시간 기반 아이템(일일 보너스 등)에 사용합니다.
/// 
/// 구독 상품의 경우: 모든 구독 구매 후 필수입니다.
/// 
/// 확인 워크플로우:
/// 1. 사용자가 아이템 구매
/// 2. 앱이 서버 측에서 구매 검증 (권장)
/// 3. 앱이 사용자에게 혜택 제공
/// 4. 앱이 acknowledgePurchase를 호출하여 수령 확인
/// 
/// @param purchaseData: 구매 완료 또는 쿼리에서 얻은 구매 데이터
Future<void> acknowledgePurchase(PurchaseData purchaseData) async {
  final result = await _clientManager.acknowledgePurchase(
    purchaseData: purchaseData
  );
  
  if (result.isSuccess()) {
    fetchPurchases([ProductType.subs]);
  }
}
```

### 5. 구매 내역 조회

구매 내역 조회는 엣지 케이스를 처리하고 모든 구매가 적절히 처리되도록 보장하는 데 필수적입니다.

```dart
/// OneStore에서 기존 구매를 조회합니다.
/// 소비되지 않은 관리형 상품과 활성 구독을 반환합니다.
/// 
/// 다음 상황에서 호출되어야 합니다:
/// - 앱 시작 시
/// - 앱이 백그라운드에서 복귀할 때
/// - 상점/프리미엄 섹션 진입 시
/// - 네트워크 연결이 복원된 후
/// 
/// 다음과 같은 시나리오를 처리합니다:
/// - 구매 중 네트워크 문제
/// - 다중 기기 사용
/// - 구매 처리 중 앱 크래시
/// 
/// @param types: 조회할 상품 유형 (기본값: inapp과 subs 모두)
Future<void> fetchPurchases([List<ProductType>? types]) async {
  types ??= [ProductType.inapp, ProductType.subs];
  
  for (var type in types) {
    final response = await _clientManager.queryPurchases(productType: type);
    
    if (response.iapResult.isSuccess()) {
      if (type == ProductType.inapp) {
        _consumables.clear();
        _consumables.addAll(response.purchasesList);
      } else if (type == ProductType.subs) {
        // 확인되지 않은 구독을 자동으로 확인
        // 초기 확인이 실패한 경우에도 구독 혜택이 활성화되도록 보장
        for (var purchase in response.purchasesList) {
          if (!purchase.isAcknowledged) {
            acknowledgePurchase(purchase);
          }
        }
        
        _subscriptions.clear();
        _subscriptions.addAll(response.purchasesList);
      }
      notifyListeners();
    }
  }
}
```

### 6. UI 구현

UI 레이어는 간단하고 반응적으로 유지되어야 하며, ViewModel의 상태 변경에 응답해야 합니다.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PurchaseViewModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneStore IAP Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 개발용 상세 로깅 활성화 (프로덕션에서는 제거)
    OneStoreLogger.setLogLevel(LogLevel.verbose);
    
    // OneStore 인증 및 데이터 초기화
    _initializeOneStore();
  }

  /// OneStore 서비스를 초기화하고 초기 데이터를 로드합니다.
  /// 적절한 초기화 순서를 보여줍니다.
  Future<void> _initializeOneStore() async {
    final viewModel = Provider.of<PurchaseViewModel>(context, listen: false);
    
    // 1단계: OneStore 인증
    final authResult = await viewModel.signIn();
    
    if (authResult.isSuccess()) {
      // 2단계: 상품 카탈로그 로드
      await viewModel.fetchProductDetails();
      
      // 3단계: 기존 구매 확인
      await viewModel.fetchPurchases();
    } else {
      // 인증 실패 처리
      _showAuthenticationError(authResult);
    }
  }

  void _showAuthenticationError(SignInResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('인증 실패: ${result.debugMessage}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OneStore 인앱결제 예제'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LicenseCheckPage()),
            ),
          ),
        ],
      ),
      body: Consumer<PurchaseViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchProductDetails();
              await viewModel.fetchPurchases();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // 소비형 상품 섹션
                  _buildProductSection(
                    '소비형 상품',
                    viewModel.consumableProducts,
                    viewModel.purchaseProduct,
                  ),
                  
                  // 구독 상품 섹션
                  _buildProductSection(
                    '구독 상품',
                    viewModel.subscriptionProducts,
                    viewModel.purchaseProduct,
                  ),
                  
                  // 구매한 아이템 섹션
                  _buildPurchasedSection(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection(
    String title,
    List<ProductDetail> products,
    Function(ProductDetail) onPurchase,
  ) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8),
          if (products.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: Text(
                  '사용 가능한 상품이 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...products.map((product) => Card(
              child: ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(product.price, style: TextStyle(fontWeight: FontWeight.bold)),
                    if (product.productType == ProductType.subs)
                      Text(
                        '${product.subscriptionPeriod} ${product.subscriptionPeriodUnitCode}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                onTap: () => onPurchase(product),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPurchasedSection(PurchaseViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내 구매', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8),
          
          // 소비형 상품
          ...viewModel.consumables.map((purchase) => Card(
            child: ListTile(
              title: Text(purchase.productId),
              subtitle: Text('소비형 상품'),
              trailing: ElevatedButton(
                child: Text('소비'),
                onPressed: () => viewModel.consumePurchase(purchase),
              ),
            ),
          )),
          
          // 구독 상품
          ...viewModel.subscriptions.map((purchase) => Card(
            child: ListTile(
              title: Text(purchase.productId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('구독 상품'),
                  Text(
                    '상태: ${purchase.isAcknowledged ? "활성" : "대기 중"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                child: Text('관리'),
                onPressed: () => viewModel.manageSubscription(purchase),
              ),
            ),
          )),
          
          if (viewModel.consumables.isEmpty && viewModel.subscriptions.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: Text(
                  '구매한 상품이 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

## 핵심 기능

### 인증

OneStore 서비스는 인증 기반입니다. 사용자는 구매하기 전에 로그인해야 합니다:

```dart
final authClient = OneStoreAuthClient();

/// OneStore 로그인 플로우를 시작합니다.
/// 앱 시작 시 또는 구매 API가 needLogin 오류를 반환할 때 호출되어야 합니다.
Future<SignInResult> signIn() async {
  return await authClient.launchSignInFlow();
}
```

### 구독 관리

OneStore는 포괄적인 구독 관리 기능을 제공합니다:

```dart
/// 기존 구독을 업데이트합니다 (업그레이드/다운그레이드).
/// 
/// @param newProduct: 새로운 구독 상품
/// @param oldPurchase: 현재 구독 구매 데이터
/// @param prorationMode: 결제 주기 변경 처리 방법
Future<IapResult> updateSubscription(
  ProductDetail newProduct,
  PurchaseData oldPurchase,
  ProrationMode prorationMode,
) async {
  return await _clientManager.launchUpdateSubscription(
    productDetail: newProduct,
    oldPurchaseData: oldPurchase,
    prorationMode: prorationMode,
  );
}

/// OneStore의 구독 관리 화면을 엽니다.
/// 
/// purchaseData가 null인 경우: 구독 목록 화면을 엽니다
/// purchaseData가 제공된 경우: 특정 구독 상세 정보를 엽니다
Future<void> manageSubscription(PurchaseData? purchaseData) async {
  await _clientManager.launchManageSubscription(purchaseData);
}
```

### 오류 처리

원활한 사용자 경험을 위해서는 적절한 오류 처리가 중요합니다:

```dart
/// 적절한 사용자 작업과 함께 일반적인 OneStore 오류를 처리합니다.
void _handleError(IapResult result) {
  switch (result.responseCode) {
    case PurchaseResponse.needUpdate:
      // OneStore 앱 업데이트 또는 설치 필요
      _clientManager.launchUpdateOrInstall();
      break;
    case PurchaseResponse.needLogin:
      // 사용자 재인증 필요
      signIn();
      break;
    case PurchaseResponse.userCanceled:
      // 사용자가 구매를 취소함 - 별도 조치 불필요
      break;
    case PurchaseResponse.itemAlreadyOwned:
      // 사용자가 이미 이 아이템을 소유함 - 구매 새로고침
      fetchPurchases();
      break;
    default:
      print('오류: ${result.debugMessage}');
      // 사용자 친화적인 오류 메시지 표시
      _showErrorDialog(result.debugMessage);
  }
}
```

### 스토어 환경 감지

OneStore는 설치 소스를 감지하는 API를 제공합니다:

```dart
/// 앱이 어느 스토어에서 설치되었는지 감지합니다.
/// 적절한 결제 UI를 표시하거나 기능을 제한하는 데 유용합니다.
Future<void> checkStoreEnvironment() async {
  StoreType storeType = await OneStoreEnvironment.getStoreType();
  
  switch (storeType) {
    case StoreType.unknown:
      print("스토어 정보를 알 수 없습니다");
      break;
    case StoreType.oneStore:
      print("ONE Store에서 설치됨");
      // OneStore 전용 기능 표시
      break;
    case StoreType.vending:
      print("Google Play Store에서 설치됨");
      // Google Play Store 시나리오 처리
      break;
    case StoreType.etc:
      print("기타 스토어에서 설치됨");
      break;
  }
}
```

## 설정

### 1. 공개키 설정

OneStore 공개키를 안전하게 저장하세요:

`lib/config/app_config.dart`:

```dart
class AppConfig {
  /// 개발자센터의 OneStore 공개키
  /// 보안을 위해 서버에 저장하고 런타임에 가져오는 것을 고려하세요
  /// 
  /// 키 획득 위치: OneStore 개발자센터 > 앱 관리 > 라이선스 관리
  static const publicKey = 'your_actual_public_key_here';
}
```

### 2. Android 설정

`android/src/main/AndroidManifest.xml`에 OneStore 개발 옵션을 추가하세요:

```xml
<application>
    <!-- OneStore 개발 옵션 -->
    <!-- 타겟 시장에 따라 적절한 값을 선택하세요 -->
    <!-- 자세한 내용은 다음을 참조하세요: https://onestore-dev.gitbook.io/dev/tools/tools/v21/flutter#undefined-5 -->
    <meta-data
        android:name="onestore:dev_option"
        android:value="onestore_00" />
</application>
```

**지역별 개발 옵션 값:**
- `onestore_00`: **한국** - 한국 시장 개발 및 테스트용
- `onestore_01`: **싱가포르, 대만** - 동남아시아 시장용
- `onestore_02`: **미국** - 미국 시장 개발 및 테스트용
- **프로덕션**: AndroidManifest.xml에서 이 메타데이터를 완전히 제거

**중요 사항:**
- 타겟 시장 지역에 따라 적절한 값을 선택하세요
- 개발 옵션은 개발 중 OneStore IAP 기능을 테스트하는 데 필수적입니다
- 이러한 옵션 중 하나라도 활성화되면 `OneStoreEnvironment.getStoreType()`이 항상 `StoreType.ONESTORE`를 반환합니다
- 적절한 스토어 감지를 보장하기 위해 프로덕션 릴리즈 전에 **반드시 제거**해야 합니다
- 이 설정을 통해 OneStore에서 설치되지 않은 앱에서도 OneStore 기능을 테스트할 수 있습니다

**다양한 지역별 예제:**
```xml
<!-- 한국용 -->
<meta-data android:name="onestore:dev_option" android:value="onestore_00" />

<!-- 싱가포르/대만용 -->
<meta-data android:name="onestore:dev_option" android:value="onestore_01" />

<!-- 미국용 -->
<meta-data android:name="onestore:dev_option" android:value="onestore_02" />
```

자세한 설정 지침 및 스토어 판단 기준은 [OneStore Flutter 통합 가이드](https://onestore-dev.gitbook.io/dev/tools/tools/v21/flutter#undefined-5)를 참조하세요.

## 중요 고려사항

### 1. 구매 처리 타임라인
- **중요**: 3일 이내에 구매를 소비하거나 확인하지 않으면 OneStore에서 자동으로 환불됩니다.
- 구매 처리를 위한 적절한 오류 처리 및 재시도 메커니즘을 구현하세요.

### 2. 상품 유형
- **소비형 상품** (`ProductType.inapp`): 재구매를 허용하려면 소비되어야 합니다.
- **구독 상품** (`ProductType.subs`): 구매 후 확인되어야 합니다.

### 3. 보안 모범 사례
- 공개키를 안전하게 저장하세요 (가급적 서버 측).
- 프로덕션 앱에서는 서버 측 구매 검증을 구현하세요.
- 모든 서버 통신에 HTTPS를 사용하세요.

### 4. 개발 vs 프로덕션
- 프로덕션 빌드에서는 상세 로깅을 제거하세요.
- 프로덕션용 `onestore:dev_option`을 제거하거나 수정하세요.
- 실제 OneStore 환경에서 철저히 테스트하세요.

### 5. 사용자 경험
- 명확한 구매 확인 대화상자를 제공하세요.
- 네트워크 중단을 우아하게 처리하세요.
- 구매 플로우 중 적절한 로딩 상태를 구현하세요.

### 6. 테스팅
- 테스트를 위해 OneStore의 샌드박스 환경을 사용하세요.
- 다양한 네트워크 조건에서 구매 플로우를 테스트하세요.
- 구독 업그레이드/다운그레이드 시나리오를 검증하세요.

## 일반적인 문제 해결

### 구매가 완료되지 않음
- 네트워크 연결 확인
- 공개키 설정 검증
- 적절한 인증 보장
- OneStore 앱 버전 확인

### 구독 문제
- 개발자센터에서 구독 상품 설정 검증
- 확인 구현 확인
- 구독 관리 플로우 테스트

### 인증 문제
- OneStore 앱이 설치되고 업데이트되었는지 확인
- 기기 호환성 확인
- 앱 서명이 개발자센터와 일치하는지 검증

## 추가 리소스

더 자세한 정보와 고급 기능은 [OneStore 개발자 문서](https://onestore-dev.gitbook.io/dev/tools/tools/v21/flutter)를 참조하세요.

이 포괄적인 예제는 모든 주요 OneStore 인앱결제 기능과 모범 사례를 보여줍니다. Flutter 애플리케이션에서 강력한 인앱결제를 구현하는 기초로 사용하세요.
