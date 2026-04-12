import 'package:mobile_app/core/config/env_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Factory untuk membuat [PrettyDioLogger] sesuai config env.
///
/// Logger HANYA aktif jika [EnvConfig.enableLogging] = true.
/// Di production, ini selalu false.
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
      // Sensor Authorization header agar token tidak muncul di log
      filter: (options, args) {
        if (options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer [REDACTED]';
        }
        return true;
      },
    );
  }
}
