// lib/core/network/logging_interceptor.dart
import 'package:mobile_app/core/config/env_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LoggingInterceptor {
  LoggingInterceptor._();

  static PrettyDioLogger? create() {
    if (!EnvConfig.enableLogging) return null;

    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: false,
      maxWidth: 90,
    );
  }
}