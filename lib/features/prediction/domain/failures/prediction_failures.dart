/// Barrel re-export failure yang relevan untuk fitur prediction.
///
/// Semua failure didefinisikan di `core/error/failures.dart` agar
/// konsisten di seluruh aplikasi. File ini hanya menyediakan convenience
/// import tanpa perlu mengingat lokasi aslinya.
///
/// Penggunaan:
/// ```dart
/// import 'package:mobile_app/features/prediction/domain/failures/prediction_failures.dart';
/// ```
export 'package:mobile_app/core/error/failures.dart'
    show
        PredictionNotFoundFailure,
        PredictionTimeoutFailure,
        PredictionFailedFailure,
        FileTooLargeFailure,
        UnsupportedFileFailure,
        InvalidFileFailure,
        NoInternetFailure,
        TimeoutFailure,
        UnauthorizedFailure,
        ServerFailure,
        UnexpectedFailure;
        