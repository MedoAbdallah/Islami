import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/fasting/presentation/screens/fasting_content_screen.dart';
import 'package:islami/features/fasting/presentation/screens/fasting_tracker_screen.dart';

class FastingScreen extends StatelessWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tiles = <_FastingTileData>[
      _FastingTileData(
        title: 'أنواع الصيام',
        subtitle: 'تعرّف على أنواع الصيام',
        icon: Icons.menu_book_rounded,
        section: FastingSection.types,
      ),
      _FastingTileData(
        title: 'أدعية الصيام',
        subtitle: 'أدعية وأذكار نافعة',
        icon: Icons.volunteer_activism_rounded,
        section: FastingSection.duas,
      ),
      _FastingTileData(
        title: 'متابع الصيام',
        subtitle: 'سجّل أيام صيامك',
        icon: Icons.calendar_month_rounded,
        tracker: true,
      ),
      _FastingTileData(
        title: 'أحكام الصيام',
        subtitle: 'معلومات أساسية للصائم',
        icon: Icons.balance_rounded,
        section: FastingSection.rulings,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.primary,
          title: Text(
            'الصيام',
            style: TextStylesHelper.largeLabelTextStyle(context),
          ),
          actions: [
            IconButton(
              tooltip: 'متابع الصيام',
              onPressed: () => _openTracker(context),
              icon: const Icon(Icons.calendar_month_rounded),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              const _FastingHero(),
              const SizedBox(height: 18),
              const _VerseCard(),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.08,
                ),
                itemBuilder: (context, index) =>
                    _FastingTile(data: tiles[index]),
              ),
              const SizedBox(height: 16),
              _VirtueCard(
                onTap: () => _openSection(context, FastingSection.virtues),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _openTracker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FastingTrackerScreen()),
    );
  }

  static void _openSection(BuildContext context, FastingSection section) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FastingContentScreen(section: section),
      ),
    );
  }
}

class _FastingTileData {
  const _FastingTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.section,
    this.tracker = false,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final FastingSection? section;
  final bool tracker;
}

class _FastingHero extends StatelessWidget {
  const _FastingHero();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [const Color(0xFF382A12), const Color(0xFF17130D)]
              : [const Color(0xFFFFF1D4), const Color(0xFFE8D2A5)],
        ),
        border: Border.all(color: p.primary.withValues(alpha: .72), width: 1.2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 18,
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: p.primary.withValues(alpha: .8),
            ),
          ),
          Positioned(
            right: 24,
            top: 28,
            child: Icon(
              Icons.nightlight_round,
              size: 58,
              color: p.primary.withValues(alpha: .9),
            ),
          ),
          Positioned(
            left: 34,
            bottom: 18,
            child: Icon(
              Icons.light_mode_rounded,
              size: 42,
              color: p.primary.withValues(alpha: .76),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الصيام',
                    style: TextStylesHelper.largeFontTextStyle(
                      context,
                      textColor: isDark ? p.primary : p.onBackground,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'عبادة عظيمة .. وقربة إلى الله',
                    textAlign: TextAlign.center,
                    style: TextStylesHelper.mediumTitleTextStyle(
                      context,
                      textColor: p.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.primary.withValues(alpha: .75), width: 1.4),
      ),
      child: Column(
        children: [
          Text(
            '﴿ يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِنْ قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ ﴾',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFF1D9AE) : const Color(0xFF59421F),
              fontFamily: 'AmiriQuran',
              fontSize: 20,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سورة البقرة • الآية ١٨٣',
            style: TextStylesHelper.mediumLabelTextStyle(
              context,
              textColor: p.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FastingTile extends StatelessWidget {
  const _FastingTile({required this.data});
  final _FastingTileData data;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () => data.tracker
            ? FastingScreen._openTracker(context)
            : FastingScreen._openSection(context, data.section!),
        child: Ink(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: p.primary.withValues(alpha: .72),
              width: 1.25,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, size: 43, color: p.primary),
              const SizedBox(height: 8),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStylesHelper.mediumTitleTextStyle(
                  context,
                  textColor: p.onBackground,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStylesHelper.smallBodyTextStyle(context),
              ),
              const SizedBox(height: 5),
              CircleAvatar(
                radius: 13,
                backgroundColor: p.primary,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 21,
                  color: p.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VirtueCard extends StatelessWidget {
  const _VirtueCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: p.primary.withValues(alpha: .72),
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.light_mode_rounded, size: 46, color: p.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فضل الصيام',
                      style: TextStylesHelper.largeLabelTextStyle(
                        context,
                        textColor: p.onBackground,
                      ),
                    ),
                    Text(
                      'من أعظم القربات إلى الله',
                      style: TextStylesHelper.mediumBodyTextStyle(context),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_circle_left_rounded, color: p.primary, size: 34),
            ],
          ),
        ),
      ),
    );
  }
}
