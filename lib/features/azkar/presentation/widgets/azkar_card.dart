import 'package:flutter/material.dart';
import 'package:islami/core/model/azkar_card.dart';
import 'package:islami/core/theme/app_palette.dart';

import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/azkar/presentation/screens/azkar_details_screen.dart';
import 'package:islami/features/azkar/presentation/widgets/azkar_ui_helper.dart';

class AzkarCardWidget extends StatelessWidget {
  const AzkarCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: askar.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return StaggeredEntrance(
            index: index,
            child: _AzkarTile(
              index: index,
              title: askar[index].title,
            ),
          );
        },
      ),
    );
  }
}

class _AzkarTile extends StatefulWidget {
  final int index;
  final String title;

  const _AzkarTile({required this.index, required this.title});

  @override
  State<_AzkarTile> createState() => _AzkarTileState();
}

class _AzkarTileState extends State<_AzkarTile> {
  bool _pressed = false;

  void _open() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => AzkarDetailsScreen(
          title: widget.title,
          number: widget.index + 1,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(18);

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? const [Color(0xFF1C1C1C), Color(0xFF0F0F0F)]
                  : [p.surface, p.background],
            ),
            border: Border.all(
              color: p.primary.withValues(alpha: _pressed ? 0.55 : 0.24),
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            splashColor: p.primary.withValues(alpha: 0.10),
            highlightColor: Colors.transparent,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: _open,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: p.primary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      (widget.index + 1).toArabicDigits,
                      style: TextStyle(
                        color: p.primary,
                        fontFamily: 'Janna',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesHelper.mediumBodyTextStyle(context)
                          .copyWith(fontWeight: FontWeight.w500, height: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 160),
                    offset: _pressed ? const Offset(-0.35, 0) : Offset.zero,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: p.primary.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}