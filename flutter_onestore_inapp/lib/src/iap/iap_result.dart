import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'purchase_client_manager.dart';
import 'iap_enum.dart';

part 'iap_result.g.dart';

const String kInvalidIapResultMessage =
    'Invalid billing result map from method channel.';

@JsonSerializable()
@PurchaseResponseConverter()
@immutable
class IapResult implements HasPurchaseResponse {
  const IapResult({required this.responseCode, this.message});

  factory IapResult.fromJson(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const IapResult(
          responseCode: PurchaseResponse.error,
          message: kInvalidIapResultMessage);
    }
    return _$IapResultFromJson(map);
  }

  @override
  final PurchaseResponse responseCode;

  final String? message;

  bool isSuccess() => responseCode == PurchaseResponse.ok;

  @override
  String toString() {
    var code = const PurchaseResponseConverter().toJson(responseCode);
    return 'IapResult(responseCode=$responseCode($code), message=$message)';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;

    return other is IapResult &&
        other.responseCode == responseCode &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(responseCode, message);
}
