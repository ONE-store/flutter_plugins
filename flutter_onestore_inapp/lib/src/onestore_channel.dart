import 'dart:io';
import 'package:flutter/services.dart';

abstract class OneStoreChannel {
  static const rootChannel = 'com.onestorecorp.sdk.flutter.plugins';
  late MethodChannel _channel;

  MethodChannel get channel => _channel;

  OneStoreChannel(String channelName) {
    if (!Platform.isAndroid) {
      throw PlatformException(code: '-1', message: 'Not supported platform.');
    }

    _channel = MethodChannel('$rootChannel/$channelName');
  }
}
