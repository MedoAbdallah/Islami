import 'package:adhan/adhan.dart';
import '../entities/prayer_models.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimes {
  const GetPrayerTimes(this._repository);
  final PrayerRepository _repository;
  Future<List<PrayerInfo>> call(Coordinates coordinates, DateTime date) =>
      _repository.fetchTimes(coordinates, date);
}
