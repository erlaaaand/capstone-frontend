extension StringExtension on String {
  String toTitleCase() => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidUuid {
    const pattern =
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';
    return RegExp(pattern, caseSensitive: false).hasMatch(this);
  }

  bool get isValidEmail {
    const pattern = r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(trim());
  }

  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  String get trimmed => trim().replaceAll(RegExp(r'\s+'), ' ');
}

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  String orElse(String fallback) =>
      isNullOrEmpty ? fallback : this!;
}
