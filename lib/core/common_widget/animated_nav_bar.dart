import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/theme/app_palette.dart';

class NavBarItem {
  final String label;
  final String icon; // asset path
  final double iconSize;

  const NavBarItem({
    required this.label,
    required this.icon,
    this.iconSize = 22,
  });
}

/// Floating bottom navigation bar with a sliding accent indicator,
/// animated icon / label colors, a subtle icon lift + scale and haptic feedback.
/// Direction-aware (works in RTL and LTR) and theme-aware (dark / light).
class AnimatedNavBar extends StatelessWidget {
  final List<NavBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AnimatedNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  static const Duration _duration = Duration(milliseconds: 380);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF171717).withValues(alpha: 0.97)
              : p.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: p.primary.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Sliding indicator
                AnimatedPositionedDirectional(
                  duration: _duration,
                  curve: _curve,
                  start: selectedIndex * itemWidth,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(p.primary, Colors.white, isDark ? 0.35 : 0.12)!,
                            p.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: p.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Items
                Row(
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: _NavItem(
                        item: items[index],
                        selected: index == selectedIndex,
                        onTap: () {
                          if (index == selectedIndex) return;
                          HapticFeedback.selectionClick();
                          onTap(index);
                        },
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final inactiveColor = p.primary.withValues(alpha: 0.7);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          splashColor: p.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: selected ? 1 : 0),
            duration: AnimatedNavBar._duration,
            curve: AnimatedNavBar._curve,
            builder: (context, t, _) {
              // Selected sits on the accent indicator, so it uses onPrimary.
              final color = Color.lerp(inactiveColor, p.onPrimary, t)!;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, -1.5 * t),
                    child: Transform.scale(
                      scale: 1 + 0.12 * t,
                      child: ImageIcon(
                        AssetImage(item.icon),
                        size: item.iconSize,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'Janna',
                      fontSize: 10.5,
                      height: 1.1,
                      fontWeight: FontWeight.lerp(
                        FontWeight.w500,
                        FontWeight.w700,
                        t,
                      ),
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
