import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/constans/app_images.dart';
import 'package:islami/core/theme/app_palette.dart';

import 'package:islami/core/common_widget/base_tob_body.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import '../cubit/sebha_cubit.dart';
import '../cubit/sebha_state.dart';
import '../widgets/sebha_dial.dart';
import '../widgets/sebha_progress_indicator.dart';

class SebhaTab extends StatefulWidget {
  const SebhaTab({super.key});
  @override
  State<SebhaTab> createState() => _SebhaTabState();
}

class _SebhaTabState extends State<SebhaTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late Animation<double> _rotation;
  double _currentRotation = 0;
  double _targetRotation = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotation = _buildRotation(0, 0);
  }

  Animation<double> _buildRotation(double begin, double end) =>
      Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: _rotationController,
          curve: Curves.easeOutCubic,
        ),
      );

  Color _snackBackground() {
    final palette = context.palette;
    return Theme.of(context).brightness == Brightness.dark
        ? palette.background
        : palette.surface;
  }

  void _showSnack(String message, {Duration duration = const Duration(seconds: 2), bool favorite = false}) {
    final palette = context.palette;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: _snackBackground(),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.primary.withValues(alpha: .4)),
        ),
        content: Row(children: [
          if (favorite) ...[
            Icon(Icons.favorite_rounded, color: palette.primary, size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(message, style: TextStylesHelper.mediumLabelTextStyle(context))),
        ]),
        duration: duration,
      ));
  }

  void _onSebhaTap(BuildContext cubitContext) {
    unawaited(SystemSound.play(SystemSoundType.click));
    final cubit = cubitContext.read<SebhaCubit>();
    final roundCompleted = cubit.increment();
    _currentRotation = _targetRotation;
    _targetRotation += .18;
    _rotation = _buildRotation(_currentRotation, _targetRotation);
    _rotationController.forward(from: 0);
    if (roundCompleted) {
      _showSnack('انتقلت إلى: ${cubit.currentZekr}', favorite: true);
    }
  }

  void _resetCounter(BuildContext cubitContext) {
    cubitContext.read<SebhaCubit>().reset();
    _currentRotation = 0;
    _targetRotation = 0;
    _rotation = _buildRotation(0, 0);
    _rotationController.reset();
    _showSnack('تم إعادة العداد', duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocProvider(
      create: (_) => SebhaCubit(),
      child: Directionality(
      textDirection: TextDirection.rtl,
      child: BaseTabBody(
        child: BlocBuilder<SebhaCubit, SebhaState>(
          builder: (context, state) => Column(children: [
            const SizedBox(height: 16),
            Text(
              'سَبِّحِ اسْمَ رَبِّكَ الْأَعْلَى',
              style: TextStylesHelper.largeTitleTextStyle(
                context,
                textColor: palette.onBackground,
              ).copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'اضغط للتسبيح  •  اضغط مطولاً لإعادة العداد',
              style: TextStylesHelper.smallLabelTextStyle(
                context,
                textColor: palette.onBackground.withValues(alpha: .55),
              ),
            ),
            const Spacer(flex: 1),
            Image.asset(AppImages.hand2, height: 90),
            const SizedBox(height: 8),
            SebhaDial(
              rotation: _rotation,
              zekr: context.read<SebhaCubit>().currentZekr,
              counter: state.counter,
              onTap: () => _onSebhaTap(context),
              onLongPress: () => _resetCounter(context),
            ),
            const Spacer(flex: 2),
            SebhaProgressIndicator(
              activeIndex: state.zekrIndex,
              count: SebhaCubit.azkar.length,
            ),
          ]),
        ),
      ),
      ),
    );
  }
}
