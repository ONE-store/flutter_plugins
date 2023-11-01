// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IapResult _$IapResultFromJson(Map json) => IapResult(
      responseCode: const PurchaseResponseConverter()
          .fromJson(json['responseCode'] as int?),
      message: json['message'] as String?,
    );
