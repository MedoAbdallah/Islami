import 'package:adhan/adhan.dart';

class PrayerLocationException implements Exception {
  const PrayerLocationException(this.message, {this.settingsButtonLabel,
    this.openAppSettings = false, this.openLocationSettings = false});
  final String message;
  final String? settingsButtonLabel;
  final bool openAppSettings;
  final bool openLocationSettings;
  @override
  String toString() => message;
}

class PrayerInfo {
  const PrayerInfo(this.name, this.time);
  final String name;
  final DateTime time;
}

class CityOption {
  const CityOption({required this.id, required this.nameAr, required this.nameEn,
    required this.lat, required this.lng});
  final String id;
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  Coordinates get coordinates => Coordinates(lat, lng);
}
