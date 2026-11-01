import 'package:flutter/material.dart';
import 'package:islami/core/common_widget/base_tob_body.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:islami/features/prayer/presentation/cubit/prayer_state.dart';
import 'package:islami/features/quran/data/datasources/quran_local_data_source.dart';
import 'package:islami/features/quran/presentation/screens/sura_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Personalized landing page built from data already available in the app.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({
    super.key,
    required this.onOpenQuran,
    required this.onOpenHadith,
    required this.onOpenSebha,
    required this.onOpenAssistant,
    required this.onOpenPrayer,
    required this.onOpenAzkar,
    required this.onOpenDua,
    required this.onOpenFasting,
  });

  final VoidCallback onOpenQuran;
  final VoidCallback onOpenHadith;
  final VoidCallback onOpenSebha;
  final VoidCallback onOpenAssistant;
  final VoidCallback onOpenPrayer;
  final VoidCallback onOpenAzkar;
  final VoidCallback onOpenDua;
  final VoidCallback onOpenFasting;

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  List<Sura> _recentSuras = const [];

  @override
  void initState() {
    super.initState();
    _loadRecentSuras();
  }

  Future<void> _loadRecentSuras() async {
    try {
      final recent = await QuranLocalDataSourceImpl().loadRecentSuras();
      if (mounted) setState(() => _recentSuras = recent);
    } catch (_) {
      // The dashboard remains usable if local reading history is unavailable.
    }
  }

  String _duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _prayerName(String name) => switch (name) {
    'Fajr' => 'الفجر',
    'Dhuhr' => 'الظهر',
    'Asr' => 'العصر',
    'Maghrib' => 'المغرب',
    'Isha' => 'العشاء',
    _ => name,
  };

  String _arabicDate(DateTime date) {
    const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${weekdays[date.weekday - 1]}، ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BaseTabBody(
        child: RefreshIndicator(
          color: p.primary,
          onRefresh: _loadRecentSuras,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
            children: [
              Text(_arabicDate(DateTime.now()), style: TextStyle(color: p.secondaryText, fontSize: 13)),
              const SizedBox(height: 4),
              Text('السلام عليكم ورحمة الله', style: TextStyle(color: p.onBackground, fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text('اجعل يومك عامرًا بذكر الله', style: TextStyle(color: p.secondaryText, fontSize: 14)),
              const SizedBox(height: 18),
              BlocBuilder<PrayerCubit, PrayerState>(
                builder: (context, state) => _NextPrayerCard(
                  state: state,
                  prayerName: state.next == null ? 'الصلاة القادمة' : _prayerName(state.next!.name),
                  countdown: _duration(state.remaining),
                  onTap: widget.onOpenPrayer,
                ),
              ),
              const SizedBox(height: 22),
              _SectionHeading(title: 'تابع رحلتك مع القرآن', action: 'فتح القرآن', onTap: widget.onOpenQuran),
              const SizedBox(height: 10),
              if (_recentSuras.isNotEmpty)
                _ContinueReadingCard(
                  sura: _recentSuras.first,
                  onTap: () => Navigator.of(context).pushNamed(SuraDetails.routeName, arguments: _recentSuras.first),
                )
              else
                _EmptyReadingCard(onTap: widget.onOpenQuran),
              const SizedBox(height: 22),
              const _SectionHeading(title: 'وقفة إيمانية'),
              const SizedBox(height: 10),
              _DailyReminderCard(
                icon: Icons.auto_stories_rounded,
                label: 'آية اليوم',
                text: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
                reference: 'سورة الشرح • ٦',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SuraDetails(
                      sura: _findSura(94),
                      initialAyahNumber: 6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _DailyReminderCard(
                icon: Icons.format_quote_rounded,
                label: 'حديث اليوم',
                text: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
                reference: 'صحيح البخاري • ١',
              ),
              const SizedBox(height: 22),
              const _SectionHeading(title: 'مساحاتك اليومية'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.72,
                children: [
                  _QuickAction(icon: Icons.wb_twilight_rounded, title: 'الأذكار', subtitle: 'أذكار الصباح والمساء', onTap: widget.onOpenAzkar),
                  _QuickAction(icon: Icons.volunteer_activism_rounded, title: 'الأدعية', subtitle: 'أدعية منوعة', onTap: widget.onOpenDua),
                  _QuickAction(icon: Icons.fingerprint_rounded, title: 'السبحة', subtitle: 'سبّح واستغفر', onTap: widget.onOpenSebha),
                  _QuickAction(icon: Icons.auto_awesome_rounded, title: 'اسأل المساعد', subtitle: 'أسئلة إسلامية', onTap: widget.onOpenAssistant),
                  _QuickAction(icon: Icons.menu_book_rounded, title: 'الأحاديث', subtitle: 'اقرأ وتعلّم', onTap: widget.onOpenHadith),
                  _QuickAction(icon: Icons.nightlight_round, title: 'الصيام', subtitle: 'تابع أيام صيامك', onTap: widget.onOpenFasting),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: p.primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(18), border: Border.all(color: p.primary.withValues(alpha: .18))),
                child: Row(children: [
                  Icon(Icons.favorite_rounded, color: p.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text('القليل الدائم خير من الكثير المنقطع', style: TextStyle(color: p.onBackground, fontWeight: FontWeight.w600))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Sura _findSura(int id) {
    Sura.generateSurasList();
    return Sura.suras.firstWhere((sura) => sura.id == id);
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.state, required this.prayerName, required this.countdown, required this.onTap});
  final PrayerState state;
  final String prayerName;
  final String countdown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [p.primary, p.primary.withValues(alpha: .78)]),
            boxShadow: [BoxShadow(color: p.primary.withValues(alpha: .20), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.access_time_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 7),
              const Expanded(child: Text('الصلاة القادمة', style: TextStyle(color: Colors.white, fontSize: 13))),
              if (state.locationLabel.isNotEmpty) ...[
                const Icon(Icons.location_on_outlined, color: Colors.white70, size: 15),
                const SizedBox(width: 3),
                Flexible(child: Text(state.locationLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11))),
              ],
            ]),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Text(prayerName, style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800))),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('متبقي', style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text(state.next == null ? '--:--' : countdown, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
              ]),
            ]),
            const SizedBox(height: 13),
            Row(children: [const Text('عرض مواقيت الصلاة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)), const Spacer(), const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18)]),
          ]),
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.sura, required this.onTap});
  final Sura sura;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _SurfaceCard(
      onTap: onTap,
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: p.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.menu_book_rounded, color: p.primary, size: 25)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sura.nameAr, style: TextStyle(color: p.onBackground, fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('سورة ${sura.nameAr} • ${sura.ayaNumbers} آية', style: TextStyle(color: p.secondaryText, fontSize: 12))]),),
        Icon(Icons.play_circle_fill_rounded, color: p.primary, size: 32),
      ]),
    );
  }
}

