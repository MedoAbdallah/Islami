import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Keeps a rolling seven-day set so date/location changes can replace it.
class PrayerNotificationService {
  PrayerNotificationService._();
  static final PrayerNotificationService instance =
  PrayerNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  static const _firstId = 4100;
  static const _maxScheduled = 40;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (error) {
      debugPrint('Could not read device time zone; using local zone: $error');
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
  }

  Future<void> requestPermissions() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();
    await android?.requestNotificationsPermission();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
    >();
    await ios?.requestPermissions(alert: true, badge: false, sound: true);
  }

  Future<void> refresh(
      List<(String, DateTime)> prayers, {
        required bool soundEnabled,
      }) async {
    await initialize();
    for (var i = 0; i < _maxScheduled; i++) {
      await _plugin.cancel(id: _firstId + i);
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        soundEnabled ? 'prayer_times_sound' : 'prayer_times_silent',
        soundEnabled ? 'مواقيت الصلاة' : 'تنبيهات الصلاة الصامتة',
        channelDescription: 'تنبيهات عند دخول وقت الصلاة',
        importance: Importance.high,
        priority: Priority.high,
        playSound: soundEnabled,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: soundEnabled,
      ),
    );

    var id = 0;
    final now = DateTime.now();
    for (final (name, time) in prayers) {
      if (!time.isAfter(now)) continue;
      try {
        await _plugin.zonedSchedule(
          id: _firstId + id,
          title: 'حان وقت الصلاة',
          body: 'حان الآن موعد صلاة $name',
          scheduledDate: tz.TZDateTime.from(time, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: name,
        );
        id++;
        if (id == _maxScheduled) break;
      } catch (error) {
        debugPrint('Could not schedule prayer notification: $error');
      }
    }
  }
}
