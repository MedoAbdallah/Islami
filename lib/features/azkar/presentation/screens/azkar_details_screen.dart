import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/theme/app_palette.dart';

import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/azkar/presentation/widgets/azkar_ui_helper.dart';

class AzkarDetailsScreen extends StatefulWidget {
  final String title;
  final int number;

  const AzkarDetailsScreen({
    super.key,
    required this.title,
    required this.number,
  });

  @override
  State<AzkarDetailsScreen> createState() => _AzkarDetailsScreenState();
}

class _AzkarDetailsScreenState extends State<AzkarDetailsScreen> {
  late Future<List<String>> _future = _load();
  final ScrollController _controller = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
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

  Future<List<String>> _load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final prefix =
        'assets/azkar/${widget.number.toString().padLeft(2, '0')}_';

    final path = manifest.listAssets().firstWhere(
          (p) => p.startsWith(prefix) && p.endsWith('.txt'),
      orElse: () => throw Exception('لا يوجد ملف أذكار يبدأ بـ $prefix'),
    );

    final text = await rootBundle.loadString(path);

    return text
        .split(RegExp(r'\r?\n\s*\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStylesHelper.largeLabelTextStyle(context),
          ),
          // Reading progress
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 2,
                color: p.primary,
                backgroundColor: p.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<String>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: p.primary),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorState(onRetry: _retry);
            }

            final items = snapshot.data!;

            return ListView.separated(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                return StaggeredEntrance(
                  index: i,
                  child: _DhikrCard(
                    text: items[i],
                    index: i + 1,
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

class _DhikrCard extends StatefulWidget {
  final String text;
  final int index;
  final int total;

  const _DhikrCard({
    required this.text,
    required this.index,
    required this.total,
  });

  @override
  State<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<_DhikrCard> {
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
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [Color(0xFF1C1C1C), Color(0xFF0F0F0F)]
              : [p.surface, p.background],
        ),
        border: Border.all(color: p.primary.withValues(alpha: 0.26)),
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
                    color: p.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.index.toArabicDigits} من ${widget.total.toArabicDigits}',
                    style: TextStyle(
                      color: p.primary,
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
                      color: p.primary.withValues(alpha: _copied ? 1 : 0.7),
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
              color: p.primary.withValues(alpha: 0.14),
            ),
          ),

          // Text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStylesHelper.largeBodyTextStyle(context)
                  .copyWith(fontSize: 18.5, height: 1.95),
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
    final p = context.palette;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: p.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'تعذر تحميل المحتوى',
            style: TextStylesHelper.largeBodyTextStyle(
              context,
              textColor: p.primary,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('إعادة المحاولة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.primary,
              side: BorderSide(color: p.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}