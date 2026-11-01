import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

enum QuranReader {
  abdulBasit(
    'عبد الباسط عبد الصمد',
    'assets/audio/abdul_basit_audio.json',
  ),
  haniArRifai(
    'هاني الرفاعي',
    'assets/audio/hani_ar_rifai_audio.json',
  ),
  maher(
    'ماهر المعيقلي',
    'assets/audio/maher_ayah_audio.json',
  ),
  mahmoudAlHusary(
    'محمود خليل الحصري',
    'assets/audio/mahmoud_khalil_al_husary_audio.json',
  ),
  mishariAlAfasy(
    'مشاري العفاسي',
    'assets/audio/mishari_rashid_al_afasy_audio.json',
  ),
  yasserAlDosari(
    'ياسر الدوسري',
    'assets/audio/yasser_al_dosari_audio.json',
  );

  const QuranReader(this.label, this.assetPath);

  final String label;
  final String assetPath;
}

class MaherRecitation {
  MaherRecitation._();

  static final AudioPlayer _player = AudioPlayer();

  static QuranReader _selectedReader = QuranReader.maher;
  static Future<Map<String, dynamic>>? _indexFuture;

  static int? _currentSurahNumber;
  static List<int> _currentAyahNumbers = [];
  static bool _repeatAll = false;

  static QuranReader get selectedReader => _selectedReader;

  static Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream;

  static Stream<int?> get currentAyahNumberStream =>
      _player.currentIndexStream.map((index) {
        if (index == null ||
            index < 0 ||
            index >= _currentAyahNumbers.length) {
          return null;
        }

        return _currentAyahNumbers[index];
      }).distinct();

  /// يغيّر القارئ ويوقف التلاوة الحالية.
  static Future<void> selectReader(QuranReader reader) async {
    if (_selectedReader == reader) return;

    await _player.stop();

    _selectedReader = reader;
    _indexFuture = null;
    _currentSurahNumber = null;
    _currentAyahNumbers = [];
  }

  static Future<Map<String, dynamic>> _loadIndex() {
    return _indexFuture ??= _readIndex(_selectedReader);
  }

  static Future<Map<String, dynamic>> _readIndex(
      QuranReader reader,
      ) async {
    final jsonText = await rootBundle.loadString(reader.assetPath);
    final decoded = jsonDecode(jsonText);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'ملف JSON الخاص بالتلاوة لازم يكون كائن (Object).',
      );
    }

    return decoded;
  }

  /// يبدأ من الآية المختارة، مع إبقاء كل آيات السورة في قائمة التشغيل.
  /// عند تفعيل التكرار تعود القائمة من أول السورة بعد آخر آية.
  static Future<void> playSura(
      int surahNumber, {
        int startAyah = 1,
      }) async {
    final index = await _loadIndex();
    final entries = <MapEntry<int, String>>[];

    for (final entry in index.entries) {
      final value = entry.value;
      if (value is! Map) continue;

      final entrySurah = value['surah_number'];
      final entryAyah = value['ayah_number'];
      final audioUrl = value['audio_url'];

      if (entrySurah == surahNumber &&
          entryAyah is int &&
          audioUrl is String &&
          audioUrl.isNotEmpty) {
        entries.add(MapEntry(entryAyah, audioUrl));
      }
    }

    entries.sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      throw StateError(
        'لم يتم العثور على تلاوة للسورة $surahNumber.',
      );
    }

    final startIndex = entries.indexWhere(
          (entry) => entry.key >= startAyah,
    );

    if (startIndex == -1) {
      throw StateError(
        'لم يتم العثور على الآية $startAyah في السورة $surahNumber.',
      );
    }

    _currentSurahNumber = surahNumber;
    _currentAyahNumbers = entries.map((entry) => entry.key).toList();

    final playlist = ConcatenatingAudioSource(
      children: entries
          .map(
            (entry) => AudioSource.uri(Uri.parse(entry.value)),
      )
          .toList(),
    );

    await _player.setLoopMode(
      _repeatAll ? LoopMode.all : LoopMode.off,
    );

    await _player.setAudioSource(
      playlist,
      initialIndex: startIndex,
    );

    unawaited(_player.play());
  }

  static Future<void> toggleSura(int surahNumber) async {
    if (_currentSurahNumber == surahNumber && _player.playing) {
      await _player.pause();
      return;
    }

    if (_currentSurahNumber == surahNumber &&
        _player.processingState != ProcessingState.completed) {
      unawaited(_player.play());
      return;
    }

    await playSura(surahNumber);
  }

  /// يرجع لأول آية ويترك التلاوة متوقفة.
  static Future<void> returnToFirstAyahPaused() async {
    if (_currentSurahNumber == null || _currentAyahNumbers.isEmpty) return;

    await _player.pause();
    await _player.seek(Duration.zero, index: 0);
  }

  /// يعيد تشغيل السورة من أول آية.
  static Future<void> restartFromFirst() async {
    final surahNumber = _currentSurahNumber;
    if (surahNumber == null) return;

    await playSura(surahNumber, startAyah: 1);
  }

  static Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else if (_currentSurahNumber != null) {
      unawaited(_player.play());
    }
  }

  static Future<void> nextAyah() async {
    if (_currentAyahNumbers.isEmpty) return;
    await _player.seekToNext();
  }

  static Future<void> previousAyah() async {
    if (_currentAyahNumbers.isEmpty) return;

    final currentIndex = _player.currentIndex;
    if (currentIndex == null || currentIndex == 0) return;

    await _player.seek(
      Duration.zero,
      index: currentIndex - 1,
    );
  }

  /// يكرر قائمة السورة كاملة، وليس ملف الآية الحالية فقط.
  static Future<void> toggleRepeatAll() async {
    final enableRepeat = !_repeatAll;

    await _player.setLoopMode(
      enableRepeat ? LoopMode.all : LoopMode.off,
    );

    _repeatAll = enableRepeat;
  }

  static Future<void> stop() async {
    await _player.stop();
    _currentSurahNumber = null;
    _currentAyahNumbers = [];
  }

  static Future<void> dispose() => _player.dispose();
}