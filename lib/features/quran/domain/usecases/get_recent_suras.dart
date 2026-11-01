import 'package:islami/core/model/sura.dart';
import '../repositories/quran_repository.dart';

class GetRecentSuras {
  const GetRecentSuras(this._repository);
  final QuranRepository _repository;
  Future<List<Sura>> call() => _repository.getRecentSuras();
}
