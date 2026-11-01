import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

import '../../../../core/theme/text_style_helper.dart';

class HadethErrorState extends StatelessWidget {
  const HadethErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: p.primary.withValues(alpha: .6),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStylesHelper.mediumLabelTextStyle(context)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('إعادة المحاولة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.primary,
              side: BorderSide(color: p.primary.withValues(alpha: .5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}