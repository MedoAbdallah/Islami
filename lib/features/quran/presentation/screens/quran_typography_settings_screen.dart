import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/quran/presentation/cubit/quran_typography_cubit.dart';

class QuranTypographySettingsScreen extends StatelessWidget {
  const QuranTypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranTypographyCubit, QuranTypographyState>(
      builder: (context, state) {
        final cubit = context.read<QuranTypographyCubit>();

        return Scaffold(
          appBar: AppBar(title: const Text('خط وحجم القرآن والتفسير')),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _SettingsCard(
                  title: 'نوع الخط',
                  child: DropdownButtonFormField<String>(
                    initialValue: state.fontFamily,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'اختر الخط',
                      border: OutlineInputBorder(),
                    ),
                    items: QuranTypographyCubit.fontOptions
                        .map(
                          (font) => DropdownMenuItem<String>(
                            value: font.family,
                            child: Text(
                              font.label,
                              style: TextStyle(fontFamily: font.family),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (family) {
                      if (family != null) cubit.setFontFamily(family);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  title: 'حجم خط القرآن',
                  child: Column(
                    children: [
                      _FontSizeSlider(
                        label: 'حجم الخط',
                        value: state.quranFontSize,
                        min: 16,
                        max: 40,
                        onChanged: cubit.setQuranFontSize,
                      ),
                      const SizedBox(height: 8),
                      _PreviewCard(
                        title: 'معاينة القرآن',
                        text:
                            'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝٢ الرَّحْمَٰنِ الرَّحِيمِ ۝٣',
                        fontFamily: state.fontFamily,
                        fontSize: state.quranFontSize,
                        lineHeight: 2.0,
                        isQuran: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  title: 'حجم خط التفسير',
                  child: Column(
                    children: [
                      _FontSizeSlider(
                        label: 'حجم الخط',
                        value: state.tafsirFontSize,
                        min: 14,
                        max: 32,
                        onChanged: cubit.setTafsirFontSize,
                      ),
                      const SizedBox(height: 8),
                      _PreviewCard(
                        title: 'معاينة التفسير',
                        text:
                            'تُثني الآية على الله تعالى وتصفه بالرحمة الواسعة، وتذكّر القارئ بنعمه.',
                        fontFamily: state.fontFamily,
                        fontSize: state.tafsirFontSize,
                        lineHeight: 1.8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      color: p.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: TextStylesHelper.mediumLabelTextStyle(context)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  const _FontSizeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toStringAsFixed(0)} px', style: TextStyle(color: p.primary)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.text,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    this.isQuran = false,
  });

  final String title;
  final String text;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final bool isQuran;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      color: p.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStylesHelper.smallLabelTextStyle(
                context,
                textColor: p.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: isQuran ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: p.onBackground,
                fontFamily: fontFamily,
                fontSize: fontSize,
                height: lineHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



