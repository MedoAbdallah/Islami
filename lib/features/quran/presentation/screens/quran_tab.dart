import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/features/quran/presentation/screens/sura_details.dart';
import 'package:islami/features/quran/data/datasources/quran_local_data_source.dart';
import 'package:islami/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:islami/features/quran/domain/usecases/add_recent_sura.dart';
import 'package:islami/features/quran/domain/usecases/get_recent_suras.dart';
import 'package:islami/features/quran/domain/usecases/get_suras.dart';
import 'package:islami/features/quran/presentation/cubit/quran_tab_cubit.dart';
import 'package:islami/features/quran/presentation/cubit/quran_tab_state.dart';
import 'package:islami/core/common_widget/base_tob_body.dart';
import 'package:islami/features/quran/presentation/widgets/most_recent_card.dart';
import 'package:islami/features/quran/presentation/widgets/quran_empty_search_state.dart';
import 'package:islami/features/quran/presentation/widgets/quran_search_field.dart';
import 'package:islami/features/quran/presentation/widgets/quran_section_header.dart';
import 'package:islami/features/quran/presentation/widgets/sura_card.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});
  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  final _searchController = TextEditingController();

  void _openSura(BuildContext context, QuranTabCubit cubit, Sura sura) {
    Navigator.pushNamed(context, SuraDetails.routeName, arguments: sura);
    unawaited(cubit.addToRecent(sura));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataSource = QuranLocalDataSourceImpl();
    final repository = QuranRepositoryImpl(dataSource);
    return BlocProvider(
      create: (_) => QuranTabCubit(
        getSuras: GetSuras(repository),
        getRecentSuras: GetRecentSuras(repository),
        addRecentSura: AddRecentSura(repository),
      )..initialize(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BaseTabBody(
          child: BlocBuilder<QuranTabCubit, QuranTabState>(
            builder: (context, state) {
              final cubit = context.read<QuranTabCubit>();
              if (state.status == QuranTabStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'تعذر تحميل قائمة السور'));
              }
              if (state.status == QuranTabStatus.loading || state.status == QuranTabStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuranSearchField(
                    controller: _searchController,
                    isSearching: state.isSearching,
                    onChanged: cubit.search,
                    onClear: () { _searchController.clear(); cubit.search(''); },
                  ),
                  if (state.recentSuras.isNotEmpty && !state.isSearching) ...[
                    const QuranSectionHeader(title: 'الأحدث'),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.recentSuras.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => MostRecentCard(
                          sura: state.recentSuras[index],
                          onSuraClick: (sura) => _openSura(context, cubit, sura),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  QuranSectionHeader(title: state.isSearching
                      ? 'نتائج البحث (${state.visibleSuras.length})' : 'قائمة السور'),
                  Expanded(
                    child: state.visibleSuras.isEmpty
                        ? const QuranEmptySearchState()
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: state.visibleSuras.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1, indent: 56, endIndent: 24,
                              color: context.palette.onBackground.withValues(alpha: .15),
                            ),
                            itemBuilder: (context, index) => SuraCard(
                              sura: state.visibleSuras[index],
                              onSuraClick: (sura) => _openSura(context, cubit, sura),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
