import 'package:flutter/services.dart';
import 'package:flutter_onestore_inapp/src/onestore_channel.dart';

const _loggerChannel = MethodChannel('${OneStoreChannel.rootChannel}/base');

class OneStoreLogger {
  static Future<void> setLogLevel(LogLevel logLevel) async {
    return _loggerChannel.invokeMethod<void>('setLogLevel', logLevel.name);
  }
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}
