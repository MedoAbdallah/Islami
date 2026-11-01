import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/features/prayer/domain/entities/prayer_models.dart';

class ViewCardTime extends StatelessWidget {
  const ViewCardTime({super.key, required this.prayers, required this.next});
  final List<PrayerInfo> prayers;
  final PrayerInfo? next;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 96,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: prayers.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, i) {
        final prayer = prayers[i];
        final isNext = next?.name == prayer.name;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250), width: 82,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isNext ? AppColors.black : Colors.black.withValues(alpha: .22),
            borderRadius: BorderRadius.circular(18),
            border: isNext ? Border.all(color: AppColors.black.withValues(alpha: .3)) : null,
            boxShadow: isNext ? [BoxShadow(color: Colors.black.withValues(alpha: .25), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(prayer.name, style: TextStyle(color: isNext ? AppColors.gold : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 5),
            Text(DateFormat('hh:mm', 'en').format(prayer.time), style: TextStyle(color: isNext ? AppColors.gold : Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
            Text(DateFormat('a', 'en').format(prayer.time), style: TextStyle(color: isNext ? AppColors.gold.withValues(alpha: .8) : Colors.white60, fontSize: 12)),
          ]),
        );
      },
    ),
  );
}
