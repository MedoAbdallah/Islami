import 'package:shared_preferences/shared_preferences.dart';

import 'package:islami/core/model/sura.dart';

abstract interface class QuranLocalDataSource {
  List<Sura> loadSuras();
  Future<List<Sura>> loadRecentSuras();
  Future<void> saveRecentSura(Sura sura);
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  static const _recentKey = 'mostRecent';

  @override
  List<Sura> loadSuras() {
    Sura.generateSurasList();
    return List<Sura>.unmodifiable(Sura.suras);
  }

  @override
  Future<List<Sura>> loadRecentSuras() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_recentKey) ?? const <String>[];
    final byId = {for (final sura in loadSuras()) sura.id.toString(): sura};
    return ids.map((id) => byId[id]).whereType<Sura>().toList();
  }

  @override
  Future<void> saveRecentSura(Sura sura) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_recentKey) ?? <String>[];
    ids.removeWhere((id) => id == sura.id.toString());
    ids.insert(0, sura.id.toString());
    if (ids.length > 10) ids.removeRange(10, ids.length);
    await prefs.setStringList(_recentKey, ids);
  }
}
