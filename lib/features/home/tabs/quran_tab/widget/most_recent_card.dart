import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';


class MostRecentCard extends StatelessWidget {
  final Sura sura;
  final Function(Sura) onSuraClick;

  const MostRecentCard({
    required this.sura,
    required this.onSuraClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onSuraClick(sura);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sura.nameEn,
                  style: TextStylesHelper.largeLabelTextStyle(
                    textColor: AppColors.black,
                  ),
                ),
                Text(
                  sura.nameAr,
                  style: TextStylesHelper.largeLabelTextStyle(
                    textColor: AppColors.black,
                  ),
                ),
                Text(
                  "${sura.ayaNumbers} Verses",
                  style: TextStylesHelper.largeBodyTextStyle(
                    textColor: AppColors.black,
                  ),
                ),
              ],
            ),
            Image.asset(AppImages.imgMostRecent),
          ],
        ),
      ),
    );
  }
}
