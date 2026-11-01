import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

import 'package:islami/features/azkar/presentation/widgets/azkar_ui_helper.dart';

class DuaDetailsScreen extends StatefulWidget {
  static const String routeName = '/dua-details';

  final String title;
  final int number;

  const DuaDetailsScreen({
    required this.title,
    required this.number,
    super.key,
  });

  @override
  State<DuaDetailsScreen> createState() => _DuaDetailsScreenState();
}

class _DuaDetailsScreenState extends State<DuaDetailsScreen> {
  late Future<List<String>> _duasFuture;
  final ScrollController _controller = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  String get _assetPrefix =>
      'assets/duas/${widget.number.toString().padLeft(2, '0')}_';

  @override
  void initState() {
    super.initState();
    _duasFuture = _loadDuas();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    _progress.value =
    max <= 0 ? 0 : (_controller.offset / max).clamp(0.0, 1.0).toDouble();
  }

  Future<List<String>> _loadDuas() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final path = manifest.listAssets().firstWhere(
          (asset) => asset.startsWith(_assetPrefix) && asset.endsWith('.txt'),
      orElse: () => throw Exception('لا يوجد ملف دعاء يبدأ بـ $_assetPrefix'),
    );

    final content = await rootBundle.loadString(path);

    return content
        .split(RegExp(r'\r?\n\s*\r?\n'))
        .map((dua) => dua.trim())
        .where((dua) => dua.isNotEmpty)
        .toList();
  }

  void _retryLoading() {
    setState(() {
      _duasFuture = _loadDuas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: AppBar(
          backgroundColor: context.palette.background,
          foregroundColor: context.palette.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStylesHelper.largeLabelTextStyle(context,
      textColor: context.palette.primary,
            ),
          ),
          // Reading progress
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 2,
                color: context.palette.primary,
                backgroundColor: context.palette.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<String>>(
          future: _duasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: context.palette.primary),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorState(onRetry: _retryLoading);
            }

            final items = snapshot.data!;

            return ListView.separated(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return StaggeredEntrance(
                  index: index,
                  child: _DuaCard(
                    text: items[index],
                    index: index + 1,
                    total: items.length,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DuaCard extends StatefulWidget {
  final String text;
  final int index;
  final int total;

  const _DuaCard({
    required this.text,
    required this.index,
    required this.total,
  });

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _copied = false;

  Future<void> _copy() async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: Theme.of(context).brightness == Brightness.dark
              ? const [Color(0xFF1C1C1C), Color(0xFF0F0F0F)]
              : [context.palette.surface, context.palette.background],
        ),
        border: Border.all(color: context.palette.primary.withValues(alpha: 0.26)),
      ),
      child: Column(
        children: [
          // Header: index pill + copy
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 6, 0),
            child: Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.palette.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.index.toArabicDigits} من ${widget.total.toArabicDigits}',
                    style: TextStyle(
                      color: context.palette.primary,
                      fontFamily: 'Janna',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'نسخ',
                  visualDensity: VisualDensity.compact,
                  onPressed: _copy,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      _copied
                          ? Icons.check_circle_rounded
                          : Icons.copy_rounded,
                      key: ValueKey<bool>(_copied),
                      size: 20,
                      color: context.palette.primary.withValues(alpha: _copied ? 1 : 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Divider(
              height: 1,
              thickness: 1,
              color: context.palette.primary.withValues(alpha: 0.14),
            ),
          ),

          // Text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStylesHelper.largeBodyTextStyle(context,
      textColor: context.palette.onBackground,
              ).copyWith(fontSize: 18.5, height: 1.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: context.palette.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل الأدعية',
              style: TextStylesHelper.largeBodyTextStyle(context,
      textColor: context.palette.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تأكد من إضافة ملف الدعاء إلى assets/duas/',
              textAlign: TextAlign.center,
              style: TextStylesHelper.smallLabelTextStyle(context,
      textColor: context.palette.onBackground.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.palette.primary,
                side: BorderSide(color: context.palette.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


