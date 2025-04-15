import 'package:flutter/material.dart';
import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';
import 'package:provider/provider.dart';

import 'purchase_view_model.dart';
import 'res/theme.dart';
import 'view/details/subscription_detail_page.dart';
import 'view/home/home_page.dart';
import 'view/license/check_license_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      // ChangeNotifier 를 사용하기 위한 프로바이더 등록.
      ChangeNotifierProvider(
    create: (context) => PurchaseViewModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: const TextTheme(
                displayLarge: AppThemes.titleTextTheme,
                displayMedium: AppThemes.bodyPrimaryTextTheme,
                displaySmall: AppThemes.bodyPrimaryTextTheme)),
        // 메인 화면
        home: const HomePage(),
        onGenerateRoute: (settings) => generatedRoutes(settings));
  }
}

Route<dynamic>? generatedRoutes(RouteSettings settings) {
  switch (settings.name) {
    case '/subscription/detail':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) {
        return SubscriptionDetailPage(
          productId: args['productId'],
        );
      });

    case '/check/license':
      return MaterialPageRoute(builder: (context) => const CheckLicensePage());

    default:
      return null;
  }
}
