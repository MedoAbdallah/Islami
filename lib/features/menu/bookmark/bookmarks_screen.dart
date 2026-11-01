import 'package:flutter/material.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/services/quran_bookmark_service.dart';
import 'package:islami/core/theme/app_palette.dart';

import '../../../core/theme/text_style_helper.dart';
import '../../quran/presentation/screens/sura_details.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late Future<List<QuranBookmark>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuranBookmarkService.getAll();
  }

  void _reload() {
    setState(() {
      _future = QuranBookmarkService.getAll();
    });
  }

  String _toArabicDigits(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  Future<void> _delete(QuranBookmark bookmark) async {
    await QuranBookmarkService.remove(bookmark.suraId, bookmark.ayahNumber);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'العلامات المرجعية',
            style: TextStylesHelper.largeLabelTextStyle(context),
          ),
        ),
        body: FutureBuilder<List<QuranBookmark>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: p.primary),
              );
            }

            final bookmarks = snapshot.data ?? [];

            if (bookmarks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: p.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد علامات مرجعية',
                      style: TextStylesHelper.largeBodyTextStyle(
                        context,
                        textColor: p.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط مطولًا على أي آية لحفظها',
                      style: TextStylesHelper.smallLabelTextStyle(
                        context,
                        textColor: p.onBackground.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = bookmarks[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final sura = Sura.suras.firstWhere(
                            (s) => s.id == item.suraId,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SuraDetails(
                            sura: sura,
                            initialAyahNumber: item.ayahNumber,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? p.background : p.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: p.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.suraNameAr} • الآية ${_toArabicDigits(item.ayahNumber)}',
                                  style: TextStylesHelper.mediumLabelTextStyle(
                                    context,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: () => _delete(item),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: p.primary.withValues(alpha: 0.7),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.ayahText,
                            style: TextStylesHelper.mediumBodyTextStyle(
                              context,
                            ).copyWith(height: 1.7),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
