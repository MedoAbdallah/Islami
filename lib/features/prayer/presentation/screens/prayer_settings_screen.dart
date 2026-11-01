import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_state.dart';

class PrayerSettingsScreen extends StatelessWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PrayerSettingsContent();
  }
}

class _PrayerSettingsContent extends StatefulWidget {
  const _PrayerSettingsContent();

  @override
  State<_PrayerSettingsContent> createState() => _PrayerSettingsContentState();
}

class _PrayerSettingsContentState extends State<_PrayerSettingsContent> {
  int? _method;
  int? _school;
  bool _isLoading = true;

  PrayerCubit get _cubit => context.read<PrayerCubit>();

  @override
  void initState() {
    super.initState();
    _loadSavedCalculation();
  }

  Future<void> _loadSavedCalculation() async {
    final method = await _cubit.getMethod();
    final school = await _cubit.getSchool();
    if (!mounted) return;
    setState(() {
      _method = method;
      _school = school;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الصلاة والأذان')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'إعدادات مواقيت الصلاة',
                      style: TextStylesHelper.largeBodyTextStyle(context),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _method,
                      items: _cubit.methodLabels.entries
                          .map(
                            (entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _method = value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'طريقة الحساب',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text('شافعي / مالكي / حنبلي'),
                        ),
                        ButtonSegment(value: 1, label: Text('حنفي')),
                      ],
                      selected: {_school!},
                      onSelectionChanged: (values) =>
                          setState(() => _school = values.first),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(p.onBackground),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'إعدادات الأذان',
                      style: TextStylesHelper.largeBodyTextStyle(context),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<PrayerCubit, PrayerState>(
                      builder: (context, state) => Column(
                        children: [
                          SwitchListTile(
                            title: const Text('كتم صوت الأذان داخل التطبيق'),
                            value: state.isAdhanMuted,
                            onChanged: (_) => _cubit.toggleMute(),
                          ),
                          DropdownButtonFormField<String>(
                            value: state.adhanReciter,
                            decoration: const InputDecoration(
                              labelText: 'صوت المؤذن',
                            ),
                            items: _cubit.reciters.entries
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) _cubit.setReciter(value);
                            },
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _cubit.playAdhanPreview,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('تجربة صوت الأذان'),
                          ),
                          TextButton(
                            onPressed: _cubit.requestNotificationPermissions,
                            child: const Text('تفعيل إشعارات الصلاة'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await _cubit.saveCalculation(
                          method: _method!,
                          school: _school!,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('حفظ وتطبيق'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
