import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/features/quran/data/datasources/quran_bookmark_data_source.dart';
import 'package:islami/features/quran/data/datasources/reader_recitation_data_source.dart';
import 'package:islami/features/quran/presentation/cubit/quran_typography_cubit.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

import 'package:islami/features/quran/presentation/widgets/ayah_radial_menu.dart';
import 'package:islami/features/quran/presentation/widgets/reader_header_play_button.dart';

@pragma('vm:entry-point')
Map<int, Map<String, String>> _parseTafsirJson(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final ayahs = decoded['ayahs'] as List<dynamic>? ?? const [];
  final result = <int, Map<String, String>>{};

  for (final ayah in ayahs) {
    if (ayah is! Map<String, dynamic>) continue;
    final number = (ayah['ayah_number'] as num?)?.toInt();
    final tafsirs = ayah['tafsir'] as List<dynamic>? ?? const [];
    if (number == null) continue;

    final sources = <String, String>{};
    for (final item in tafsirs) {
      if (item is! Map<String, dynamic>) continue;
      final name = item['type']?.toString().trim() ?? '';
      final text = item['text']?.toString().trim() ?? '';
      if (name.isNotEmpty && text.isNotEmpty) sources[name] = text;
    }
    if (sources.isNotEmpty) result[number] = sources;
  }
  return result;
}

Future<AssetManifest>? _assetManifestFuture;

class SuraDetails extends StatefulWidget {
  static const String routeName = 'sura_details';

  final Sura sura;
  final int? initialAyahNumber;

  const SuraDetails({required this.sura, this.initialAyahNumber, super.key});

  @override
  State<SuraDetails> createState() => _SuraDetailsState();
}

