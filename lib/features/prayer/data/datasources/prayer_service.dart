import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islami/features/prayer/domain/entities/prayer_models.dart';
export 'package:islami/features/prayer/domain/entities/prayer_models.dart';

class PrayerService {
  static final Coordinates cairo = Coordinates(30.0444, 31.2357);
  static const _names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  // ─── Popular cities ───────────────────────────────────────────────────────
  static const List<CityOption> popularCities = [
    CityOption(id: 'cairo', nameAr: 'القاهرة', nameEn: 'Cairo', lat: 30.0444, lng: 31.2357),
    CityOption(id: 'alexandria', nameAr: 'الإسكندرية', nameEn: 'Alexandria', lat: 31.2001, lng: 29.9187),
    CityOption(id: 'giza', nameAr: 'الجيزة', nameEn: 'Giza', lat: 30.0131, lng: 31.2089),
    CityOption(id: 'riyadh', nameAr: 'الرياض', nameEn: 'Riyadh', lat: 24.7136, lng: 46.6753),
    CityOption(id: 'jeddah', nameAr: 'جدة', nameEn: 'Jeddah', lat: 21.4858, lng: 39.1925),
    CityOption(id: 'mecca', nameAr: 'مكة المكرمة', nameEn: 'Mecca', lat: 21.3891, lng: 39.8579),
    CityOption(id: 'medina', nameAr: 'المدينة المنورة', nameEn: 'Medina', lat: 24.5247, lng: 39.5692),
    CityOption(id: 'dubai', nameAr: 'دبي', nameEn: 'Dubai', lat: 25.2048, lng: 55.2708),
    CityOption(id: 'abu_dhabi', nameAr: 'أبوظبي', nameEn: 'Abu Dhabi', lat: 24.4539, lng: 54.3773),
    CityOption(id: 'doha', nameAr: 'الدوحة', nameEn: 'Doha', lat: 25.2854, lng: 51.5310),
    CityOption(id: 'kuwait', nameAr: 'الكويت', nameEn: 'Kuwait City', lat: 29.3759, lng: 47.9774),
    CityOption(id: 'amman', nameAr: 'عمّان', nameEn: 'Amman', lat: 31.9454, lng: 35.9284),
    CityOption(id: 'beirut', nameAr: 'بيروت', nameEn: 'Beirut', lat: 33.8938, lng: 35.5018),
    CityOption(id: 'istanbul', nameAr: 'إسطنبول', nameEn: 'Istanbul', lat: 41.0082, lng: 28.9784),
    CityOption(id: 'ankara', nameAr: 'أنقرة', nameEn: 'Ankara', lat: 39.9334, lng: 32.8597),
  ];

  // ─── Calculation methods (only ones supported by adhan package) ──────────
  static const Map<int, String> methodLabels = {
    3: 'رابطة العالم الإسلامي (MWL)',
    5: 'الهيئة المصرية العامة للمساحة',
    4: 'أم القرى - مكة',
    2: 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
    1: 'جامعة العلوم الإسلامية - كراتشي',
    9: 'الكويت',
    10: 'قطر',
    8: 'دول الخليج',
    15: 'لجنة رؤية الهلال',
  };

  static const Map<int, CalculationMethod> _adhanMethods = {
    3: CalculationMethod.muslim_world_league,
    5: CalculationMethod.egyptian,
    4: CalculationMethod.umm_al_qura,
    2: CalculationMethod.north_america,
    1: CalculationMethod.karachi,
    9: CalculationMethod.kuwait,
    10: CalculationMethod.qatar,
    8: CalculationMethod.dubai,
    15: CalculationMethod.moon_sighting_committee,
  };

  // SharedPreferences keys
  static const _keyMethod = 'prayer_method';
  static const _keySchool = 'prayer_school'; // 0 = Shafi, 1 = Hanafi
  static const _keyUseGps = 'prayer_use_gps';
  static const _keyCityId = 'prayer_city_id';

