import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Deteksi timezone lokal dari offset sistem — tanpa flutter_timezone
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    final locationName = _offsetToLocation(offsetHours);
    tz.setLocalLocation(tz.getLocation(locationName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  String _offsetToLocation(int offsetHours) {
    switch (offsetHours) {
      case 7:
        return 'Asia/Jakarta';   // WIB
      case 8:
        return 'Asia/Makassar';  // WITA
      case 9:
        return 'Asia/Jayapura'; // WIT
      default:
        return 'Asia/Jakarta';
    }
  }

  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'rasanusantara_channel',
        'RasaNusantara',
        channelDescription: 'Notifikasi jadwal memasak',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Konfirmasi langsung saat jadwal disimpan
  Future<void> showSavedConfirmation(
    String recipeName,
    DateTime scheduledTime,
  ) async {
    await _ensureInit();
    final formatted = DateFormat('dd MMM yyyy, HH:mm').format(scheduledTime);
    await _plugin.show(
      0,
      '✅ Jadwal Tersimpan',
      'Pengingat $recipeName dijadwalkan pada $formatted',
      _details(),
    );
  }

  /// Notifikasi terjadwal — muncul tepat waktu meski app di background
  Future<void> scheduleReminder({
    required int id,
    required String recipeName,
    required DateTime cookingTime,
  }) async {
    await _ensureInit();

    final tzTime = tz.TZDateTime.from(cookingTime, tz.local);

    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      '🍳 Waktunya Masak!',
      'Sudah waktunya memasak $recipeName. Selamat memasak!',
      tzTime,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async {
    await _ensureInit();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _ensureInit();
    await _plugin.cancelAll();
  }
}