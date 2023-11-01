// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseData _$PurchaseDataFromJson(Map json) => PurchaseData(
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      purchaseTime: json['purchaseTime'] as int? ?? 0,
      purchaseToken: json['purchaseToken'] as String? ?? '',
      purchaseState: const PurchaseStateConverter()
          .fromJson(json['purchaseState'] as int?),
      recurringState: const RecurringStateConverter()
          .fromJson(json['recurringState'] as int?),
      quantity: json['quantity'] as int? ?? 1,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      developerPayload: json['developerPayload'] as String? ?? '',
      originalJson: json['originalJson'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
    );

PurchasesResultResponse _$PurchasesResultResponseFromJson(Map json) =>
    PurchasesResultResponse(
      iapResult: IapResult.fromJson((json['iapResult'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      )),
      purchasesList: (json['purchasesList'] as List<dynamic>?)
              ?.map((e) =>
                  PurchaseData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
