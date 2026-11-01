import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FastingTrackerScreen extends StatefulWidget {
  const FastingTrackerScreen({super.key});
  @override
  State<FastingTrackerScreen> createState() => _FastingTrackerScreenState();
}

class _FastingTrackerScreenState extends State<FastingTrackerScreen> {
  static const _storageKey = 'fasting_tracker_dates_v1';
  Set<String> _fastedDates = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadDates() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fastedDates = prefs.getStringList(_storageKey)?.toSet() ?? {};
      _loading = false;
    });
  }

  Future<void> _toggleDate(DateTime date) async {
    final key = _dateKey(date);
    final next = Set<String>.from(_fastedDates);
    if (!next.add(key)) next.remove(key);
    setState(() => _fastedDates = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, next.toList()..sort());
  }

  String _toArabicDigits(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => digits[int.parse(digit)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final today = DateUtils.dateOnly(DateTime.now());
    final todayKey = _dateKey(today);
    final isTodayFasted = _fastedDates.contains(todayKey);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.primary,
          title: Text(
            'متابع الصيام',
            style: TextStylesHelper.largeLabelTextStyle(
              context,
              textColor: p.onBackground,
            ),
          ),
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: p.primary))
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: p.primary.withValues(alpha: .55),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 46,
                          color: p.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سجّل صيام اليوم',
                          style: TextStylesHelper.largeLabelTextStyle(
                            context,
                            textColor: p.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_toArabicDigits(today.day)} / ${_toArabicDigits(today.month)} / ${_toArabicDigits(today.year)}',
                          style: TextStylesHelper.mediumBodyTextStyle(context),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _toggleDate(today),
                          style: FilledButton.styleFrom(
                            backgroundColor: p.primary,
                            foregroundColor: p.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          icon: Icon(
                            isTodayFasted
                                ? Icons.check_circle_rounded
                                : Icons.add_rounded,
                          ),
                          label: Text(
                            isTodayFasted
                                ? 'تم تسجيل صيام اليوم'
                                : 'سجّلت صيام اليوم',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.primary.withValues(alpha: .35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: p.primary,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'إجمالي الأيام المسجلة',
                          style: TextStylesHelper.mediumTitleTextStyle(
                            context,
                            textColor: p.onBackground,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _toArabicDigits(_fastedDates.length),
                          style: TextStylesHelper.largeFontTextStyle(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'آخر ١٤ يومًا',
                    style: TextStylesHelper.largeLabelTextStyle(
                      context,
                      textColor: p.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var daysAgo = 0; daysAgo < 14; daysAgo++)
                    _DayRow(
                      date: today.subtract(Duration(days: daysAgo)),
                      selected: _fastedDates.contains(
                        _dateKey(today.subtract(Duration(days: daysAgo))),
                      ),
                      onTap: () =>
                          _toggleDate(today.subtract(Duration(days: daysAgo))),
                      toArabicDigits: _toArabicDigits,
                    ),
                ],
              ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.date,
    required this.selected,
    required this.onTap,
    required this.toArabicDigits,
  });
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;
  final String Function(int) toArabicDigits;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final label =
        '${toArabicDigits(date.day)} / ${toArabicDigits(date.month)} / ${toArabicDigits(date.year)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected
                    ? p.primary
                    : p.secondaryText.withValues(alpha: .2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? p.primary : p.secondaryText,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStylesHelper.mediumBodyTextStyle(context),
                ),
                const Spacer(),
                if (selected)
                  Text(
                    'صيام',
                    style: TextStylesHelper.smallLabelTextStyle(
                      context,
                      textColor: p.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
