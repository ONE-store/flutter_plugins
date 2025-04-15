import 'onestore_base.dart';

class OneStoreLogger {
  static Future<void> setLogLevel(LogLevel logLevel) async {
    return baseChannel.invokeMethod<void>('setLogLevel', logLevel.name);
  }
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}
