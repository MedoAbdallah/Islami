import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

import '../../../../core/theme/text_style_helper.dart';

class HadethLoadingState extends StatelessWidget {
  const HadethLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: p.primary),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الأحاديث',
            style: TextStylesHelper.smallLabelTextStyle(
              context,
              textColor: p.primary.withValues(alpha: .8),
            ),
          ),
        ],
      ),
    );
  }
}