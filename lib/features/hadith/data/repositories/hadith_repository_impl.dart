import 'package:islami/core/model/hadeth.dart';
import '../../domain/repositories/hadith_repository.dart';
import '../datasources/hadith_asset_data_source.dart';

class HadithRepositoryImpl implements HadithRepository {
  HadithRepositoryImpl(this._dataSource);
  final HadithAssetDataSource _dataSource;
  @override
  Future<List<Hadeth>> getAll() => _dataSource.loadAll();
}
