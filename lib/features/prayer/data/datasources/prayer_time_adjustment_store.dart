import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's minute adjustments for each prayer time.
class PrayerTimeAdjustmentStore {
  static const _prefix = 'prayer_time_offset_';
  static const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  Future<Map<String, int>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return {
      for (final name in prayerNames)
        name: preferences.getInt('$_prefix$name') ?? 0,
    };
  }

  Future<void> save(String prayerName, int minutes) async {
    if (!prayerNames.contains(prayerName)) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('$_prefix$prayerName', minutes);
  }
}
