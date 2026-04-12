/// Storage-related failures untuk feature ini.
///
/// Semua failure generik sudah didefinisikan di [core/error/failures.dart].
/// File ini me-re-export failure yang relevan agar import di dalam feature
/// tidak perlu selalu menunjuk ke core, sekaligus menjadi dokumentasi
/// failure apa saja yang mungkin muncul di storage feature.
///
/// Failure yang mungkin terjadi pada operasi storage:
/// - [FileTooLargeFailure]   → File > 5MB (HTTP 413)
/// - [UnsupportedFileFailure] → Format bukan JPG/PNG/WebP (HTTP 422)
/// - [InvalidFileFailure]    → File kosong, corrupt, atau tidak lolos validasi lokal
/// - [NoInternetFailure]     → Tidak ada koneksi internet
/// - [TimeoutFailure]        → Request timeout saat upload
/// - [UnauthorizedFailure]   → Token expired saat upload (HTTP 401)
/// - [ServerFailure]         → Error server tidak terduga
/// - [UnexpectedFailure]     → Error runtime tidak terduga
export 'package:mobile_app/core/error/failures.dart'
    show
        FileTooLargeFailure,
        UnsupportedFileFailure,
        InvalidFileFailure,
        NoInternetFailure,
        TimeoutFailure,
        UnauthorizedFailure,
        ServerFailure,
        UnexpectedFailure;
        