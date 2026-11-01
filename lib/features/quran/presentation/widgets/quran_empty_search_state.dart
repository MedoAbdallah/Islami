import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class QuranEmptySearchState extends StatelessWidget {
  const QuranEmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: p.primary.withValues(alpha: .5),
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على سور',
            style: TextStylesHelper.largeBodyTextStyle(
              context,
              textColor: p.onBackground.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'جرّب اسمًا آخر',
            style: TextStylesHelper.smallLabelTextStyle(
              context,
              textColor: p.onBackground.withValues(alpha: .45),
            ),
          ),
        ],
      ),
    );
  }
}
