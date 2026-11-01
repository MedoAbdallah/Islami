import 'package:islami/core/model/hadeth.dart';
import '../repositories/hadith_repository.dart';

class GetHadith {
  const GetHadith(this._repository);
  final HadithRepository _repository;
  Future<List<Hadeth>> call() => _repository.getAll();
}
