import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class QuranSearchField extends StatelessWidget {
  const QuranSearchField({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.start,
        style: TextStylesHelper.smallLabelTextStyle(
          context,
          textColor: p.onBackground,
        ),
        cursorColor: p.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark
              ? p.background.withValues(alpha: .55)
              : p.surface.withValues(alpha: .9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: ImageIcon(
              AssetImage(AppImages.icQuran),
              color: p.primary,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: isSearching
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, color: p.primary, size: 20),
                )
              : null,
          hintText: 'ابحث باسم السورة...',
          hintStyle: TextStylesHelper.smallLabelTextStyle(
            context,
            textColor: p.onBackground.withValues(alpha: .6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.primary.withValues(alpha: .6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: p.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
