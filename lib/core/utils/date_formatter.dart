import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateOnly = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _timeOnly = DateFormat('HH:mm', 'id_ID');

  static final _dateOnlyFallback = DateFormat('dd MMM yyyy');
  static final _dateTimeFallback = DateFormat('dd MMM yyyy, HH:mm');
  static final _timeOnlyFallback = DateFormat('HH:mm');

  static String toDate(String isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '-';
    return _safeFormat(_dateOnly, _dateOnlyFallback, dt.toLocal());
  }

  static String toDateTime(String isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '-';
    return _safeFormat(_dateTime, _dateTimeFallback, dt.toLocal());
  }

  static String toTime(String isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '-';
    return _safeFormat(_timeOnly, _timeOnlyFallback, dt.toLocal());
  }

  static String toRelative(String isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '-';

    final diff = DateTime.now().difference(dt.toLocal());

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bulan lalu';
    return '${(diff.inDays / 365).floor()} tahun lalu';
  }

  static DateTime? _parse(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  static String _safeFormat(
    DateFormat primary,
    DateFormat fallback,
    DateTime value,
  ) {
    try {
      return primary.format(value);
    } catch (_) {
      return fallback.format(value);
    }
  }
}