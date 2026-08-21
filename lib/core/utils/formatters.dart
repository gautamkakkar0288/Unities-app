import 'package:intl/intl.dart';

/// Presentation formatting.
///
/// Centralised so an event's start time reads identically on a card, a detail
/// header and a notification row — and so tests can pin the wording.
class Formatters {
  const Formatters._();

  /// `Fri, 21 Aug · 6:30 pm`. Local time: the backend stores UTC, students
  /// think in campus time.
  static String eventWhen(DateTime startsUtc) {
    final local = startsUtc.toLocal();
    final day = DateFormat('EEE, d MMM').format(local);
    final time = DateFormat('h:mm a').format(local).toLowerCase();
    return '$day · $time';
  }

  /// `6:30 pm – 8:00 pm`, or a date range when the event spans days.
  static String eventDuration(DateTime startsUtc, DateTime endsUtc) {
    final start = startsUtc.toLocal();
    final end = endsUtc.toLocal();
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    final startTime = DateFormat('h:mm a').format(start).toLowerCase();
    if (sameDay) {
      final endTime = DateFormat('h:mm a').format(end).toLowerCase();
      return '$startTime – $endTime';
    }
    return '$startTime – ${DateFormat('d MMM, h:mm a').format(end).toLowerCase()}';
  }

  /// Compact relative time for notification rows: `now`, `4m`, `3h`, `2d`,
  /// then a date.
  static String relativeShort(DateTime timestampUtc, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toUtc();
    final difference = reference.difference(timestampUtc.toUtc());
    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('d MMM').format(timestampUtc.toLocal());
  }

  /// Event fees are stored in paise. Null or zero is free — said in words,
  /// because “₹0” makes students look twice.
  static String fee(int? paise) {
    if (paise == null || paise == 0) return 'Free';
    final rupees = paise / 100;
    final hasPaise = paise % 100 != 0;
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: hasPaise ? 2 : 0,
    );
    return format.format(rupees);
  }

  /// `1 member`, `24 members`, `1.2k members`.
  static String memberCount(int count) {
    final value = compactCount(count);
    return count == 1 ? '$value member' : '$value members';
  }

  static String compactCount(int count) {
    if (count < 1000) return '$count';
    if (count < 100000) {
      final thousands = count / 1000;
      final text = thousands.toStringAsFixed(thousands < 10 ? 1 : 0);
      return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text}k';
    }
    return NumberFormat.compact(locale: 'en_IN').format(count);
  }
}
