import '../../domain/repositories/qibla_repository.dart';
import '../datasources/compass_data_source.dart';

class QiblaRepositoryImpl implements QiblaRepository {
  QiblaRepositoryImpl(this._dataSource);
  final CompassDataSource _dataSource;

  @override
  Stream<double?>? watchHeadings({
    required double latitude,
    required double longitude,
  }) => _dataSource.headings(latitude: latitude, longitude: longitude);
}
