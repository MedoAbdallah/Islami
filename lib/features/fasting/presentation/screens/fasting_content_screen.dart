import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';

enum FastingSection { types, duas, rulings, virtues }

class FastingContentScreen extends StatelessWidget {
  const FastingContentScreen({super.key, required this.section});
  final FastingSection section;

  String get _title => switch (section) {
    FastingSection.types => 'أنواع الصيام',
    FastingSection.duas => 'أدعية الصيام',
    FastingSection.rulings => 'أحكام الصيام',
    FastingSection.virtues => 'فضل الصيام',
  };

  List<_FastingInfo> get _items => switch (section) {
    FastingSection.types => const [
      _FastingInfo(
        'صيام رمضان',
        'صيام شهر رمضان المبارك، وهو من أركان الإسلام.',
      ),
      _FastingInfo(
        'قضاء الصيام',
        'صيام الأيام التي أفطرها المسلم من رمضان بعذر، في وقت لاحق.',
      ),
      _FastingInfo(
        'صيام النذر',
        'الوفاء بصيام النذر المشروع عند تحقق ما التزمه الناذر.',
      ),
      _FastingInfo(
        'صيام التطوع',
        'صيام نافلة في أيام مشروعة، مثل الاثنين والخميس.',
      ),
    ],
    FastingSection.duas => const [
      _FastingInfo(
        'دعاء جامع',
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        source: 'سورة البقرة • الآية ٢٠١',
      ),
      _FastingInfo(
        'دعاء القبول',
        'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
        source: 'سورة البقرة • الآية ١٢٧',
      ),
      _FastingInfo(
        'دعاء العبادة',
        'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      ),
    ],
    FastingSection.rulings => const [
      _FastingInfo(
        'النية',
        'يحرص المسلم على نية الصيام والعبادة بإخلاص لله تعالى.',
      ),
      _FastingInfo(
        'آداب الصائم',
        'حفظ اللسان، والإحسان إلى الناس، واجتناب الخصام، والإكثار من الطاعات.',
      ),
      _FastingInfo(
        'أحكام الأعذار',
        'للمريض والمسافر أحكام ورخص، ويُسأل أهل العلم عن الحالة الخاصة.',
      ),
      _FastingInfo(
        'قضاء ما فات',
        'من أفطر لعذر يرجع إلى الأحكام الشرعية لمعرفة ما يلزمه.',
      ),
    ],
    FastingSection.virtues => const [
      _FastingInfo(
        'التقوى',
        'قال الله تعالى: ﴿ لَعَلَّكُمْ تَتَّقُونَ ﴾، فالصيام يربي النفس على مراقبة الله.',
      ),
      _FastingInfo(
        'الصبر',
        'يعوّد الصيام المسلم الصبر والانضباط ومجاهدة النفس.',
      ),
      _FastingInfo(
        'الإحسان',
        'يذكّر الصيام بنعمة الطعام والشراب ويحث على تفقد المحتاجين.',
      ),
      _FastingInfo(
        'الاجتهاد في الطاعة',
        'اجعل الصيام فرصة للمحافظة على الصلاة والقرآن والذكر والعمل الصالح.',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.primary,
          title: Text(
            _title,
            style: TextStylesHelper.largeLabelTextStyle(context),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _items[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.primary.withValues(alpha: .42)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStylesHelper.largeLabelTextStyle(
                      context,
                      textColor: p.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.body,
                    style: TextStylesHelper.largeBodyTextStyle(
                      context,
                    ).copyWith(height: 1.7),
                  ),
                  if (item.source != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.source!,
                      style: TextStylesHelper.smallLabelTextStyle(
                        context,
                        textColor: p.primary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FastingInfo {
  const _FastingInfo(this.title, this.body, {this.source});
  final String title;
  final String body;
  final String? source;
}
