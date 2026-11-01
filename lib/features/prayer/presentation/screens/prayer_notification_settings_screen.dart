import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_state.dart';

class PrayerNotificationSettingsScreen extends StatelessWidget {
  const PrayerNotificationSettingsScreen({super.key});

  static const _names = <String, String>{
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<PrayerCubit>();
    final soundDescription = defaultTargetPlatform == TargetPlatform.iOS
        ? 'على iOS يستخدم الإشعار صوت التنبيه الذي يسمح به النظام.'
        : 'يصدر التنبيه المجدول صوته حتى عندما يكون التطبيق مغلقًا على Android.';
    return Scaffold(
      appBar: AppBar(title: const Text('إشعارات الصلاة'), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<PrayerCubit, PrayerState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('إشعارات مواقيت الصلاة'),
                      subtitle: const Text(
                        'تفعيل أو إيقاف تنبيهات الصلوات كلها',
                      ),
                      value: state.prayerNotificationsEnabled,
                      onChanged: (enabled) async {
                        if (enabled && !state.notificationPermissionGranted) {
                          await cubit.requestNotificationPermissions();
                        }
                        await cubit.setPrayerNotificationsEnabled(enabled);
                      },
                    ),
                    const Divider(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        state.notificationPermissionGranted
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        color: state.notificationPermissionGranted
                            ? p.primary
                            : p.onBackground.withValues(alpha: .55),
                      ),
                      title: Text(
                        state.notificationPermissionGranted
                            ? 'إذن الإشعارات مفعّل'
                            : 'اسمح للتطبيق بإرسال الإشعارات',
                      ),
                      subtitle: Text(
                        state.exactAlarmPermissionGranted
                            ? 'التنبيهات مضبوطة على وقت الصلاة'
                            : 'يمكن ضبط تنبيهات الصلاة الدقيقة من إعدادات الجهاز',
                      ),
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        color: p.primary,
                      ),
                      onTap: cubit.requestNotificationPermissions,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'اختيار الصلوات',
                style: TextStylesHelper.largeBodyTextStyle(context),
              ),
              const SizedBox(height: 8),
              _SettingsCard(
                child: Column(
                  children: [
                    for (final prayer in PrayerState.prayerNames)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_names[prayer]!),
                        value: state.enabledPrayerNotifications[prayer] ?? true,
                        onChanged: state.prayerNotificationsEnabled
                            ? (enabled) => cubit.setPrayerNotificationEnabled(
                                prayer,
                                enabled,
                              )
                            : null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'صوت التنبيه',
                style: TextStylesHelper.largeBodyTextStyle(context),
              ),
              const SizedBox(height: 8),
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('تشغيل صوت الأذان مع التنبيه'),
                      subtitle: Text(soundDescription),
                      value: state.notificationSoundEnabled,
                      onChanged: cubit.setNotificationSoundEnabled,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: state.adhanReciter,
                      decoration: const InputDecoration(
                        labelText: 'صوت المؤذن',
                      ),
                      items: cubit.reciters.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: state.notificationSoundEnabled
                          ? (value) {
                              if (value != null) cubit.setReciter(value);
                            }
                          : null,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: cubit.playAdhanPreview,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('تجربة صوت الأذان'),
                    ),
                    Text(
                      'على أجهزة Android يُستخدم صوت المؤذن المختار للتنبيه المجدول. قد تؤخر بعض الأجهزة التنبيهات بسبب إعدادات توفير البطارية.',
                      style: TextStylesHelper.smallLabelTextStyle(
                        context,
                        textColor: p.onBackground.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.primary.withValues(alpha: .18)),
      ),
      child: child,
    );
  }
}
