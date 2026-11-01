import 'package:flutter/material.dart';

/// Converts western digits to Arabic-Indic digits: 12 -> ١٢
extension ArabicDigits on int {
  String get toArabicDigits {
    const western = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return toString().split('').map((c) {
      final i = western.indexOf(c);
      return i == -1 ? c : arabic[i];
    }).join();
  }
}

/// Fade + rise entrance. The first items arrive in a soft cascade;
/// items further down (built lazily while scrolling) use a short, flat duration
/// so they never feel sluggish.
class StaggeredEntrance extends StatelessWidget {
  final int index;
  final Widget child;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ms = index < 8 ? 380 + index * 70 : 320;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}