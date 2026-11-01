import 'package:islami/core/model/sura.dart';
import '../repositories/quran_repository.dart';

class GetSuras {
  const GetSuras(this._repository);
  final QuranRepository _repository;
  List<Sura> call() => _repository.getSuras();
}
