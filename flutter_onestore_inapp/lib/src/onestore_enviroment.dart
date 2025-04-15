import 'package:flutter_onestore_inapp/src/onestore_base.dart';


class OneStoreEnvironment {
  static Future<StoreType> getStoreType() async {
    final int? result = await baseChannel.invokeMethod<int?>("getStoreType");
    // result가 null인 경우 0(unknown)으로 처리
    return StoreType.fromValue(result ?? 0);
  }
}

enum StoreType {
  unknown(0),
  oneStore(1),
  vending(2),
  etc(3);

  final int value;

  const StoreType(this.value);

  static StoreType fromValue(int value) {
    return StoreType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StoreType.unknown,
    );
  }
}
