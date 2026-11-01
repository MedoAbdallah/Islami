import 'package:islami/core/model/sura.dart';
import '../repositories/quran_repository.dart';

class AddRecentSura {
  const AddRecentSura(this._repository);
  final QuranRepository _repository;
  Future<void> call(Sura sura) => _repository.addRecentSura(sura);
}
