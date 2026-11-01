import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

class SebhaProgressIndicator extends StatelessWidget {
  const SebhaProgressIndicator({super.key, required this.activeIndex, required this.count});
  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    final primary = context.palette.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? primary : primary.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }
}
