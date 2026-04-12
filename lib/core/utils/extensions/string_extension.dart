extension StringExtension on String {
  /// Kapitalisasi huruf pertama setiap kata.
  String toTitleCase() => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  /// Kapitalisasi huruf pertama saja.
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Apakah string merupakan UUID v4 yang valid.
  bool get isValidUuid {
    const pattern =
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';
    return RegExp(pattern, caseSensitive: false).hasMatch(this);
  }

  /// Apakah string merupakan email yang valid (validasi ringan).
  bool get isValidEmail {
    const pattern = r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(trim());
  }

  /// Potong string dengan ellipsis jika melebihi [maxLength].
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  /// Hapus whitespace berlebih.
  String get trimmed => trim().replaceAll(RegExp(r'\s+'), ' ');
}

extension NullableStringExtension on String? {
  /// Return true jika null atau kosong setelah di-trim.
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Return fallback jika null atau kosong.
  String orElse(String fallback) =>
      isNullOrEmpty ? fallback : this!;
}