class _SuraDetailsState extends State<SuraDetails>
    with TickerProviderStateMixin {
  static const double _cornerSize = 42;
  static const Duration _longPressDuration = Duration(milliseconds: 600);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _readerTextKey = GlobalKey();
  final List<TapGestureRecognizer> _ayahRecognizers = [];
  final List<Timer?> _ayahHoldTimers = [];
  final List<bool> _ayahLongPressTriggered = [];

  late Sura _currentSura;

  List<String>? _ayahs;
  Map<int, Map<String, String>> _tafsirByAyah = {};
  int? _tafsirLoadedSuraId;
  Future<Map<int, Map<String, String>>>? _tafsirLoadFuture;
  List<String> _tafsirSources = [];
  String? _selectedTafsirSource;
  static const String _tafsirPreferenceKey = 'quran_tafsir_source';

  bool _loadFailed = false;
  bool _isPlaying = false;
  bool _startingAudio = false;
  bool _hasStartedReader = false;
  bool _repeatAll = false;
  bool _changingSura = false;
  double _horizontalDragDistance = 0;

  /// Where the finger last touched an ayah (used to center the radial menu).
  Offset _lastTapPosition = Offset.zero;

  int? _currentAyahNumber;
  Set<int> _bookmarkedAyahs = {};

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<int?>? _ayahSubscription;

  late final AnimationController _pageTurnController;
  late Animation<Offset> _pageTurnAnimation;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _currentSura = widget.sura;

    _pageTurnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pageTurnAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _pageTurnController,
            curve: Curves.easeInOutCubic,
          ),
        );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _loadSuraDetails();
    unawaited(_loadBookmarks());

    _playerStateSubscription = MaherRecitation.playerStateStream.listen((
      state,
    ) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
    });

    _ayahSubscription = MaherRecitation.currentAyahNumberStream.listen((
      ayahNumber,
    ) {
      if (!mounted) return;
      setState(() => _currentAyahNumber = ayahNumber);
    });
  }

  Future<void> _loadBookmarks() async {
    final set = await QuranBookmarkService.getBookmarkedAyahs(_currentSura.id);
    if (!mounted) return;
    setState(() => _bookmarkedAyahs = set);
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final ayahText = _ayahText(ayahNumber);
    if (ayahText.isEmpty) return;

    final exists = _bookmarkedAyahs.contains(ayahNumber);

    if (exists) {
      await QuranBookmarkService.remove(_currentSura.id, ayahNumber);
      setState(() => _bookmarkedAyahs.remove(ayahNumber));
    } else {
      await QuranBookmarkService.save(
        QuranBookmark(
          suraId: _currentSura.id,
          suraNameAr: _currentSura.nameAr,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
          createdAt: DateTime.now(),
        ),
      );
      setState(() => _bookmarkedAyahs.add(ayahNumber));
    }
  }

  Future<void> _loadSuraDetails() async {
    final suraId = _currentSura.id;
    _tafsirLoadedSuraId = null;
    _tafsirLoadFuture = null;

    setState(() {
      _loadFailed = false;
      _ayahs = null;
      _tafsirByAyah = {};
      _tafsirSources = [];
    });

    try {
      final content = await rootBundle.loadString('assets/quran/$suraId.txt');
      final ayahs = content
          .trim()
          .split('\n')
          .map((ayah) => ayah.trim())
          .where((ayah) => ayah.isNotEmpty)
          .toList();

      if (!mounted || _currentSura.id != suraId) return;

      _disposeAyahRecognizers();

      _ayahRecognizers.addAll(
        List.generate(ayahs.length, (index) {
          _ayahHoldTimers.add(null);
          _ayahLongPressTriggered.add(false);

          final ayahNumber = index + 1;

          return TapGestureRecognizer()
            ..onTapDown = (details) {
              _lastTapPosition = details.globalPosition;
              _ayahLongPressTriggered[index] = false;
              _ayahHoldTimers[index]?.cancel();

              _ayahHoldTimers[index] = Timer(_longPressDuration, () {
                _ayahLongPressTriggered[index] = true;
                _toggleBookmark(ayahNumber);
              });
            }
            ..onTapUp = (_) {
              _ayahHoldTimers[index]?.cancel();
            }
            ..onTapCancel = () {
              _ayahHoldTimers[index]?.cancel();
            }
            ..onTap = () {
              _ayahHoldTimers[index]?.cancel();

              if (_ayahLongPressTriggered[index]) {
                _ayahLongPressTriggered[index] = false;
                return;
              }

              _showAyahMenu(ayahNumber);
            };
        }),
      );

      setState(() {
        _ayahs = ayahs;
        _tafsirByAyah = {};
        _tafsirSources = [];
      });

      if (widget.initialAyahNumber != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAyah(widget.initialAyahNumber!);
        });
      }
    } catch (error) {
      debugPrint('فشل تحميل السورة: $error');
      if (!mounted || _currentSura.id != suraId) return;
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _ensureTafsirLoaded() async {
    final suraId = _currentSura.id;
    if (_tafsirLoadedSuraId == suraId) return;

    final future = _tafsirLoadFuture ??= _loadTafsirData(suraId);
    final tafsirData = await future;
    if (!mounted || _currentSura.id != suraId) return;

    setState(() {
      _tafsirByAyah = tafsirData;
      _tafsirSources =
          tafsirData.values.expand((sources) => sources.keys).toSet().toList()
            ..sort();
      _tafsirLoadedSuraId = suraId;
    });
  }

  void _scrollToAyah(int ayahNumber) {
    if (!mounted || _ayahs == null || !_scrollController.hasClients) return;
    if (ayahNumber < 1 || ayahNumber > _ayahs!.length) return;

    final paragraph = _readerTextKey.currentContext?.findRenderObject();
    if (paragraph is! RenderParagraph) return;

    var textOffset = 0;
    for (var index = 0; index < ayahNumber - 1; index++) {
      textOffset += _ayahs![index].length + 1;
      final previousAyahNumber = index + 1;
      textOffset +=
          '\uFD3F${_toArabicDigits(previousAyahNumber)}\uFD3E  '.length;
    }

    final textLength = paragraph.text.toPlainText().length;
    if (textOffset >= textLength) return;

    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: textOffset, extentOffset: textOffset + 1),
    );
    if (boxes.isEmpty) return;

    final viewport = _scrollController.position.context.storageContext
        .findRenderObject();
    if (viewport is! RenderBox) return;
    final targetGlobalY = paragraph
        .localToGlobal(boxes.first.toRect().topLeft)
        .dy;
    final viewportGlobalY = viewport.localToGlobal(Offset.zero).dy;
    final delta = targetGlobalY - viewportGlobalY - 24;
    final targetOffset = (_scrollController.offset + delta)
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<Map<int, Map<String, String>>> _loadTafsirData(int suraId) async {
    try {
      final manifest = await (_assetManifestFuture ??=
          AssetManifest.loadFromAssetBundle(rootBundle));
      final prefix = 'assets/tafseer/${suraId.toString().padLeft(3, '0')}_';
      final paths = manifest
          .listAssets()
          .where((asset) => asset.startsWith(prefix) && asset.endsWith('.json'))
          .toList();
      if (paths.isEmpty) return {};

      final raw = await rootBundle.loadString(paths.first);
      return await compute(_parseTafsirJson, raw);
    } catch (_) {
      return {};
    }
  }

  String _ayahText(int ayahNumber) =>
      _ayahs != null && ayahNumber > 0 && ayahNumber <= _ayahs!.length
      ? _ayahs![ayahNumber - 1]
      : '';

  /// Opens the icon-only circular menu around the tapped ayah.
  void _showAyahMenu(int ayahNumber) {
    final ayahText = _ayahText(ayahNumber);
    if (ayahText.isEmpty) return;

    final isBookmarked = _bookmarkedAyahs.contains(ayahNumber);
    final digits = _toArabicDigits(ayahNumber);

    showAyahRadialMenu(
      context: context,
      origin: _lastTapPosition,
      centerLabel: digits,
      actions: [
        AyahRadialAction(
          icon: Icons.menu_book_rounded,
          label: 'التفسير',
          onTap: () => _showTafsir(ayahNumber),
        ),
        AyahRadialAction(
          icon: isBookmarked
              ? Icons.bookmark_remove_rounded
              : Icons.bookmark_add_rounded,
          label: isBookmarked ? 'إزالة العلامة' : 'حفظ الآية',
          highlighted: isBookmarked,
          onTap: () => _toggleBookmark(ayahNumber),
        ),
        AyahRadialAction(
          icon: Icons.copy_rounded,
          label: 'نسخ الآية',
          onTap: () =>
              Clipboard.setData(ClipboardData(text: '$ayahText  ﴿$digits﴾')),
        ),
        AyahRadialAction(
          icon: Icons.share_rounded,
          label: 'مشاركة الآية',
          onTap: () => unawaited(
            SharePlus.instance.share(
              ShareParams(
                title: '${_currentSura.nameAr} • الآية $digits',
                text: '$ayahText  ﴿$digits﴾\n${_currentSura.nameAr}',
              ),
            ),
          ),
        ),
        AyahRadialAction(
          icon: Icons.play_circle_outline_rounded,
          label: 'استماع للآية',
          onTap: () => _playFromAyah(ayahNumber),
        ),
      ],
    );
  }

  Future<void> _showTafsir(int ayahNumber) async {
    final tafsirAlreadyLoaded = _tafsirLoadedSuraId == _currentSura.id;
    if (!tafsirAlreadyLoaded) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await _ensureTafsirLoaded();
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (!mounted) return;
    final sources = _tafsirByAyah[ayahNumber] ?? const <String, String>{};
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tafsirPreferenceKey);

    final initial = sources.containsKey(saved)
        ? saved
        : (sources.containsKey(_selectedTafsirSource)
              ? _selectedTafsirSource
              : (sources.isEmpty ? null : sources.keys.first));

    if (mounted && initial != _selectedTafsirSource) {
      setState(() => _selectedTafsirSource = initial);
    }
    if (!mounted) return;

    var selected = initial;
    final ayahText = _ayahText(ayahNumber);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final p = context.palette;
            final typography = context.watch<QuranTypographyCubit>().state;
            final tafsirText = selected == null
                ? 'لا يتوفر تفسير لهذه الآية في الملف.'
                : (sources[selected] ?? 'لا يتوفر تفسير لهذه الآية في الملف.');

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.82,
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  border: Border.all(color: p.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: p.primary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${_currentSura.nameAr} • الآية ${_toArabicDigits(ayahNumber)}',
                        style: TextStylesHelper.largeLabelTextStyle(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: p.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: p.primary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                ayahText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: p.primary,
                                  fontFamily: typography.fontFamily,
                                  fontSize: typography.quranFontSize,
                                  height: 1.85,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  12,
                                ),
                                decoration: BoxDecoration(
                                  color: p.onBackground.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: p.primary.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'التفسير',
                                          style:
                                              TextStylesHelper.mediumLabelTextStyle(
                                                context,
                                              ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          tooltip: 'نسخ التفسير',
                                          onPressed: () async {
                                            await Clipboard.setData(
                                              ClipboardData(text: tafsirText),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.copy_rounded,
                                            color: p.primary.withValues(
                                              alpha: 0.85,
                                            ),
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: p.onBackground.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Text(
                                          tafsirText,
                                          style: TextStyle(
                                            color: p.onBackground,
                                            fontFamily: typography.fontFamily,
                                            fontSize: typography.tafsirFontSize,
                                            height: 1.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTafsirSettings() async {
    if (_tafsirLoadedSuraId != _currentSura.id) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        await _ensureTafsirLoaded();
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (!mounted) return;

    if (_tafsirSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا تتوفر مصادر تفسير لهذه السورة')),
      );
      return;
    }

    final p = context.palette;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: p.background,
          title: Text('مصدر التفسير', style: TextStyle(color: p.primary)),
          content: _tafsirSources.length == 1
              ? Text(
                  _tafsirSources.first,
                  style: TextStyle(color: p.onBackground),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _tafsirSources.contains(_selectedTafsirSource)
                      ? _selectedTafsirSource
                      : _tafsirSources.first,
                  dropdownColor: p.background,
                  decoration: InputDecoration(
                    labelText: 'اختر التفسير',
                    labelStyle: TextStyle(color: p.primary),
                  ),
                  items: _tafsirSources
                      .map(
                        (name) => DropdownMenuItem(
                          value: name,
                          child: Text(
                            name,
                            style: TextStyle(color: p.onBackground),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() => _selectedTafsirSource = value);
                    await (await SharedPreferences.getInstance()).setString(
                      _tafsirPreferenceKey,
                      value,
                    );
                  },
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('تم', style: TextStyle(color: p.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.delta.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final distance = _horizontalDragDistance;
    _horizontalDragDistance = 0;
    if (distance.abs() < 50) return;
    unawaited(_changeSura(distance < 0 ? -1 : 1));
  }

  Future<void> _changeSura(int direction) async {
    if (_changingSura) return;

    final suras = Sura.suras;
    final currentIndex = suras.indexWhere((sura) => sura.id == _currentSura.id);
    if (currentIndex == -1) return;

    final nextIndex = currentIndex + direction;
    if (nextIndex < 0 || nextIndex >= suras.length) return;

    setState(() => _changingSura = true);

    _pageTurnAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(direction > 0 ? 0.15 : -0.15, 0),
        ).animate(
          CurvedAnimation(
            parent: _pageTurnController,
            curve: Curves.easeInOutCubic,
          ),
        );

    await Future.wait([
      _pageTurnController.forward(from: 0),
      _fadeController.reverse(),
    ]);

    try {
      await MaherRecitation.stop();
      if (!mounted) return;

      _disposeAyahRecognizers();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      setState(() {
        _currentSura = suras[nextIndex];
        _ayahs = null;
        _loadFailed = false;
        _isPlaying = false;
        _hasStartedReader = false;
        _currentAyahNumber = null;
        _bookmarkedAyahs = {};
      });

      await _loadSuraDetails();
      await _loadBookmarks();
    } catch (error) {
      debugPrint('تعذر الانتقال بين السور: $error');
    } finally {
      if (!mounted) return;

      _pageTurnController.reset();
      await _fadeController.forward();
      setState(() => _changingSura = false);
    }
  }

  Future<void> _selectReader(QuranReader reader) async {
    if (reader == MaherRecitation.selectedReader) return;

    try {
      await MaherRecitation.selectReader(reader);
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _hasStartedReader = false;
        _currentAyahNumber = null;
      });
    } catch (error) {
      debugPrint('تعذر تغيير القارئ: $error');
    }
  }

  Future<void> _toggleSura() async {
    if (_startingAudio || _changingSura) return;
    setState(() => _startingAudio = true);

    try {
      await MaherRecitation.toggleSura(_currentSura.id);
      if (mounted) setState(() => _hasStartedReader = true);
    } catch (error) {
      debugPrint('تعذر تشغيل أو إيقاف التلاوة: $error');
    } finally {
      if (mounted) setState(() => _startingAudio = false);
    }
  }

  Future<void> _playFromAyah(int ayahNumber) async {
    if (_startingAudio || _changingSura) return;
    setState(() => _startingAudio = true);

    try {
      await MaherRecitation.playSura(_currentSura.id, startAyah: ayahNumber);
      if (mounted) setState(() => _hasStartedReader = true);
    } catch (error) {
      debugPrint('تعذر تشغيل الآية $ayahNumber: $error');
    } finally {
      if (mounted) setState(() => _startingAudio = false);
    }
  }

  Future<void> _restartFromFirst() async {
    try {
      await MaherRecitation.restartFromFirst();
    } catch (error) {
      debugPrint('تعذر إعادة السورة من البداية: $error');
    }
  }

  Future<void> _toggleRepeat() async {
    try {
      await MaherRecitation.toggleRepeatAll();
      if (mounted) setState(() => _repeatAll = !_repeatAll);
    } catch (error) {
      debugPrint('تعذر تغيير وضع التكرار: $error');
    }
  }

  void _disposeAyahRecognizers() {
    for (final timer in _ayahHoldTimers) {
      timer?.cancel();
    }
    _ayahHoldTimers.clear();
    _ayahLongPressTriggered.clear();

    for (final recognizer in _ayahRecognizers) {
      recognizer.dispose();
    }
    _ayahRecognizers.clear();
  }

  @override
  void dispose() {
    _pageTurnController.dispose();
    _fadeController.dispose();
    _playerStateSubscription?.cancel();
    _ayahSubscription?.cancel();
    _disposeAyahRecognizers();
    _scrollController.dispose();
    unawaited(MaherRecitation.stop());
    super.dispose();
  }

  String _toArabicDigits(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((char) => digits[int.parse(char)])
        .join();
  }

  TextSpan _buildSuraTextSpan(QuranTypographyState typography) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // tealAccent is unreadable on a light background, so use a deeper teal.
    final savedTextColor = isDark ? Colors.tealAccent : Colors.teal.shade800;
    final savedBackground = Colors.teal.withValues(alpha: isDark ? 0.35 : 0.22);
    final playingTextColor = isDark
        ? const Color(0xFF80CBC4)
        : const Color(0xFF00796B);

    final baseStyle =
        TextStylesHelper.largeBodyTextStyle(
          context,
          textColor: p.primary,
        ).copyWith(
          fontFamily: typography.fontFamily,
          fontSize: typography.quranFontSize,
          height: 2.15,
        );

    final spans = <InlineSpan>[];

    for (var i = 0; i < _ayahs!.length; i++) {
      final ayahNumber = i + 1;
      final isCurrentAyah = _currentAyahNumber == ayahNumber;
      final isBookmarkedAyah = _bookmarkedAyahs.contains(ayahNumber);

      final backgroundColor = isBookmarkedAyah
          ? savedBackground
          : Colors.transparent;

      final ayahStyle = baseStyle.copyWith(
        color: isCurrentAyah && !isBookmarkedAyah
            ? playingTextColor
            : baseStyle.color,
        backgroundColor: backgroundColor,
      );

      spans.add(
        TextSpan(
          text: '${_ayahs![i]} ',
          style: ayahStyle,
          recognizer: _ayahRecognizers[i],
        ),
      );

      // Saved ayahs keep their background marker; the playing ayah uses a
      // contrasting text color without adding a background highlight.
      spans.add(
        TextSpan(
          text: '\uFD3F${_toArabicDigits(ayahNumber)}\uFD3E  ',
          style: baseStyle.copyWith(
            fontSize: typography.quranFontSize * 0.76,
            color: isBookmarkedAyah
                ? savedTextColor
                : isCurrentAyah
                ? playingTextColor
                : p.primary.withValues(alpha: 0.7),
            backgroundColor: backgroundColor,
          ),
          recognizer: _ayahRecognizers[i],
        ),
      );
    }

    return TextSpan(children: spans);
  }

  Widget _buildCorner({
    required Alignment alignment,
    bool flipX = false,
    bool flipY = false,
  }) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Transform.flip(
          flipX: flipX,
          flipY: flipY,
          child: Opacity(
            opacity: 0.9,
            child: Image.asset(AppImages.imgLeftCorner, width: _cornerSize),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.background,
        border: Border(
          top: BorderSide(color: p.primary.withValues(alpha: 0.25)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AudioButton(
                icon: Icons.stop_rounded,
                tooltip: 'العودة لأول آية مع الإيقاف',
                onPressed: () => MaherRecitation.returnToFirstAyahPaused(),
              ),
              _AudioButton(
                icon: Icons.fast_rewind_rounded,
                tooltip: 'إعادة السورة من البداية',
                onPressed: _restartFromFirst,
              ),
              _PlayButton(
                isPlaying: _isPlaying,
                isLoading: _startingAudio,
                onPressed: () => MaherRecitation.togglePlayPause(),
              ),
              _AudioButton(
                icon: Icons.skip_next_rounded,
                tooltip: 'الآية التالية',
                onPressed: () => MaherRecitation.nextAyah(),
              ),
              _AudioButton(
                icon: Icons.repeat_rounded,
                tooltip: 'تكرار السورة',
                isActive: _repeatAll,
                onPressed: _toggleRepeat,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    final p = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: p.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل السورة',
              style: TextStylesHelper.largeBodyTextStyle(
                context,
                textColor: p.primary,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _loadSuraDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: p.primary,
                side: BorderSide(color: p.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(QuranTypographyState typography) {
    final p = context.palette;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: p.primary.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: p.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Scrollbar(
              controller: _scrollController,
              radius: const Radius.circular(8),
              thickness: 3.5,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                physics: const BouncingScrollPhysics(),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    key: _readerTextKey,
                    _buildSuraTextSpan(typography),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            _buildCorner(alignment: Alignment.topLeft),
            _buildCorner(alignment: Alignment.topRight, flipX: true),
            _buildCorner(alignment: Alignment.bottomLeft, flipY: true),
            _buildCorner(
              alignment: Alignment.bottomRight,
              flipX: true,
              flipY: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    final p = context.palette;

    return PopupMenuButton<String>(
      tooltip: 'إعدادات',
      icon: Icon(Icons.settings_rounded, color: p.primary),
      color: p.background,
      onSelected: (value) {
        if (value == 'reader') _showReaderBottomSheet();
        if (value == 'tafsir') _showTafsirSettings();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'tafsir',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.menu_book_rounded, color: p.primary),
            title: Text(
              'مصدر التفسير',
              style: TextStyle(color: p.onBackground),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'reader',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.record_voice_over_rounded, color: p.primary),
            title: Text(
              'اختيار القارئ',
              style: TextStyle(color: p.onBackground),
            ),
          ),
        ),
      ],
    );
  }

  void _showReaderBottomSheet() {
    final p = context.palette;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: p.background,
          title: Text('اختيار القارئ', style: TextStyle(color: p.primary)),
          content: DropdownButtonFormField<QuranReader>(
            initialValue: MaherRecitation.selectedReader,
            dropdownColor: p.background,
            decoration: InputDecoration(
              labelText: 'اختر القارئ',
              labelStyle: TextStyle(color: p.primary),
            ),
            items: QuranReader.values
                .map(
                  (reader) => DropdownMenuItem(
                    value: reader,
                    child: Text(
                      reader.label,
                      style: TextStyle(color: p.onBackground),
                    ),
                  ),
                )
                .toList(),
            onChanged: (reader) async {
              if (reader == null) return;
              Navigator.pop(dialogContext);
              await _selectReader(reader);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('تم', style: TextStyle(color: p.primary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final typography = context.watch<QuranTypographyCubit>().state;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                _currentSura.nameAr,
                style: TextStylesHelper.largeLabelTextStyle(context),
              ),
              const SizedBox(height: 2),
              Text(
                'القارئ: ${MaherRecitation.selectedReader.label} • '
                'اضغط مطولًا لحفظ الآية',
                style: TextStyle(
                  fontSize: 11.5,
                  color: p.primary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          actions: [
            _buildSettingsMenu(),
            ReaderHeaderPlayButton(
              tooltip: _isPlaying ? 'إيقاف مؤقت' : 'تشغيل السورة',
              isPlaying: _isPlaying,
              isLoading: _startingAudio,
              onPressed: _startingAudio || _changingSura ? null : _toggleSura,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => _horizontalDragDistance = 0,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _pageTurnAnimation,
                child: _loadFailed
                    ? _buildError()
                    : _ayahs == null
                    ? Center(child: CircularProgressIndicator(color: p.primary))
                    : _buildContent(typography),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _hasStartedReader && _ayahs != null && !_loadFailed
            ? _buildAudioControls()
            : null,
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isActive;

  const _AudioButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? p.primary : p.primary.withValues(alpha: 0.85),
        size: 26,
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: isPlaying ? 'إيقاف مؤقت' : 'تشغيل التلاوة',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(p.primary, Colors.white, isDark ? 0.5 : 0.12)!,
                p.primary,
                Color.lerp(p.primary, Colors.black, 0.2)!,
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: .48)),
          ),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: p.onPrimary,
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 30,
                      color: p.onPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
