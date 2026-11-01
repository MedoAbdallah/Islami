import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranFontOption {
  const QuranFontOption({required this.label, required this.family});

  final String label;
  final String family;
}

class QuranTypographyState {
  const QuranTypographyState({
    this.quranFontSize = 21,
    this.tafsirFontSize = 16.5,
    this.fontFamily = 'Janna',
  });

  final double quranFontSize;
  final double tafsirFontSize;
  final String fontFamily;

  QuranTypographyState copyWith({
    double? quranFontSize,
    double? tafsirFontSize,
    String? fontFamily,
  }) {
    return QuranTypographyState(
      quranFontSize: quranFontSize ?? this.quranFontSize,
      tafsirFontSize: tafsirFontSize ?? this.tafsirFontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class QuranTypographyCubit extends Cubit<QuranTypographyState> {
  QuranTypographyCubit() : super(const QuranTypographyState());

  static const fontOptions = <QuranFontOption>[
    QuranFontOption(label: 'Janna', family: 'Janna'),
    QuranFontOption(label: 'المراعي (Almarai)', family: 'Almarai'),
    QuranFontOption(label: 'أميري للقرآن (Amiri Quran)', family: 'AmiriQuran'),
    QuranFontOption(label: 'القاهرة (Cairo)', family: 'Cairo'),
    QuranFontOption(label: 'المسيري (El Messiri)', family: 'ElMessiri'),
    QuranFontOption(label: 'آي بي إم بليكس (IBM Plex Sans Arabic)', family: 'IBMPlexSansArabic'),
    QuranFontOption(label: 'نوتو نسخ عربي (Noto Naskh Arabic)', family: 'NotoNaskhArabic'),
    QuranFontOption(label: 'تجوال (Tajawal)', family: 'Tajawal'),
  ];

  static const _quranSizeKey = 'quran_reader_font_size';
  static const _tafsirSizeKey = 'quran_tafsir_font_size';
  static const _fontFamilyKey = 'quran_reader_font_family';

  SharedPreferences? _preferences;
  Timer? _saveTimer;

  Future<void> load() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      final preferences = _preferences!;
      final savedFamily = preferences.getString(_fontFamilyKey);
      final family = fontOptions.any((option) => option.family == savedFamily)
          ? savedFamily!
          : state.fontFamily;
      emit(
        state.copyWith(
          quranFontSize: preferences.getDouble(_quranSizeKey) ?? 21,
          tafsirFontSize: preferences.getDouble(_tafsirSizeKey) ?? 16.5,
          fontFamily: family,
        ),
      );
    } catch (_) {
      // Defaults remain available if preferences cannot be read.
    }
  }

  void setQuranFontSize(double value) {
    emit(state.copyWith(quranFontSize: value.clamp(16, 40).toDouble()));
    _scheduleSave();
  }

  void setTafsirFontSize(double value) {
    emit(state.copyWith(tafsirFontSize: value.clamp(14, 32).toDouble()));
    _scheduleSave();
  }

  void setFontFamily(String value) {
    if (!fontOptions.any((option) => option.family == value)) return;
    emit(state.copyWith(fontFamily: value));
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 250), _persist);
  }

  Future<void> _persist() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await preferences.setDouble(_quranSizeKey, state.quranFontSize);
    await preferences.setDouble(_tafsirSizeKey, state.tafsirFontSize);
    await preferences.setString(_fontFamilyKey, state.fontFamily);
  }

  @override
  Future<void> close() async {
    _saveTimer?.cancel();
    await _persist();
    await super.close();
  }
}



