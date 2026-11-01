import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_state.dart';

class PrayerTimeAdjustmentScreen extends StatelessWidget {
  const PrayerTimeAdjustmentScreen({super.key});

  static const _names = <String, String>{
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  DateTime? _timeFor(PrayerState state, String prayer) {
    for (final item in state.today) {
      if (item.name == prayer) return item.time;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerCubit>();
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل مواقيت الصلاة'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: BlocBuilder<PrayerCubit, PrayerState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'عدّل كل موعد بالدقائق. سيتم حفظ التعديل وتطبيقه على مواقيت اليوم والتنبيهات القادمة.',
                  style: TextStylesHelper.mediumBodyTextStyle(
                    context,
                    textColor: p.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final prayer in PrayerState.prayerNames)
                _PrayerOffsetTile(
                  name: _names[prayer]!,
                  time: _timeFor(state, prayer),
                  offset: state.prayerOffsets[prayer] ?? 0,
                  onDecrease: () => cubit.adjustPrayerOffset(prayer, -1),
                  onIncrease: () => cubit.adjustPrayerOffset(prayer, 1),
                  onReset: () => cubit.resetPrayerOffset(prayer),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerOffsetTile extends StatelessWidget {
  const _PrayerOffsetTile({
    required this.name,
    required this.time,
    required this.offset,
    required this.onDecrease,
    required this.onIncrease,
    required this.onReset,
  });

  final String name;
  final DateTime? time;
  final int offset;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final timeLabel = time == null
        ? '--:--'
        : DateFormat('HH:mm').format(time!);
    final offsetLabel = offset == 0
        ? 'بدون تعديل'
        : '${offset > 0 ? '+' : ''}$offset دقيقة';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.primary.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStylesHelper.largeBodyTextStyle(context)),
                const SizedBox(height: 3),
                Text(
                  '$timeLabel  •  $offsetLabel',
                  style: TextStylesHelper.smallLabelTextStyle(
                    context,
                    textColor: p.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'إنقاص دقيقة',
            onPressed: offset <= -180 ? null : onDecrease,
            icon: const Icon(Icons.remove_rounded),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: 'إضافة دقيقة',
            onPressed: offset >= 180 ? null : onIncrease,
            icon: const Icon(Icons.add_rounded),
          ),
          if (offset != 0)
            IconButton(
              tooltip: 'إعادة الضبط',
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
            ),
        ],
      ),
    );
  }
}
