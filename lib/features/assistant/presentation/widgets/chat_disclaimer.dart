import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class ChatDisclaimer extends StatelessWidget {
  const ChatDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        'قد يخطئ الذكاء الاصطناعي، يُرجى مراجعة أهل العلم في المسائل الفقهية',
        textAlign: TextAlign.center,
        style: TextStylesHelper.smallLabelTextStyle(
          context,
          textColor: palette.primary.withValues(alpha: 0.85),
        ).copyWith(fontSize: 12.5, height: 1.4),
      ),
    );
  }
}
