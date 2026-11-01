import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? palette.background : palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
        ),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: palette.primary,
          ),
        ),
      ),
    );
  }
}
