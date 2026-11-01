import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuranBookmark {
  final int suraId;
  final String suraNameAr;
  final int ayahNumber;
  final String ayahText;
  final DateTime createdAt;

  const QuranBookmark({
    required this.suraId,
    required this.suraNameAr,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
  });

  String get key => '${suraId}_$ayahNumber';

  Map<String, dynamic> toJson() => {
    'suraId': suraId,
    'suraNameAr': suraNameAr,
    'ayahNumber': ayahNumber,
    'ayahText': ayahText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QuranBookmark.fromJson(Map<String, dynamic> json) {
    return QuranBookmark(
      suraId: json['suraId'] as int,
      suraNameAr: json['suraNameAr'] as String,
      ayahNumber: json['ayahNumber'] as int,
      ayahText: json['ayahText'] as String,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  QuranBookmark copyWith({String? note}) {
    return QuranBookmark(
      suraId: suraId,
      suraNameAr: suraNameAr,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      createdAt: createdAt,
    );
  }
}

class QuranBookmarkService {
  static const _storageKey = 'quran_bookmarks_v2';

  static Future<List<QuranBookmark>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map(
          (e) => QuranBookmark.fromJson(jsonDecode(e) as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<Set<int>> getBookmarkedAyahs(int suraId) async {
    final all = await getAll();
    return all
        .where((b) => b.suraId == suraId)
        .map((b) => b.ayahNumber)
        .toSet();
  }

  static Future<QuranBookmark?> getBookmark(int suraId, int ayahNumber) async {
    final all = await getAll();
    try {
      return all.firstWhere(
        (b) => b.suraId == suraId && b.ayahNumber == ayahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(QuranBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((b) => b.key == bookmark.key);
    all.insert(0, bookmark);
    await prefs.setStringList(
      _storageKey,
      all.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  static Future<void> remove(int suraId, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((b) => b.suraId == suraId && b.ayahNumber == ayahNumber);
    await prefs.setStringList(
      _storageKey,
      all.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  static Future<void> updateNote(
    int suraId,
    int ayahNumber,
    String? note,
  ) async {
    final existing = await getBookmark(suraId, ayahNumber);
    if (existing == null) return;
    await save(
      existing.copyWith(note: note?.trim().isEmpty == true ? null : note),
    );
  }
}
