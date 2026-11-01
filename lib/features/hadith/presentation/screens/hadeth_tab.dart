import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/model/hadeth.dart';
import 'package:islami/features/hadith/data/datasources/hadith_asset_data_source.dart';
import 'package:islami/features/hadith/data/repositories/hadith_repository_impl.dart';
import 'package:islami/features/hadith/domain/usecases/get_hadith.dart';
import 'package:islami/features/hadith/presentation/cubit/hadith_cubit.dart';
import 'package:islami/features/hadith/presentation/cubit/hadith_state.dart';

import 'package:islami/core/common_widget/base_tob_body.dart';
import 'reader/hadeth_details_screen.dart';
import '../widgets/hadeth_carousel_card.dart';
import '../widgets/hadeth_error_state.dart';
import '../widgets/hadeth_loading_state.dart';
import '../widgets/hadeth_progress_footer.dart';

class HadethTab extends StatelessWidget {
  const HadethTab({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HadithCubit(GetHadith(HadithRepositoryImpl(HadithAssetDataSource())))..load(),
    child: const Directionality(textDirection: TextDirection.rtl, child: _HadethTabBody()),
  );
}

class _HadethTabBody extends StatefulWidget {
  const _HadethTabBody();
  @override
  State<_HadethTabBody> createState() => _HadethTabBodyState();
}

class _HadethTabBodyState extends State<_HadethTabBody> {
  // This state owns only the page controller and current carousel index.
  final _pageController = PageController(viewportFraction: .82);
  int _currentPage = 0;

  void _openDetails(Hadeth hadeth) {
    Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => HadethDetailsScreen(hadeth: hadeth),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(opacity: curved, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(curved), child: child));
      },
    ));
  }

  void _onCardTap(int index, Hadeth hadeth) {
    if (index == _currentPage) {
      _openDetails(hadeth);
    } else {
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => BaseTabBody(
    child: BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        if (state.status == HadithStatus.initial || state.status == HadithStatus.loading) return const HadethLoadingState();
        if (state.status == HadithStatus.failure) {
          return HadethErrorState(message: state.errorMessage ?? 'تعذر تحميل الأحاديث', onRetry: () => unawaited(context.read<HadithCubit>().load()));
        }
        final hadethList = state.items;
        return Column(children: [
          Expanded(child: PageView.builder(
            controller: _pageController,
            itemCount: hadethList.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) { HapticFeedback.selectionClick(); setState(() => _currentPage = index); },
            itemBuilder: (context, index) => AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                var page = _currentPage.toDouble();
                if (_pageController.hasClients && _pageController.position.haveDimensions) page = _pageController.page ?? page;
                final diff = (page - index).abs().clamp(0.0, 1.0).toDouble();
                return Opacity(opacity: 1 - diff * .4, child: Transform.scale(scale: 1 - diff * .1, child: child));
              },
              child: HadethCarouselCard(hadeth: hadethList[index], onTap: () => _onCardTap(index, hadethList[index])),
            ),
          )),
          HadethProgressFooter(current: _currentPage, total: hadethList.length),
        ]);
      },
    ),
  );
}
