import 'package:flutter/services.dart';
import 'package:islami/core/model/hadeth.dart';

class HadithAssetDataSource {
  static const _assetDirectory = 'assets/hadeth/';

  Future<List<Hadeth>> loadAll() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final files = manifest.listAssets()
        .where((path) => path.startsWith(_assetDirectory) && path.endsWith('.txt'))
        .toList()..sort((a, b) {
          final order = _fileOrder(a).compareTo(_fileOrder(b));
          return order != 0 ? order : a.compareTo(b);
        });
    if (files.isEmpty) throw StateError('لم يتم العثور على ملفات أحاديث');
    final contents = await Future.wait(files.map(rootBundle.loadString));
    return List.generate(contents.length, (index) {
      final lines = contents[index].split('\n');
      if (lines.isNotEmpty && lines.first.trim().startsWith('الحد')) {
        lines.removeAt(0);
      }
      return Hadeth.fromFile(index + 1, lines.join('\n').trim());
    });
  }

  int _fileOrder(String path) {
    final match = RegExp(r'\d+').firstMatch(path.split('/').last);
    return match == null ? 1 << 30 : int.parse(match.group(0)!);
  }
}
