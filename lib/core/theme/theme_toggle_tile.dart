import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/core/theme/theme_cubit.dart';

/// Drop this anywhere (e.g. a settings screen).
class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.primary),
      ),
      child: Row(
        children: [
          Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
              style: TextStylesHelper.largeBodyTextStyle(context),
            ),
          ),
          Switch(
            value: isDark,
            activeColor: context.palette.primary,
            onChanged: (_) => context.read<ThemeCubit>().toggle(),
          ),
        ],
      ),
    );
  }
}
