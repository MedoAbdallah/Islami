import 'package:islami/core/model/sura.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl(this._localDataSource);
  final QuranLocalDataSource _localDataSource;

  @override
  List<Sura> getSuras() => _localDataSource.loadSuras();

  @override
  Future<List<Sura>> getRecentSuras() => _localDataSource.loadRecentSuras();

  @override
  Future<void> addRecentSura(Sura sura) =>
      _localDataSource.saveRecentSura(sura);
}
