import 'package:adhan/adhan.dart';
import '../entities/prayer_models.dart';

abstract interface class PrayerRepository {
  Coordinates get cairo;
  List<CityOption> get popularCities;
  Map<int, String> get methodLabels;
  Future<bool> getUseGps();
  Future<String?> getSavedCityId();
  Future<Coordinates> getCoordinates();
  CityOption? cityById(String? id);
  Future<List<PrayerInfo>> fetchTimes(Coordinates coordinates, DateTime date);
  List<PrayerInfo> timesFor(Coordinates coordinates, DateTime date, {int? method, int? school});
  Future<int> getMethod();
  Future<void> setMethod(int method);
  Future<int> getSchool();
  Future<void> setSchool(int school);
  Future<void> setUseGps(bool value);
  Future<void> setSavedCityId(String? id);
}
