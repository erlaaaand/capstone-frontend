extension DateTimeExtension on DateTime {
  /// Apakah tanggal ini hari ini.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Apakah tanggal ini kemarin.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Selisih hari dari sekarang (positif = masa depan).
  int get daysFromNow => difference(DateTime.now()).inDays;

  /// Ke ISO 8601 UTC string.
  String toIso8601UtcString() => toUtc().toIso8601String();
}
