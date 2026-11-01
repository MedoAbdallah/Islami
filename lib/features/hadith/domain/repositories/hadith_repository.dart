import 'package:islami/core/model/hadeth.dart';

abstract interface class HadithRepository {
  Future<List<Hadeth>> getAll();
}
