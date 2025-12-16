# OneStore In-App Purchase Codelab

In this example, you will learn the basics of OneStore In-App Purchase Flutter Plugin. You'll see how easy it is to integrate OneStore's in-app billing functionality into your Flutter app, and understand what problems this plugin solves.

OneStore In-App Purchase Plugin provides a comprehensive solution for integrating Korean market-leading OneStore's billing system into Flutter applications. This plugin handles complex billing operations, subscription management, and purchase verification seamlessly.

## What is OneStore In-App Purchase?

OneStore is South Korea's leading alternative app store, providing a robust in-app purchase system that competes with Google Play Store. The OneStore In-App Purchase system offers:

- **Managed Products (Consumables)**: Items that can be purchased multiple times and consumed by the user
- **Subscription Products**: Recurring billing for services like premium memberships
- **Secure Payment Processing**: Built-in fraud protection and secure transaction handling
- **Real-time Purchase Updates**: Stream-based purchase notifications
- **Flexible Product Management**: Easy product catalog management through OneStore Developer Center

## Key Features

- **Simple Integration**: Initialize with just your public key
- **Reactive Purchase Updates**: Real-time purchase notifications via streams
- **Comprehensive Error Handling**: Built-in error recovery and user guidance
- **Subscription Management**: Full subscription lifecycle management
- **Security First**: Secure purchase verification and acknowledgment
- **Developer Friendly**: Clear APIs with extensive documentation

## Quick Start

Let's start with the simplest way to use OneStore In-App Purchase. First, we'll initialize the `PurchaseClientManager` and fetch product information:

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
    // Initialize with OneStore public key (available in Developer Center)
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
      // Handle successful purchase
      print('Purchase successful: ${product.productId}');
    }
  }
}
```

This simple example demonstrates the core concepts of OneStore In-App Purchase. However, production apps require more sophisticated state management, purchase data handling, and subscription management.

## Advanced Example with Full Features

Real production apps need state management, purchase data processing, subscription management, and more complex features. This example uses the Provider pattern to separate business logic and demonstrates all features.

### Understanding OneStore In-App Purchase Architecture

Before diving into the advanced example, it's important to understand the architecture:

1. **PurchaseClientManager**: The main entry point for all purchase operations
2. **OneStoreAuthClient**: Handles user authentication with OneStore services
3. **Purchase Streams**: Real-time updates for purchase state changes
4. **Product Types**: Different handling for consumables vs. subscriptions
5. **Purchase Lifecycle**: Purchase → Acknowledge/Consume → Verification

### 1. PurchaseViewModel Setup

The `PurchaseViewModel` acts as a centralized state manager that handles all purchase-related operations. It demonstrates separation of concerns by keeping business logic separate from UI components.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';

class PurchaseViewModel extends ChangeNotifier {
  // Product IDs should match those registered in OneStore Developer Center
  static const consumableIds = ['p500', 'p510'];
  static const subscriptionIds = ['week', 'month', 'three_month'];

  final PurchaseClientManager _clientManager = PurchaseClientManager.instance;
  final OneStoreAuthClient _authClient = OneStoreAuthClient();
  
  // Internal state management
  List<PurchaseData> _consumables = [];
  List<PurchaseData> _subscriptions = [];
  List<ProductDetail> _products = [];

  // Public getters for UI consumption
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
    // Initialize with public key (should be stored securely)
    _clientManager.initialize('your_public_key_here');
    
    // Listen to purchase updates stream for real-time purchase notifications
    // This is crucial for handling purchases that complete outside the app flow
    _clientManager.purchasesUpdatedStream.listen(
      (purchasesList) => _handlePurchaseUpdates(purchasesList),
      onError: (error) => print('Purchase error: $error'),
    );
  }
}
```

### 2. Product Details Query

Product details contain essential information like pricing, descriptions, and subscription periods. OneStore supports querying multiple product types efficiently.

