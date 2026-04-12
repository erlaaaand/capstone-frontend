// User failures sudah didefinisikan di core/error/failures.dart:
//
//  - UserNotFoundFailure   → user tidak ditemukan (404)
//  - ForbiddenFailure      → tidak boleh ubah profil user lain (403)
//  - ValidationFailure     → format nama/password tidak valid (400)
//  - UnauthorizedFailure   → token expired (401)
//  - NoInternetFailure     → tidak ada koneksi
//  - TimeoutFailure        → request timeout
//  - ServerFailure         → error server lainnya
//  - UnexpectedFailure     → runtime error tidak terduga
//
// File ini sebagai barrel re-export untuk kemudahan import di layer user.

export 'package:mobile_app/core/error/failures.dart'
    show
        UserNotFoundFailure,
        ForbiddenFailure,
        ValidationFailure,
        UnauthorizedFailure,
        NoInternetFailure,
        TimeoutFailure,
        ServerFailure,
        UnexpectedFailure;
        