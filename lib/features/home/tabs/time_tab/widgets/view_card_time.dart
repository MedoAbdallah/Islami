import 'package:flutter/material.dart';
import 'package:islami/core/model/prayertime.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';

class ViewCardTime extends StatelessWidget {
  const ViewCardTime({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController _pageController = PageController(
      viewportFraction: 0.30,
      initialPage: 4,
    );

    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: dataTime.length,
        itemBuilder: (context, index) {
          final data = dataTime[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.2)).clamp(0.9, 1.0);
              }
              return Transform.scale(scale: value, child: child);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.black, Colors.black.withAlpha(70)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.prayerName,
                        style: TextStylesHelper.smallTextStyle(
                          textColor: AppColors.white,
                        ),
                      ),
                      Text(
                        data.time,
                        style: TextStylesHelper.largeFontTextStyle(
                          textColor: AppColors.white,
                        ),
                      ),
                      Text(
                        data.amPm,
                        style: TextStylesHelper.largeBodyTextStyle(
                          textColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