  static Future<int> getMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMethod) ?? 5; // Egyptian default
  }

  static Future<void> setMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMethod, method);
  }

  static Future<int> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySchool) ?? 0;
  }

  static Future<void> setSchool(int school) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySchool, school);
  }

  static Future<bool> getUseGps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseGps) ?? true;
  }

  static Future<void> setUseGps(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseGps, value);
  }

  static Future<String?> getSavedCityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCityId);
  }

  static Future<void> setSavedCityId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_keyCityId);
    } else {
      await prefs.setString(_keyCityId, id);
    }
  }

  static CityOption? cityById(String? id) {
    if (id == null) return null;
    try {
      return popularCities.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns coordinates respecting manual city override.
  static Future<Coordinates> getCoordinates() async {
    final useGps = await getUseGps();
    if (!useGps) {
      final city = cityById(await getSavedCityId());
      if (city != null) return city.coordinates;
      return cairo;
    }

    // Ask permission before checking the phone's location switch. Otherwise
    // disabled Location can silently make the map appear stuck in Cairo.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PrayerLocationException(
        'اسمح للتطبيق باستخدام الموقع من إعدادات التطبيق لعرض موقعك على الخريطة.',
        settingsButtonLabel: 'إعدادات التطبيق',
        openAppSettings: true,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const PrayerLocationException(
        'لم يتم السماح بالوصول للموقع. اضغط تحديث الموقع وحاول مرة أخرى.',
      );
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const PrayerLocationException(
        'فعّل خدمة الموقع في الهاتف ثم أعد المحاولة.',
        settingsButtonLabel: 'إعدادات الموقع',
        openLocationSettings: true,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return Coordinates(position.latitude, position.longitude);
    } on PermissionDeniedException {
      final currentPermission = await Geolocator.checkPermission();
      if (currentPermission == LocationPermission.deniedForever) {
        throw const PrayerLocationException(
          'اسمح للتطبيق باستخدام الموقع من إعدادات التطبيق لعرض اتجاه القبلة بدقة.',
          settingsButtonLabel: 'إعدادات التطبيق',
          openAppSettings: true,
        );
      }
      throw const PrayerLocationException(
        'لم يتم السماح بالوصول للموقع. اضغط تحديث الموقع وحاول مرة أخرى.',
      );
    } on LocationServiceDisabledException {
      throw const PrayerLocationException(
        'فعّل خدمة الموقع في الهاتف ثم أعد المحاولة.',
        settingsButtonLabel: 'إعدادات الموقع',
        openLocationSettings: true,
      );
    } on TimeoutException {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return Coordinates(lastPosition.latitude, lastPosition.longitude);
      }
      throw const PrayerLocationException(
        'تعذر تحديد موقعك. تأكد من تشغيل الموقع وحاول مجددًا.',
        settingsButtonLabel: 'إعدادات الموقع',
        openLocationSettings: true,
      );
    }
  }

  /// Internet first (cached per day), offline calculation as fallback.
  static Future<List<PrayerInfo>> fetchTimes(
      Coordinates c,
      DateTime date,
      ) async {
    final method = await getMethod();
    final school = await getSchool();
    final day = DateFormat('dd-MM-yyyy', 'en').format(date);
    final key =
        'prayer_${c.latitude.toStringAsFixed(2)}_${c.longitude.toStringAsFixed(2)}_${method}_${school}_$day';
    final prefs = await SharedPreferences.getInstance();

    // 1) cache
    final cached = prefs.getString(key);
    if (cached != null) {
      try {
        return _parse(Map<String, dynamic>.from(jsonDecode(cached)), date);
      } catch (_) {}
    }

    // 2) internet
    try {
      final uri = Uri.https('api.aladhan.com', '/v1/timings/$day', {
        'latitude': c.latitude.toString(),
        'longitude': c.longitude.toString(),
        'method': method.toString(),
        'school': school.toString(),
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final timings =
        jsonDecode(res.body)['data']['timings'] as Map<String, dynamic>;
        final map = {for (final n in _names) n: timings[n] as String};
        await prefs.setString(key, jsonEncode(map));
        return _parse(map, date);
      }
    } catch (_) {}

    // 3) offline calculation
    return timesFor(c, date, method: method, school: school);
  }

  static List<PrayerInfo> _parse(Map<String, dynamic> map, DateTime date) {
    return _names.map((n) {
      final parts = (map[n] as String).substring(0, 5).split(':');
      return PrayerInfo(
        n,
        DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        ),
      );
    }).toList();
  }

  /// Offline fallback. Always pass method & school when possible.
  static List<PrayerInfo> timesFor(
      Coordinates coords,
      DateTime date, {
        int? method,
        int? school,
      }) {
    final m = method ?? 5;
    final s = school ?? 0;

    final calcMethod = _adhanMethods[m] ?? CalculationMethod.egyptian;
    final params = calcMethod.getParameters();
    params.madhab = s == 1 ? Madhab.hanafi : Madhab.shafi;

    final t = PrayerTimes(coords, DateComponents.from(date), params);
    return [
      PrayerInfo('Fajr', t.fajr.toLocal()),
      PrayerInfo('Dhuhr', t.dhuhr.toLocal()),
      PrayerInfo('Asr', t.asr.toLocal()),
      PrayerInfo('Maghrib', t.maghrib.toLocal()),
      PrayerInfo('Isha', t.isha.toLocal()),
    ];
  }
}
