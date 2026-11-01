import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/features/prayer/domain/entities/prayer_models.dart';
import 'header_card_time.dart';
import 'next_pray_text.dart';
import 'view_card_time.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.now,
    required this.prayers,
    required this.next,
    required this.current,
    required this.remaining,
  });

  final DateTime now;
  final List<PrayerInfo> prayers;
  final PrayerInfo? next;
  final PrayerInfo? current;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: p.primary.withValues(alpha: .2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderCardTime(now: now),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ViewCardTime(prayers: prayers, next: next),
          ),
          NextPrayText(
            prayerName: next?.name,
            currentPrayerName: current?.name,
            remaining: remaining,
          ),
        ],
      ),
    );
  }
}
