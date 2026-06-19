import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response == null) {
      return handler.next(err);
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    final rawMessage = data is Map ? data['message'] : null;
    final String message = switch (rawMessage) {
      List()   => (rawMessage as List).join(', '),
      String() => rawMessage as String,
      _        => err.message ?? 'Terjadi kesalahan',
    };

    final List<String>? errors = rawMessage is List
        ? List<String>.from(rawMessage as List)
        : null;

    final module = data is Map ? data['module'] as String? : null;

    final exception = switch (statusCode) {
      401 => UnauthorizedException(message: message),
      403 => ForbiddenException(message: message),
      404 => NotFoundException(message: message),
      409 => ConflictException(message: message),
      413 => FileTooLargeException(message: message),
      422 => UnsupportedFileException(message: message),
      429 => RateLimitException(message: message),
      _   => ServerException(
          statusCode: statusCode,
          message: message,
          errors: errors,
          module: module,
        ),
    };

    return handler.next(
      err.copyWith(error: exception),
    );
  }
}
