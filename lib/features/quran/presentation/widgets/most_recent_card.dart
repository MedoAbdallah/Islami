import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class MostRecentCard extends StatelessWidget {
  const MostRecentCard({
    required this.sura,
    required this.onSuraClick,
    super.key,
  });

  final Sura sura;
  final ValueChanged<Sura> onSuraClick;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSuraClick(sura),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(p.primary, Colors.white, isDark ? .4 : .12)!,
                p.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: p.primary.withValues(alpha: .28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sura.nameAr,
                    style: TextStylesHelper.largeLabelTextStyle(
                      context,
                      textColor: p.onPrimary,
                    ).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sura.nameEn,
                    style: TextStylesHelper.smallLabelTextStyle(
                      context,
                      textColor: p.onPrimary.withValues(alpha: .65),
                    ).copyWith(fontSize: 11.5),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Image.asset(AppImages.imgMostRecent, height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
