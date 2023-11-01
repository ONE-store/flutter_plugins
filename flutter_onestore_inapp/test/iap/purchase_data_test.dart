import 'package:flutter_onestore_inapp/flutter_onestore_inapp.dart';
import 'package:flutter_test/flutter_test.dart';

const PurchaseData dummyPurchase = PurchaseData(
    orderId: 'orderId',
    packageName: 'packageName',
    purchaseTime: 0,
    productId: 'productId',
    purchaseToken: 'purchaseToken',
    purchaseState: PurchaseState.purchased,
    recurringState: RecurringState.notAutoProduct,
    developerPayload: 'dummy payload',
    quantity: 1,
    isAcknowledged: true,
    originalJson: '',
    signature: 'signature');

void main() {
  group('PurchaseData', () {
    test('converts from map', () {
      const PurchaseData expected = dummyPurchase;
      final PurchaseData parsed =
          PurchaseData.fromJson(_$PurchaseDataToJson(expected));

      expect(parsed, equals(expected));
    });
  });

  group('PurchaseResultResponse', () {
    test('parsed from map', () {
      const PurchaseResponse responseCode = PurchaseResponse.ok;
      const String message = 'response ok';
      final List<PurchaseData> purchases = <PurchaseData>[
        dummyPurchase,
        dummyPurchase
      ];
      const IapResult iapResult =
          IapResult(responseCode: responseCode, message: message);
      final PurchasesResultResponse expected = PurchasesResultResponse(
          iapResult: iapResult, purchasesList: purchases);
      final PurchasesResultResponse parsed =
          PurchasesResultResponse.fromJson(<String, dynamic>{
        'iapResult': _$IapResultToJson(iapResult),
        'purchasesList': <Map<String, dynamic>>[
          _$PurchaseDataToJson(dummyPurchase),
          _$PurchaseDataToJson(dummyPurchase)
        ]
      });
      expect(parsed.iapResult, equals(expected.iapResult));
      expect(parsed.purchasesList, equals(expected.purchasesList));
    });

    test('parsed form empty map', () {
      final PurchasesResultResponse parsed =
          PurchasesResultResponse.fromJson(const <String, dynamic>{});
      expect(
          parsed.iapResult,
          equals(const IapResult(
              responseCode: PurchaseResponse.error,
              message: kInvalidIapResultMessage)));
      expect(parsed.purchasesList, isEmpty);
    });
  });
}

Map<String, dynamic> _$IapResultToJson(IapResult instance) => <String, dynamic>{
      'responseCode':
          const PurchaseResponseConverter().toJson(instance.responseCode),
      'message': instance.message,
    };

Map<String, dynamic> _$PurchaseDataToJson(PurchaseData instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'productId': instance.productId,
      'packageName': instance.packageName,
      'purchaseTime': instance.purchaseTime,
      'purchaseToken': instance.purchaseToken,
      'developerPayload': instance.developerPayload,
      'purchaseState':
          const PurchaseStateConverter().toJson(instance.purchaseState),
      'recurringState':
          const RecurringStateConverter().toJson(instance.recurringState),
      'quantity': instance.quantity,
      'isAcknowledged': instance.isAcknowledged,
      'originalJson': instance.originalJson,
      'signature': instance.signature,
    };
