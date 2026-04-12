/// AI Health failures untuk feature ini.
///
/// Failure yang mungkin terjadi pada operasi AI health check:
/// - [AiOfflineFailure]   → AI service offline atau tidak merespons
/// - [NoInternetFailure]  → Tidak ada koneksi internet
/// - [TimeoutFailure]     → Request/stream timeout
/// - [ServerFailure]      → Error NestJS tidak terduga
/// - [UnexpectedFailure]  → Error runtime tidak terduga
export 'package:mobile_app/core/error/failures.dart'
    show
        AiOfflineFailure,
        NoInternetFailure,
        TimeoutFailure,
        ServerFailure,
        UnexpectedFailure;
        