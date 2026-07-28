import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';
import 'package:islami/core/widget/base_tob_body.dart';

class SebhaTab extends StatefulWidget {
  const SebhaTab({super.key});

  @override
  State<SebhaTab> createState() => _SebhaTabState();
}

class _SebhaTabState extends State<SebhaTab>
    with SingleTickerProviderStateMixin {
  int counter = 0;
  int zekrIndex = 0;

  final List<String> azkar = ["سبحان الله", "الحمد لله", "الله أكبر"];

  late AnimationController _controller;

  late Animation<double> _rotationAnimation;

  double _currentRotation = 0.0;
  double _targetRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSebhaTap() {
  setState(() {
    counter++;
    if (counter == 32) {
      counter = 0;
      zekrIndex = (zekrIndex + 1) % azkar.length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.black,
          content: Row(
            children: [
              Text(
                "${azkar[zekrIndex]}",
                style: TextStylesHelper.largeBodyTextStyle(
                  textColor: AppColors.gold,
                ),
              ),
              const Spacer(),
              Icon(Icons.favorite_rounded, color: AppColors.gold),
            ],
          ),
          duration: const Duration(seconds: 2 ),
        ),
      );

      // if (zekrIndex == 0) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       backgroundColor: AppColors.brown,
      //       content:  Text(
      //         "تم إكمال دورة تسبيح كاملة ",
      //         style: TextStylesHelper.largeBodyTextStyle(textColor:AppColors.white )
      //       ),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      // }
    }

    _currentRotation = _targetRotation;
    _targetRotation = _targetRotation + 0.2;

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _targetRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(from: 0.0);
  });
}


  void _resetCounter() {
    setState(() {
      counter = 0;
      zekrIndex = 0;
      _currentRotation = 0.0;
      _targetRotation = 0.0;
      _rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseTabBody(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "سَبِّحِ اسْمَ رَبِّكَ الأعلى ",
            style: TextStylesHelper.largeTitleTextStyle(textColor: Colors.white),
          ),
          const SizedBox(height: 10),
          Image.asset(AppImages.hand2),
          GestureDetector(
            onTap: _onSebhaTap,
            onLongPress: _resetCounter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Image.asset(
                    AppImages.sebhaBody,
                    fit: BoxFit.contain,
                    height: 300,
                    width: 300,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      azkar[zekrIndex],
                      style: TextStylesHelper.largeTitleTextStyle(
                        textColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "$counter",
                      style: TextStylesHelper.largeTitleTextStyle(
                        textColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}