class _EmptyReadingCard extends StatelessWidget {
  const _EmptyReadingCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _SurfaceCard(onTap: onTap, child: Row(children: [Icon(Icons.auto_stories_rounded, color: p.primary, size: 32), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ابدأ رحلتك', style: TextStyle(color: p.onBackground, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('افتح القرآن واختر سورة للقراءة', style: TextStyle(color: p.secondaryText, fontSize: 12))])), Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: p.primary)]));
  }
}

class _DailyReminderCard extends StatelessWidget {
  const _DailyReminderCard({required this.icon, required this.label, required this.text, required this.reference, this.onTap});
  final IconData icon;
  final String label;
  final String text;
  final String reference;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _SurfaceCard(onTap: onTap, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: p.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: p.primary)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: p.primary, fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 6), Text(text, style: TextStyle(color: p.onBackground, fontSize: 19, height: 1.65, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(reference, style: TextStyle(color: p.secondaryText, fontSize: 11))]))]));
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _SurfaceCard(onTap: onTap, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: p.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: p.primary, size: 21)), const SizedBox(width: 9), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.onBackground, fontWeight: FontWeight.w800, fontSize: 12)), const SizedBox(height: 4), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.secondaryText, fontSize: 10))]))]));
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(children: [Expanded(child: Text(title, style: TextStyle(color: p.onBackground, fontSize: 17, fontWeight: FontWeight.w800))), if (action != null) TextButton(onPressed: onTap, child: Text(action!, style: TextStyle(color: p.primary, fontSize: 12, fontWeight: FontWeight.w700)))]);
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Ink(padding: padding, decoration: BoxDecoration(color: p.surface.withValues(alpha: .96), borderRadius: BorderRadius.circular(18), border: Border.all(color: p.primary.withValues(alpha: .15))), child: child)));
  }
}
