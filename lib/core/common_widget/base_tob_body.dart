import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/common_widget/islami_wordmark.dart';

class BaseTabBody extends StatelessWidget {
  final Widget child;
  const BaseTabBody({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'القائمة الرئيسية',
                  onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                  icon: Icon(
                    Icons.menu_rounded,
                    color: context.palette.onBackground,
                    size: 27,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: IslamiWordmark(height: 58),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
