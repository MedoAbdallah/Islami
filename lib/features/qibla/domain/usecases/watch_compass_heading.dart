import '../repositories/qibla_repository.dart';

class WatchCompassHeading {
  const WatchCompassHeading(this._repository);
  final QiblaRepository _repository;
  Stream<double?>? call({required double latitude, required double longitude}) =>
      _repository.watchHeadings(latitude: latitude, longitude: longitude);
}
