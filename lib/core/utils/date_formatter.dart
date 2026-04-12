import 'package:intl/intl.dart';

/// Formatter tanggal & waktu untuk tampilan UI.
class DateFormatter {
  DateFormatter._();

  static final _dateOnly   = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTime   = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _timeOnly   = DateFormat('HH:mm', 'id_ID');
  // static final _iso        = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

  /// Format ISO 8601 string ke tanggal. Contoh: `15 Jan 2024`
  static String toDate(String isoString) {
    final dt = _parse(isoString);
    return dt != null ? _dateOnly.format(dt.toLocal()) : '-';
  }

  /// Format ISO 8601 string ke tanggal + jam. Contoh: `15 Jan 2024, 10:30`
  static String toDateTime(String isoString) {
    final dt = _parse(isoString);
    return dt != null ? _dateTime.format(dt.toLocal()) : '-';
  }

  /// Format ISO 8601 string ke jam saja. Contoh: `10:30`
  static String toTime(String isoString) {
    final dt = _parse(isoString);
    return dt != null ? _timeOnly.format(dt.toLocal()) : '-';
  }

  /// Relatif — berapa lama yang lalu. Contoh: `2 jam lalu`, `3 hari lalu`.
  static String toRelative(String isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '-';

    final diff = DateTime.now().difference(dt.toLocal());

    if (diff.inSeconds < 60)  return 'Baru saja';
    if (diff.inMinutes < 60)  return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24)    return '${diff.inHours} jam lalu';
    if (diff.inDays < 7)      return '${diff.inDays} hari lalu';
    if (diff.inDays < 30)     return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays < 365)    return '${(diff.inDays / 30).floor()} bulan lalu';
    return '${(diff.inDays / 365).floor()} tahun lalu';
  }

  static DateTime? _parse(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }
}
