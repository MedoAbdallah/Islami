import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/theme/app_palette.dart';

class AyahRadialAction {
  final IconData icon;
  final String label; // tooltip / accessibility only
  final VoidCallback onTap;

  final bool highlighted;

  const AyahRadialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });
}

/// Compact icon-only circular menu centered on [origin] (the tap position).
Future<void> showAyahRadialMenu({
  required BuildContext context,
  required Offset origin,
  required String centerLabel,
  required List<AyahRadialAction> actions,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'إغلاق',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 280),
    // The menu animates itself, so skip the default fade of the whole page.
    transitionBuilder: (_, __, ___, child) => child,
    pageBuilder: (_, animation, __) => _AyahRadialMenu(
      origin: origin,
      animation: animation,
      centerLabel: centerLabel,
      actions: actions,
    ),
  );
}

class _AyahRadialMenu extends StatelessWidget {
  final Offset origin;
  final Animation<double> animation;
  final String centerLabel;
  final List<AyahRadialAction> actions;

  const _AyahRadialMenu({
    required this.origin,
    required this.animation,
    required this.centerLabel,
    required this.actions,
  });

  // Tight layout
  static const double _radius = 50; // center -> button centers
  static const double _buttonSize = 40;
  static const double _centerSize = 30;

  void _select(BuildContext context, AyahRadialAction action) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    action.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final p = context.palette;

    // Keep every button on screen, even when tapping near an edge.
    const extent = _radius + _buttonSize / 2 + 10;
    final minX = extent;
    final maxX = math.max(minX, size.width - extent);
    final minY = media.padding.top + extent;
    final maxY = math.max(minY, size.height - media.padding.bottom - extent);

    final center = Offset(
      origin.dx.clamp(minX, maxX).toDouble(),
      origin.dy.clamp(minY, maxY).toDouble(),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final v = animation.value.clamp(0.0, 1.0).toDouble();
          final t = Curves.easeOutCubic.transform(v);

          return SizedBox.expand(
            child: Stack(
              children: [
                // Center badge (ayah number) - no ring behind the buttons
                Positioned(
                  left: center.dx - _centerSize / 2,
                  top: center.dy - _centerSize / 2,
                  width: _centerSize,
                  height: _centerSize,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: t,
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * t,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.lerp(
                                  p.primary,
                                  Colors.white,
                                  Theme.of(context).brightness == Brightness.dark
                                      ? 0.4
                                      : 0.12,
                                )!,
                                p.primary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: p.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Text(
                            centerLabel,
                            style: TextStyle(
                              color: p.onPrimary,
                              fontFamily: 'Janna',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Action buttons
                for (var i = 0; i < actions.length; i++)
                  _buildButton(context, i, center, v),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, int i, Offset center, double v) {
    final action = actions[i];
    final baseAngle = -math.pi / 2 + 2 * math.pi * i / actions.length;

    // Quick stagger
    final itemT = Interval(
      0.03 * i,
      0.55 + 0.03 * i,
      curve: Curves.easeOutBack,
    ).transform(v);

    // Buttons swirl slightly as they fan out from the center.
    final angle = baseAngle - (1 - itemT) * 0.6;

    final dx = math.cos(angle) * _radius * itemT;
    final dy = math.sin(angle) * _radius * itemT;

    return Positioned(
      left: center.dx + dx - _buttonSize / 2,
      top: center.dy + dy - _buttonSize / 2,
      width: _buttonSize,
      height: _buttonSize,
      child: Opacity(
        opacity: itemT.clamp(0.0, 1.0).toDouble(),
        child: Transform.scale(
          scale: 0.4 + 0.6 * itemT,
          child: _RadialButton(
            action: action,
            onPressed: () => _select(context, action),
          ),
        ),
      ),
    );
  }
}

class _RadialButton extends StatefulWidget {
  final AyahRadialAction action;
  final VoidCallback onPressed;

  const _RadialButton({required this.action, required this.onPressed});

  @override
  State<_RadialButton> createState() => _RadialButtonState();
}

class _RadialButtonState extends State<_RadialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // tealAccent is unreadable on a light surface, so use a deeper teal there.
    final savedColor = isDark ? Colors.tealAccent : Colors.teal.shade700;
    final accent = action.highlighted ? savedColor : p.primary;

    return Tooltip(
      message: action.label,
      preferBelow: false,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        // Outer layer = soft glow + gradient hairline border
        child: Container(
          padding: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.95),
                accent.withValues(alpha: 0.25),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: _pressed ? 0.45 : 0.25),
                blurRadius: 12,
              ),
            ],
          ),
          // Inner layer = glassy fill (dark in dark mode, cream in light mode)
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 1,
                colors: isDark
                    ? const [Color(0xFF2C2C2C), Color(0xFF101010)]
                    : [Colors.white, p.background],
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: accent.withValues(alpha: 0.22),
                highlightColor: Colors.transparent,
                onHighlightChanged: (value) => setState(() => _pressed = value),
                onTap: widget.onPressed,
                child: Center(
                  child: Icon(action.icon, size: 19, color: accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
