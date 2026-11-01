import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules a rolling week of prayer alerts using the operating system.
/// Android can therefore deliver alerts while the Flutter app is backgrounded
/// or terminated.
class PrayerNotificationService {
  PrayerNotificationService._();
  static final instance = PrayerNotificationService._();

  static const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const _enabledKey = 'prayer_notifications_enabled';
  static const _soundKey = 'prayer_notification_sound_enabled';
  static const _prayersKey = 'enabled_prayer_notifications';
  static const _firstId = 4100;
  static const _maxScheduled = 40;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;

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

  Future<({bool notifications, bool exactAlarms})> requestPermissions() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationResult = await android?.requestNotificationsPermission();
    // Prayer times are user-requested, time-sensitive alerts. Ask for the
    // Android Alarms & reminders access; schedule inexactly if declined.
    if (defaultTargetPlatform == TargetPlatform.android) {
      final exactWasAllowed =
          await android?.canScheduleExactNotifications() ?? false;
      if (!exactWasAllowed) await android?.requestExactAlarmsPermission();
      return (
        notifications:
            notificationResult ??
            await android?.areNotificationsEnabled() ??
            false,
        exactAlarms: await android?.canScheduleExactNotifications() ?? false,
      );
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    return (notifications: iosResult ?? false, exactAlarms: true);
  }

  Future<bool> canScheduleExactly() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    return await android.canScheduleExactNotifications() ?? false;
  }

  Future<bool> canReceiveNotifications() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null)
      return await android.areNotificationsEnabled() ?? false;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.checkPermissions().then(
          (settings) => settings?.isEnabled ?? false,
        ) ??
        false;
  }

  Future<({bool enabled, bool soundEnabled, Map<String, bool> prayers})>
  loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPrayers = preferences.getStringList(_prayersKey);
    final enabledPrayers = savedPrayers == null
        ? prayerNames.toSet()
        : savedPrayers.toSet().intersection(prayerNames.toSet());
    return (
      enabled: preferences.getBool(_enabledKey) ?? true,
      soundEnabled: preferences.getBool(_soundKey) ?? true,
      prayers: {
        for (final name in prayerNames) name: enabledPrayers.contains(name),
      },
    );
  }

  Future<void> saveEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, enabled);
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_soundKey, enabled);
  }

  Future<void> savePrayerEnabled(String prayer, bool enabled) async {
    if (!prayerNames.contains(prayer)) return;
    final current = await loadSettings();
    final prayers = current.prayers.entries
        .where((entry) => entry.value || (entry.key == prayer && enabled))
        .map((entry) => entry.key)
        .toSet();
    if (!enabled) prayers.remove(prayer);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_prayersKey, prayers.toList());
  }

  Future<void> refresh(
    List<(String, DateTime)> prayers, {
    required bool enabled,
    required Map<String, bool> enabledPrayers,
    required bool soundEnabled,
    required String reciter,
  }) async {
    await initialize();
    for (var i = 0; i < _maxScheduled; i++) {
      await _plugin.cancel(id: _firstId + i);
    }
    if (!enabled) return;

    final exactAllowed = await canScheduleExactly();
    final selectedReciter = reciter == 'mishary' ? 'mishary' : 'mansour';
    final soundChannel = 'prayer_adhan_${selectedReciter}_v2';
    final channelId = soundEnabled ? soundChannel : 'prayer_silent_v2';
    final soundDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        soundEnabled ? 'أذان الصلاة' : 'تنبيهات الصلاة الصامتة',
        channelDescription: 'تنبيهات عند دخول وقت الصلاة',
        importance: Importance.max,
        priority: Priority.max,
        playSound: soundEnabled,
        sound: soundEnabled
            ? RawResourceAndroidNotificationSound('adhan_$selectedReciter')
            : null,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
      // iOS displays a local alert and uses its standard alert tone. Custom
      // notification audio on iOS is restricted to short bundled sounds.
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: soundEnabled,
      ),
    );

    var id = 0;
    for (final (name, time) in prayers) {
      if (!prayerNames.contains(name) ||
          enabledPrayers[name] != true ||
          !time.isAfter(DateTime.now()))
        continue;
      try {
        await _plugin.zonedSchedule(
          id: _firstId + id,
          title: 'حان وقت الصلاة',
          body: 'حان الآن موعد صلاة ${_arabicName(name)}',
          scheduledDate: tz.TZDateTime.from(time, tz.local),
          notificationDetails: soundDetails,
          androidScheduleMode: exactAllowed
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: name,
        );
        if (++id >= _maxScheduled) break;
      } catch (error) {
        debugPrint('Could not schedule $name prayer notification: $error');
      }
    }
  }

  String _arabicName(String name) => switch (name) {
    'Fajr' => 'الفجر',
    'Dhuhr' => 'الظهر',
    'Asr' => 'العصر',
    'Maghrib' => 'المغرب',
    'Isha' => 'العشاء',
    _ => name,
  };
}
