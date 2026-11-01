import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

import '../../../../core/theme/text_style_helper.dart';

String _arabicDigits(int n) {
  const western = '0123456789';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((c) {
    final i = western.indexOf(c);
    return i < 0 ? c : arabic[i];
  }).join();
}

class HadethProgressFooter extends StatelessWidget {
  const HadethProgressFooter({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 0, 48, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              '${_arabicDigits(current + 1)} / ${_arabicDigits(total)}',
              key: ValueKey<int>(current),
              style: TextStylesHelper.smallLabelTextStyle(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: p.primary.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional.centerStart,
              widthFactor: (current + 1) / total,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: p.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}