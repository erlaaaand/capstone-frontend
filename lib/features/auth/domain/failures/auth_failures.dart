// Auth failures sudah didefinisikan di core/error/failures.dart:
//
//  - InvalidCredentialsFailure   → email/password salah (401 login)
//  - UnauthorizedFailure         → token expired / tidak ada
//  - EmailAlreadyUsedFailure     → konflik email (409 register)
//  - ValidationFailure           → format email/password salah (400)
//  - RateLimitFailure            → 429 rate limit
//  - NoInternetFailure           → tidak ada koneksi
//  - ServerFailure               → error server lainnya
//
// File ini sebagai barrel re-export untuk kemudahan import di layer auth.

export 'package:mobile_app/core/error/failures.dart'
    show
        InvalidCredentialsFailure,
        UnauthorizedFailure,
        EmailAlreadyUsedFailure,
        ValidationFailure,
        RateLimitFailure,
        NoInternetFailure,
        TimeoutFailure,
        ServerFailure,
        UnexpectedFailure;
