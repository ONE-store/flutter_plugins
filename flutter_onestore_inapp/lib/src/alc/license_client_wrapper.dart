import 'package:flutter/services.dart';

import '../onestore_channel.dart';

const String _kOnGranted = 'onGranted';
const String _kOnDenied = 'onDenied';
const String _kOnError = 'onError';

abstract class LicenseCallback {
  void onGranted(String license, String signature);

  void onDenied();

  void onError(int code, String message);
}

/// ALC 클라이언트
class LicenseClient extends OneStoreChannel {
  LicenseCallback? callback;

  final String publicKey;

  LicenseClient(this.publicKey, [this.callback]) : super('license') {
    channel.setMethodCallHandler(methodCallHandler);
  }

  Future<void> queryLicense() async {
    return channel.invokeMethod<void>('queryLicense', publicKey);
  }

  Future<void> strictQueryLicense() async {
    return channel.invokeMethod<void>('strictQueryLicense', publicKey);
  }

  Future<void> dispose() async {
    callback = null;
    return channel.invokeMethod<void>('destroy');
  }

  void listen(LicenseCallback callback) {
    this.callback = callback;
  }

  Future<void> methodCallHandler(MethodCall call) async {
    final dynamic args = call.arguments;
    switch (call.method) {
      case _kOnGranted:
        callback?.onGranted(args['license'], args['signature']);
        break;
      case _kOnDenied:
        callback?.onDenied();
        break;
      case _kOnError:
        callback?.onError(args['code'], args['message']);
        break;
    }
  }
}
