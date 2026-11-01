import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/theme/app_palette.dart';

import 'package:islami/core/theme/text_style_helper.dart';

class SebhaDial extends StatelessWidget {
  const SebhaDial({
    super.key,
    required this.rotation,
    required this.zekr,
    required this.counter,
    required this.onTap,
    required this.onLongPress,
  });

  final Animation<double> rotation;
  final String zekr;
  final int counter;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: .15),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: rotation,
              builder: (context, child) => Transform.rotate(
                angle: rotation.value,
                child: child,
              ),
              child: Image.asset(
                AppImages.sebhaBody,
                height: 310,
                width: 310,
                fit: BoxFit.contain,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  zekr,
                  style: TextStylesHelper.largeTitleTextStyle(
                    context,
                    textColor: palette.onBackground,
                  ).copyWith(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? palette.background.withValues(alpha: .45)
                        : palette.surface.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: palette.primary.withValues(alpha: .35),
                    ),
                  ),
                  child: Text(
                    '$counter',
                    style: TextStylesHelper.largeTitleTextStyle(context)
                        .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
