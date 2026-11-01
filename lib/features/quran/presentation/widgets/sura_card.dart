import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class SuraCard extends StatelessWidget {
  const SuraCard({required this.sura, required this.onSuraClick, super.key});

  final Sura sura;
  final ValueChanged<Sura> onSuraClick;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSuraClick(sura),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.primary.withValues(alpha: .16)),
            boxShadow: [
              BoxShadow(
                color: p.primary.withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    AppImages.suraNumberDecoration,
                    height: 56,
                    width: 56,
                  ),
                  Text(
                    sura.id.toString(),
                    style: TextStylesHelper.mediumLabelTextStyle(
                      context,
                      textColor: p.primary,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sura.nameAr,
                      style: TextStylesHelper.mediumLabelTextStyle(
                        context,
                        textColor: p.onBackground,
                      ).copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sura.nameEn,
                      style: TextStylesHelper.smallBodyTextStyle(
                        context,
                        textColor: p.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'آياتها',
                    style: TextStylesHelper.smallLabelTextStyle(
                      context,
                      textColor: p.secondaryText,
                    ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sura.ayaNumbers.toString(),
                    style: TextStylesHelper.smallLabelTextStyle(
                      context,
                      textColor: p.primary,
                    ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Image.asset(
                sura.place == 'مكية' ? AppImages.kaaba : AppImages.mosque,
                height: 26,
                width: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
