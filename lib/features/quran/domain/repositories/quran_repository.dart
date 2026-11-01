import 'package:islami/core/model/sura.dart';

abstract interface class QuranRepository {
  List<Sura> getSuras();
  Future<List<Sura>> getRecentSuras();
  Future<void> addRecentSura(Sura sura);
}
