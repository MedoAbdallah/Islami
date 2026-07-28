import 'package:flutter/material.dart';
import 'package:islami/core/constans/app_Images.dart';
import 'package:islami/core/model/sura.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';

class SuraCard extends StatelessWidget {
  final Sura sura;
  final Function(Sura) onSuraClick;
  const SuraCard({required this.sura, required this.onSuraClick, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSuraClick(sura);
      },
      child: ListTile(
        title: Text(
          sura.nameEn,
          style: TextStylesHelper.mediumLabelTextStyle(textColor: AppColors.white),
        ),
        subtitle: Text(
          sura.nameAr,
          style: TextStylesHelper.mediumLabelTextStyle(textColor: AppColors.white),
        ),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(AppImages.suraNumberDecoration, height: 70, width: 70),
            Text(
              sura.id.toString(),
              style: TextStylesHelper.mediumLabelTextStyle(
                textColor: AppColors.white,
              ),
            ),
          ],
        ),
        trailing: Text(
          sura.ayaNumbers,
          style: TextStylesHelper.mediumLabelTextStyle(textColor: AppColors.white),
        ),
      ),
    );
  }
}
