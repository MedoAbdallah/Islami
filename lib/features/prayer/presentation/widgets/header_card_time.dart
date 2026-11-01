import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:islami/core/theme/app_palette.dart';

import 'package:islami/core/theme/text_style_helper.dart';

const bool _useArabicDigits = false;

String _digits(String input) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    final index = arabic.indexOf(ch);
    if (_useArabicDigits) {
      final latin = int.tryParse(ch);
      buffer.write(latin != null ? arabic[latin] : ch);
    } else {
      buffer.write(index >= 0 ? index.toString() : ch);
    }
  }
  return buffer.toString();
}

class HeaderCardTime extends StatelessWidget {
  const HeaderCardTime({super.key, required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(now);
    final onCard = context.palette.onPrimary;
    final gregorian = _digits(DateFormat('d MMM،\nyyyy', 'ar').format(now));
    final day = DateFormat('EEEE', 'ar').format(now);
    final hijriText = _digits(
      '${hijri.hDay.toString().padLeft(2, '0')} ${hijri.getShortMonthName()}،\n${hijri.hYear}',
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _DateLabel(gregorian),
            Column(children: [
              Text('مواقيت الصلاة', style: TextStylesHelper.largeLabelBoldTextStyle(context, textColor: onCard.withValues(alpha: .7)).copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              Text(day, style: TextStylesHelper.largeLabelBoldTextStyle(context, textColor: onCard).copyWith(fontSize: 18)),
            ]),
            _DateLabel(hijriText),
          ],
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStylesHelper.largeBoldTextStyle(context, textColor: Colors.white).copyWith(fontSize: 15, height: 1.35),
  );
}
