import 'package:adhan/adhan.dart';
import '../../domain/entities/prayer_models.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_service.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  @override
  Coordinates get cairo => PrayerService.cairo;
  @override
  List<CityOption> get popularCities => PrayerService.popularCities;
  @override
  Map<int, String> get methodLabels => PrayerService.methodLabels;
  @override
  Future<bool> getUseGps() => PrayerService.getUseGps();
  @override
  Future<String?> getSavedCityId() => PrayerService.getSavedCityId();
  @override
  Future<Coordinates> getCoordinates() => PrayerService.getCoordinates();
  @override
  CityOption? cityById(String? id) => PrayerService.cityById(id);
  @override
  Future<List<PrayerInfo>> fetchTimes(Coordinates coordinates, DateTime date) => PrayerService.fetchTimes(coordinates, date);
  @override
  List<PrayerInfo> timesFor(Coordinates coordinates, DateTime date, {int? method, int? school}) => PrayerService.timesFor(coordinates, date, method: method, school: school);
  @override
  Future<int> getMethod() => PrayerService.getMethod();
  @override
  Future<void> setMethod(int method) => PrayerService.setMethod(method);
  @override
  Future<int> getSchool() => PrayerService.getSchool();
  @override
  Future<void> setSchool(int school) => PrayerService.setSchool(school);
  @override
  Future<void> setUseGps(bool value) => PrayerService.setUseGps(value);
  @override
  Future<void> setSavedCityId(String? id) => PrayerService.setSavedCityId(id);
}
