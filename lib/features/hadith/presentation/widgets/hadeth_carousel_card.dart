import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/model/hadeth.dart';
import 'package:islami/core/theme/app_colors.dart';

import '../../../../core/theme/text_style_helper.dart';

/// The card is a self-contained gold "paper" (gold fill + pattern image) with
/// black text, so it keeps the same look in both themes. Only the shadow adapts.
class HadethCarouselCard extends StatelessWidget {
  const HadethCarouselCard({super.key, required this.hadeth, required this.onTap});
  final Hadeth hadeth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: hadeth.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.gold,
            image: DecorationImage(
              image: AssetImage(AppImages.hadethCardBackground),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.gold.withValues(alpha: .25)
                    : Colors.black.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(children: [
            Positioned(left: 0, top: 0, child: Image.asset(AppImages.leftCorner, width: 48)),
            Positioned(right: 0, top: 0, child: Image.asset(AppImages.rightCorner, width: 48)),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 36, 22, 20),
              child: Column(children: [
                Text(
                  hadeth.title,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStylesHelper.largeTextStyle(
                    context,
                    textColor: AppColors.black,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 20, height: 1.3),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1.2,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.black.withValues(alpha: .4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.black, Colors.transparent],
                      stops: [0, .78, 1],
                    ).createShader(rect),
                    child: ClipRect(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Text(
                          hadeth.content,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStylesHelper.mediumLabelTextStyle(
                            context,
                            textColor: AppColors.black,
                          ).copyWith(height: 1.7, fontSize: 15.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.black.withValues(alpha: .15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'اضغط للقراءة كاملة',
                        style: TextStylesHelper.smallLabelTextStyle(
                          context,
                          textColor: AppColors.black.withValues(alpha: .7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 15,
                        color: AppColors.black.withValues(alpha: .6),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}