```dart
/// Queries product details from OneStore.
/// This should be called when the app starts or when entering the store section.
/// 
/// OneStore supports batch queries for efficiency, but be mindful of response times
/// with large product catalogs.
Future<void> fetchProductDetails() async {
  // Batch query for different product types
  // This is more efficient than individual queries for small product sets
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

  // Alternative single query approach for mixed product types:
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

### 3. Purchase Processing

The purchase flow in OneStore follows a specific pattern: initiate purchase → receive callback → handle acknowledgment/consumption. Understanding this flow is crucial for proper implementation.

```dart
/// Initiates a purchase flow for the specified product.
/// 
/// @param product: The product to purchase (obtained from fetchProductDetails)
/// @param quantity: Number of items to purchase (default: 1, optional)
/// @param developerPayload: Custom data that will be returned with purchase data
/// 
/// The developerPayload is useful for:
/// - Tracking purchase context
/// - Storing user identifiers
/// - Adding custom metadata
Future<IapResult> purchaseProduct(ProductDetail product) async {
  return await _clientManager.launchPurchaseFlow(
    productDetail: product,
    quantity: 1,
    developerPayload: 'custom_data_here', // Optional custom data
  );
}

/// Handles real-time purchase updates from OneStore.
/// This method is called automatically when purchases complete,
/// including purchases that happen outside the current app session.
/// 
/// This is essential for handling:
/// - Network interruption during purchase
/// - Multi-device scenarios
/// - Background purchase completions
void _handlePurchaseUpdates(List<PurchaseData> purchasesList) {
  for (var purchase in purchasesList) {
    if (consumableIds.contains(purchase.productId)) {
      // Handle consumable products - add to list for consumption
      _consumables.add(purchase);
    } else if (subscriptionIds.contains(purchase.productId)) {
      // Handle subscription products - automatically acknowledge
      acknowledgePurchase(purchase);
    }
  }
  notifyListeners();
}
```

### 4. Post-Purchase Processing

OneStore requires explicit acknowledgment or consumption of purchases within 3 days to prevent automatic refunds. This is a critical security feature.

```dart
/// Consumes a purchased product (for consumable products only).
/// 
/// CRITICAL: You must consume or acknowledge purchases within 3 days,
/// or they will be automatically refunded by OneStore.
/// 
/// Consumption workflow:
/// 1. User purchases consumable item
/// 2. App grants the benefit to user
/// 3. App calls consumePurchase to mark item as consumed
/// 4. Item becomes available for repurchase
/// 
/// @param purchaseData: Purchase data from purchase completion or query
Future<void> consumePurchase(PurchaseData purchaseData) async {
  final result = await _clientManager.consumePurchase(
    purchaseData: purchaseData
  );
  
  if (result.isSuccess()) {
    // Refresh purchase list after successful consumption
    fetchPurchases([ProductType.inapp]);
  }
}

