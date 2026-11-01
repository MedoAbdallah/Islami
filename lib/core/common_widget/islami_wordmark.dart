import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';

/// Text based Islami mark that follows the selected application accent color.
class IslamiWordmark extends StatelessWidget {
  const IslamiWordmark({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final accent = context.palette.primary;

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: height * .02,
            child: Icon(
              Icons.account_balance_rounded,
              size: height * .56,
              color: accent.withValues(alpha: .24),
            ),
          ),
          Positioned(
            bottom: height * .03,
            child: Text(
              'ISLAMI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontFamily: 'ElMessiri',
                fontSize: height * .39,
                fontWeight: FontWeight.w800,
                letterSpacing: height * .025,
                height: 1,
                shadows: [
                  Shadow(
                    color: accent.withValues(alpha: .22),
                    blurRadius: height * .08,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
