import '../../domain/entities/quran_verse.dart';

class QuranVerseModel extends QuranVerse {
  const QuranVerseModel({required super.number, required super.text});

  static List<QuranVerseModel> parseTextLines(String content) => content
      .trim()
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList()
      .asMap()
      .entries
      .map((entry) => QuranVerseModel(number: entry.key + 1, text: entry.value))
      .toList(growable: false);
}