/// Acknowledges a purchased product (for both consumable and subscription products).
/// 
/// For consumable products: Use this for time-based items where you want to
/// prevent repurchase until a certain period passes (like daily bonuses).
/// 
/// For subscription products: This is REQUIRED after every subscription purchase.
/// 
/// Acknowledgment workflow:
/// 1. User purchases item
/// 2. App verifies purchase server-side (recommended)
/// 3. App grants benefits to user
/// 4. App calls acknowledgePurchase to confirm receipt
/// 
/// @param purchaseData: Purchase data from purchase completion or query
Future<void> acknowledgePurchase(PurchaseData purchaseData) async {
  final result = await _clientManager.acknowledgePurchase(
    purchaseData: purchaseData
  );
  
  if (result.isSuccess()) {
    fetchPurchases([ProductType.subs]);
  }
}
```

### 5. Purchase History Query

Querying purchase history is essential for handling edge cases and ensuring all purchases are properly processed.

```dart
/// Queries existing purchases from OneStore.
/// Returns unconsumed managed products and active subscriptions.
/// 
/// This should be called:
/// - When app starts
/// - When app returns from background
/// - When entering store/premium sections
/// - After network connectivity is restored
/// 
/// This handles scenarios like:
/// - Network issues during purchase
/// - Multi-device usage
/// - App crashes during purchase processing
/// 
/// @param types: Product types to query (defaults to both inapp and subs)
Future<void> fetchPurchases([List<ProductType>? types]) async {
  types ??= [ProductType.inapp, ProductType.subs];
  
  for (var type in types) {
    final response = await _clientManager.queryPurchases(productType: type);
    
    if (response.iapResult.isSuccess()) {
      if (type == ProductType.inapp) {
        _consumables.clear();
        _consumables.addAll(response.purchasesList);
      } else if (type == ProductType.subs) {
        // Auto-acknowledge unacknowledged subscriptions
        // This ensures subscription benefits are activated even if
        // the initial acknowledgment failed
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

### 6. UI Implementation

The UI layer should be kept simple and reactive, responding to state changes from the ViewModel.

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
    // Enable verbose logging for development (remove in production)
    OneStoreLogger.setLogLevel(LogLevel.verbose);
    
    // Initialize OneStore authentication and data
    _initializeOneStore();
  }

  /// Initializes OneStore services and loads initial data.
  /// This demonstrates the proper initialization sequence.
  Future<void> _initializeOneStore() async {
    final viewModel = Provider.of<PurchaseViewModel>(context, listen: false);
    
    // Step 1: Authenticate with OneStore
    final authResult = await viewModel.signIn();
    
    if (authResult.isSuccess()) {
      // Step 2: Load product catalog
      await viewModel.fetchProductDetails();
      
      // Step 3: Check for existing purchases
      await viewModel.fetchPurchases();
    } else {
      // Handle authentication failure
      _showAuthenticationError(authResult);
    }
  }

  void _showAuthenticationError(SignInResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authentication failed: ${result.debugMessage}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OneStore In-App Example'),
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
                  // Consumable products section
                  _buildProductSection(
                    'Consumable Products',
                    viewModel.consumableProducts,
                    viewModel.purchaseProduct,
                  ),
                  
                  // Subscription products section
                  _buildProductSection(
                    'Subscription Products',
                    viewModel.subscriptionProducts,
                    viewModel.purchaseProduct,
                  ),
                  
                  // Purchased items section
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
                  'No products available',
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
          Text('My Purchases', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8),
          
          // Consumable products
          ...viewModel.consumables.map((purchase) => Card(
            child: ListTile(
              title: Text(purchase.productId),
              subtitle: Text('Consumable Product'),
              trailing: ElevatedButton(
                child: Text('Consume'),
                onPressed: () => viewModel.consumePurchase(purchase),
              ),
            ),
          )),
          
          // Subscription products
          ...viewModel.subscriptions.map((purchase) => Card(
            child: ListTile(
              title: Text(purchase.productId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subscription Product'),
                  Text(
                    'Status: ${purchase.isAcknowledged ? "Active" : "Pending"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                child: Text('Manage'),
                onPressed: () => viewModel.manageSubscription(purchase),
              ),
            ),
          )),
          
          if (viewModel.consumables.isEmpty && viewModel.subscriptions.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: Text(
                  'No purchases found',
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

## Core Features

### Authentication

OneStore services are authentication-based. Users must sign in before making purchases:

```dart
final authClient = OneStoreAuthClient();

/// Initiates OneStore sign-in flow.
/// This should be called at app startup or when purchase APIs return needLogin error.
Future<SignInResult> signIn() async {
  return await authClient.launchSignInFlow();
}
```

### Subscription Management

OneStore provides comprehensive subscription management features:

```dart
/// Updates an existing subscription (upgrade/downgrade).
/// 
/// @param newProduct: The new subscription product
/// @param oldPurchase: The current subscription purchase data
/// @param prorationMode: How to handle billing cycle changes
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

/// Opens OneStore's subscription management screen.
/// 
/// If purchaseData is null: Opens subscription list screen
/// If purchaseData is provided: Opens specific subscription details
Future<void> manageSubscription(PurchaseData? purchaseData) async {
  await _clientManager.launchManageSubscription(purchaseData);
}
```

### Error Handling

Proper error handling is crucial for a smooth user experience:

```dart
/// Handles common OneStore errors with appropriate user actions.
void _handleError(IapResult result) {
  switch (result.responseCode) {
    case PurchaseResponse.needUpdate:
      // OneStore app needs update or installation
      _clientManager.launchUpdateOrInstall();
      break;
    case PurchaseResponse.needLogin:
      // User needs to re-authenticate
      signIn();
      break;
    case PurchaseResponse.userCanceled:
      // User canceled the purchase - no action needed
      break;
    case PurchaseResponse.itemAlreadyOwned:
      // User already owns this item - refresh purchases
      fetchPurchases();
      break;
    default:
      print('Error: ${result.debugMessage}');
      // Show user-friendly error message
      _showErrorDialog(result.debugMessage);
  }
}
```

### Store Environment Detection

OneStore provides API to detect installation source:

```dart
/// Detects which store the app was installed from.
/// Useful for showing appropriate payment UI or restricting features.
Future<void> checkStoreEnvironment() async {
  StoreType storeType = await OneStoreEnvironment.getStoreType();
  
  switch (storeType) {
    case StoreType.unknown:
      print("Store information unknown");
      break;
    case StoreType.oneStore:
      print("Installed from ONE Store");
      // Show OneStore-specific features
      break;
    case StoreType.vending:
      print("Installed from Google Play Store");
      // Handle Google Play Store scenario
      break;
    case StoreType.etc:
      print("Installed from other store");
      break;
  }
}
```

## Configuration

### 1. Public Key Setup

Store your OneStore public key securely:

`lib/config/app_config.dart`:

```dart
class AppConfig {
  /// OneStore public key from Developer Center
  /// For security, consider storing this on your server and fetching it at runtime
  /// 
  /// Get your key from: OneStore Developer Center > App Management > License Management
  static const publicKey = 'your_actual_public_key_here';
}
```

### 2. Android Configuration

Add OneStore development option to `android/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- OneStore development option -->
    <!-- Choose the appropriate value based on your target market -->
    <!-- For more details, see: https://onestore-dev.gitbook.io/dev/eng/tools/tools/v21/flutter#undefined-3 -->
    <meta-data
        android:name="onestore:dev_option"
        android:value="onestore_00" />
</application>
```

**Development Option Values by Region:**
- `onestore_00`: **South Korea** - Use this for Korean market development and testing
- `onestore_01`: **Singapore, Taiwan** - Use this for Southeast Asian markets
- `onestore_02`: **United States** - Use this for US market development and testing
- **Production**: Remove this meta-data completely from your AndroidManifest.xml

**Important Notes:**
- Choose the appropriate value based on your target market region
- The development option is essential for testing OneStore IAP functionality during development
- When any of these options is enabled, `OneStoreEnvironment.getStoreType()` will always return `StoreType.ONESTORE`
- **Must be removed** before releasing to production to ensure proper store detection
- This setting allows testing OneStore features even when the app is not installed from OneStore

**Example for different regions:**
```xml
<!-- For South Korea -->
<meta-data android:name="onestore:dev_option" android:value="onestore_00" />

<!-- For Singapore/Taiwan -->
<meta-data android:name="onestore:dev_option" android:value="onestore_01" />

<!-- For United States -->
<meta-data android:name="onestore:dev_option" android:value="onestore_02" />
```

For detailed configuration instructions and store determination criteria, refer to the [OneStore Flutter Integration Guide](https://onestore-dev.gitbook.io/dev/eng/tools/tools/v21/flutter#undefined-3).

## Important Considerations

### 1. Purchase Processing Timeline
- **Critical**: You must consume or acknowledge purchases within 3 days or they will be automatically refunded by OneStore.
- Implement proper error handling and retry mechanisms for purchase processing.

### 2. Product Types
- **Consumable Products** (`ProductType.inapp`): Must be consumed to allow repurchase.
- **Subscription Products** (`ProductType.subs`): Must be acknowledged after purchase.

### 3. Security Best Practices
- Store public keys securely (preferably server-side).
- Implement server-side purchase verification for production apps.
- Use HTTPS for all server communications.

### 4. Development vs Production
- Remove verbose logging in production builds.
- Remove or modify `onestore:dev_option` for production.
- Test thoroughly with actual OneStore environment.

### 5. User Experience
- Provide clear purchase confirmation dialogs.
- Handle network interruptions gracefully.
- Implement proper loading states during purchase flows.

### 6. Testing
- Use OneStore's sandbox environment for testing.
- Test purchase flows with various network conditions.
- Verify subscription upgrade/downgrade scenarios.

## Troubleshooting Common Issues

### Purchase Not Completing
- Check network connectivity
- Verify public key configuration
- Ensure proper authentication
- Check OneStore app version

### Subscription Issues
- Verify subscription product configuration in Developer Center
- Check acknowledgment implementation
- Test subscription management flows

### Authentication Problems
- Ensure OneStore app is installed and updated
- Check device compatibility
- Verify app signature matches Developer Center

## Additional Resources

For more detailed information and advanced features, refer to the [OneStore Developer Documentation](https://onestore-dev.gitbook.io/dev/eng/tools/tools/v21/flutter).

This comprehensive example demonstrates all major OneStore In-App Purchase features and best practices. Use it as a foundation for implementing robust in-app purchases in your Flutter applications. 