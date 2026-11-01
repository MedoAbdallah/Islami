import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/theme/app_palette.dart';

import '../../features/dua/presentation/widgets/dua_card_widget.dart';
import '../../features/azkar/presentation/widgets/azkar_card.dart';
import '../theme/text_style_helper.dart';

class AzkarDuaSectionWidget extends StatefulWidget {
  const AzkarDuaSectionWidget({super.key});

  @override
  State<AzkarDuaSectionWidget> createState() => _AzkarDuaSectionWidgetState();
}

class _AzkarDuaSectionWidgetState extends State<AzkarDuaSectionWidget> {
  bool _showDuas = false;

  void _select(bool showDuas) {
    if (_showDuas == showDuas) return;
    HapticFeedback.selectionClick();
    setState(() => _showDuas = showDuas);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.palette.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'الأذكار والأدعية',
                  style: TextStylesHelper.largeBodyTextStyle(context),
                ),
              ],
            ),
          ),

          // Sliding segmented toggle
          _SegmentedToggle(
            showDuas: _showDuas,
            onChanged: _select,
          ),

          const SizedBox(height: 18),

          // Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, if (current != null) current],
            ),
            transitionBuilder: (child, animation) {
              // Content slides slightly in the direction of the tab change.
              final dx = _showDuas ? -0.05 : 0.05;
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(dx, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _showDuas
                ? const DuaCardWidget(key: ValueKey('duas'))
                : const AzkarCardWidget(key: ValueKey('azkar')),
          ),
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final bool showDuas;
  final ValueChanged<bool> onChanged;

  const _SegmentedToggle({required this.showDuas, required this.onChanged});

  static const Duration _duration = Duration(milliseconds: 340);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.primary.withValues(alpha: 0.24)),
      ),
      child: Stack(
        children: [
          // Sliding accent indicator (direction-aware)
          AnimatedAlign(
            duration: _duration,
            curve: _curve,
            alignment: AlignmentDirectional(showDuas ? 1 : -1, 0),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(p.primary, Colors.white, 0.35)!,
                      p.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: p.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Labels
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  title: 'الأذكار',
                  icon: Icons.menu_book_rounded,
                  selected: !showDuas,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _SegmentButton(
                  title: 'الأدعية',
                  icon: Icons.volunteer_activism_rounded,
                  selected: showDuas,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Selected sits on the accent indicator -> onPrimary.
    // Unselected sits on the toggle background -> onBackground.
    final target = selected
        ? p.onPrimary
        : p.onBackground.withValues(alpha: 0.85);

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: p.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: target),
            duration: _SegmentedToggle._duration,
            curve: _SegmentedToggle._curve,
            builder: (context, color, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.12 : 1,
                    duration: _SegmentedToggle._duration,
                    curve: _SegmentedToggle._curve,
                    child: Icon(icon, size: 21, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStylesHelper.mediumBodyTextStyle(
                      context,
                      textColor: color ?? target,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
