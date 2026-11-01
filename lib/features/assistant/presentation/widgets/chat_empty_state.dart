import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

import 'package:islami/core/theme/text_style_helper.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: palette.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'مرحباً بك',
              style: TextStylesHelper.largeBodyTextStyle(
                context,
                textColor: palette.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اسأل عن أي موضوع ديني أو فقهي\nوسأجيبك بأفضل ما يمكن',
              textAlign: TextAlign.center,
              style: TextStylesHelper.smallLabelTextStyle(
                context,
                textColor: palette.onBackground.withValues(alpha: 0.55),
              ).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
