import 'package:dio/dio.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';

/// Konversi berbagai tipe [Exception] menjadi [Failure] yang tepat.
///
/// Digunakan di setiap repository implementation, di dalam blok `catch`.
///
/// ```dart
/// } on ServerException catch (e) {
///   return Left(ErrorHandler.fromServerException(e));
/// } catch (e) {
///   return Left(ErrorHandler.fromUnknown(e));
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// Konversi [ServerException] (dari Dio response) ke [Failure].
  static Failure fromServerException(ServerException e) {
    return switch (e.statusCode) {
      400 => ValidationFailure(
          message: e.errors?.join('\n') ?? e.message,
        ),
      401 => const UnauthorizedFailure(),
      403 => const ForbiddenFailure(),
      404 => const UserNotFoundFailure(),
      409 => EmailAlreadyUsedFailure(email: _extractEmail(e.message)),
      413 => const FileTooLargeFailure(),
      422 => const UnsupportedFileFailure(),
      429 => const RateLimitFailure(),
      _   => ServerFailure(message: e.message),
    };
  }

  /// Konversi [DioException] yang belum dikonversi ke [Failure].
  static Failure fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutFailure(),
      DioExceptionType.connectionError => const NoInternetFailure(),
      _ => const UnexpectedFailure(),
    };
  }

  /// Konversi exception generik / unknown ke [Failure].
  static Failure fromUnknown(Object e) {
    if (e is NoInternetException) return const NoInternetFailure();
    if (e is TimeoutException) return const TimeoutFailure();
    if (e is StorageAccessException) return ServerFailure(message: e.message);
    if (e is InvalidFileException) return InvalidFileFailure(message: e.message);
    if (e is PredictionTimeoutException) return const PredictionTimeoutFailure();
    return const UnexpectedFailure();
  }

  static String _extractEmail(String message) {
    // Contoh message NestJS: "Email 'x@y.com' sudah digunakan"
    final match = RegExp(r"'([^']+)'").firstMatch(message);
    return match?.group(1) ?? '';
  }
}
