class Validator {
  Validator._();

  // ── Email ─────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong.';
    }
    if (value.length > 255) {
      return 'Email maksimal 255 karakter.';
    }
    const pattern = r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value.trim())) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong.';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter.';
    }
    if (value.length > 128) {
      return 'Password maksimal 128 karakter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf besar.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 huruf kecil.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung minimal 1 angka.';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong.';
    }
    if (value != original) {
      return 'Password tidak cocok.';
    }
    return null;
  }

  // ── Full Name ─────────────────────────────────────────────────────────────

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 100) {
      return 'Nama lengkap maksimal 100 karakter.';
    }
    return null;
  }

  // ── Required ─────────────────────────────────────────────────────────────

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }
    return null;
  }
}
