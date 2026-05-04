import 'package:intl/intl.dart';

class TimeConverter {
  /// Konversi lengkap dengan tanggal — untuk display umum
  static Map<String, String> convert(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    final londonOffset = _londonOffset(utc);

    return {
      'WIB': formatter.format(utc.add(const Duration(hours: 7))),
      'WITA': formatter.format(utc.add(const Duration(hours: 8))),
      'WIT': formatter.format(utc.add(const Duration(hours: 9))),
      'London': formatter.format(utc.add(londonOffset)),
    };
  }

  /// Konversi jam saja — untuk ditampilkan di schedule card
  static Map<String, String> convertShort(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final formatter = DateFormat('HH:mm');
    final londonOffset = _londonOffset(utc);

    return {
      'WIB': formatter.format(utc.add(const Duration(hours: 7))),
      'WITA': formatter.format(utc.add(const Duration(hours: 8))),
      'WIT': formatter.format(utc.add(const Duration(hours: 9))),
      'London': formatter.format(utc.add(londonOffset)),
    };
  }

  static Duration _londonOffset(DateTime utc) {
    final year = utc.year;
    final bstStart = _lastSunday(year, 3);
    final bstEnd = _lastSunday(year, 10);
    final isBst = utc.isAfter(bstStart) && utc.isBefore(bstEnd);
    return Duration(hours: isBst ? 1 : 0);
  }

  static DateTime _lastSunday(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0);
    final daysFromSunday = lastDay.weekday % 7;
    return lastDay.subtract(Duration(days: daysFromSunday));
  }
}