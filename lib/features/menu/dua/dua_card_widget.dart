import 'package:flutter/material.dart';
import 'package:islami/core/model/dua_card.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';
import 'package:islami/features/menu/dua/dua_details_screen.dart';

import '../azkar/azkar_ui_helper.dart';

class DuaCardWidget extends StatelessWidget {
  const DuaCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: duas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return StaggeredEntrance(
            index: index,
            child: _DuaTile(
              index: index,
              title: duas[index].title,
            ),
          );
        },
      ),
    );
  }
}

class _DuaTile extends StatefulWidget {
  final int index;
  final String title;

  const _DuaTile({required this.index, required this.title});

  @override
  State<_DuaTile> createState() => _DuaTileState();
}

class _DuaTileState extends State<_DuaTile> {
  bool _pressed = false;

  void _open() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => DuaDetailsScreen(
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
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF1C1C1C), Color(0xFF0F0F0F)],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: _pressed ? 0.55 : 0.24),
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            splashColor: AppColors.gold.withValues(alpha: 0.10),
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
                      color: AppColors.gold.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      (widget.index + 1).toArabicDigits,
                      style: const TextStyle(
                        color: AppColors.gold,
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
                      style: TextStylesHelper.mediumBodyTextStyle(
                        textColor: AppColors.white,
                      ).copyWith(fontWeight: FontWeight.w500, height: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 160),
                    offset: _pressed ? const Offset(-0.35, 0) : Offset.zero,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.gold.withValues(alpha: 0.75),
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