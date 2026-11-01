import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/model/hadeth.dart';
import 'package:islami/core/theme/app_palette.dart';

import '../../../../../core/theme/text_style_helper.dart';

String _arabicDigits(int n) {
  const western = '0123456789';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((c) {
    final i = western.indexOf(c);
    return i == -1 ? c : arabic[i];
  }).join();
}

class HadethDetailsScreen extends StatefulWidget {
  static const String routeName = '/hadeth-details';

  final Hadeth hadeth;

  const HadethDetailsScreen({required this.hadeth, super.key});

  @override
  State<HadethDetailsScreen> createState() => _HadethDetailsScreenState();
}

class _HadethDetailsScreenState extends State<HadethDetailsScreen> {
  static const double _cornerSize = 48;
  static const double _minFont = 16;
  static const double _maxFont = 30;
  static const double _fontStep = 2;

  final ScrollController _controller = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);

  double _fontSize = 20;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    _progress.value =
    max <= 0 ? 0 : (_controller.offset / max).clamp(0.0, 1.0).toDouble();
  }

  void _changeFont(double delta) {
    final next = (_fontSize + delta).clamp(_minFont, _maxFont).toDouble();
    if (next == _fontSize) return;
    HapticFeedback.selectionClick();
    setState(() => _fontSize = next);
    // Re-measure after the text has been re-laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateProgress());
  }

  Future<void> _copy() async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(
      ClipboardData(
        text: '${widget.hadeth.title}\n\n${widget.hadeth.content}',
      ),
    );
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseStyle = TextStylesHelper.largeBodyTextStyle(
      context,
      textColor: p.primary,
    ).copyWith(
      fontSize: _fontSize,
      height: 2.1,
      // No letterSpacing: it can break Arabic letter joining.
    );

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
            widget.hadeth.title,
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
        body: SafeArea(
          child: Column(
            children: [
              // Reading card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: p.primary.withValues(alpha: 0.3),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.primary.withValues(alpha: 0.1),
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
                        // Soft tint
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                p.primary.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Text, with soft fade at top and bottom edges
                        Scrollbar(
                          controller: _controller,
                          radius: const Radius.circular(8),
                          thickness: 3.5,
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (rect) => const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0, 0.04, 0.93, 1],
                            ).createShader(rect),
                            child: SingleChildScrollView(
                              controller: _controller,
                              physics: const BouncingScrollPhysics(),
                              padding:
                              const EdgeInsets.fromLTRB(28, 40, 28, 48),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                style: baseStyle,
                                child: Text(
                                  widget.hadeth.content,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Decorative corners
                        _buildCorner(alignment: Alignment.topLeft),
                        _buildCorner(
                          alignment: Alignment.topRight,
                          flipX: true,
                        ),
                        _buildCorner(
                          alignment: Alignment.bottomLeft,
                          flipY: true,
                        ),
                        _buildCorner(
                          alignment: Alignment.bottomRight,
                          flipX: true,
                          flipY: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Reader toolbar
              Container(
                height: 54,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.primary.withValues(alpha: 0.24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ToolbarButton(
                      icon: Icons.text_decrease_rounded,
                      tooltip: 'تصغير الخط',
                      onPressed: _fontSize > _minFont
                          ? () => _changeFont(-_fontStep)
                          : null,
                    ),
                    SizedBox(
                      width: 44,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            ),
                        child: Text(
                          _arabicDigits(_fontSize.round()),
                          key: ValueKey<double>(_fontSize),
                          textAlign: TextAlign.center,
                          style: TextStylesHelper.smallLabelTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    _ToolbarButton(
                      icon: Icons.text_increase_rounded,
                      tooltip: 'تكبير الخط',
                      onPressed: _fontSize < _maxFont
                          ? () => _changeFont(_fontStep)
                          : null,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: p.primary.withValues(alpha: 0.2),
                    ),
                    IconButton(
                      tooltip: 'نسخ الحديث',
                      onPressed: _copy,
                      splashRadius: 22,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _copied
                              ? Icons.check_circle_rounded
                              : Icons.copy_rounded,
                          key: ValueKey<bool>(_copied),
                          size: 22,
                          color: p.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 22,
      icon: Icon(icon, size: 22),
      color: p.primary,
      disabledColor: p.primary.withValues(alpha: 0.25),
    );
  }
}