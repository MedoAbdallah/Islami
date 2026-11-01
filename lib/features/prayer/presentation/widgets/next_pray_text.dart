import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class NextPrayText extends StatelessWidget {
  const NextPrayText({
    super.key,
    required this.prayerName,
    required this.currentPrayerName,
    required this.remaining,
  });

  final String? prayerName;
  final String? currentPrayerName;
  final Duration remaining;

  String _format(Duration value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.inHours)}:${two(value.inMinutes % 60)}:${two(value.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final onCard = context.palette.onPrimary;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
        child: Column(
          children: [
            if (currentPrayerName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'الآن: $currentPrayerName',
                  style: TextStylesHelper.largeTextStyle(
                    context,
                    textColor: onCard.withValues(alpha: .75),
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            Text(
              'الصلاة القادمة  –  ${prayerName ?? '...'}',
              style: TextStylesHelper.largeTextStyle(
                context,
                textColor: onCard,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _format(remaining),
              style: TextStyle(
                color: onCard,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
