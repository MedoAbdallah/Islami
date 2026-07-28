import 'package:flutter/material.dart';
import 'package:islami/core/model/azkar_card.dart';
import 'package:islami/core/theme/app_colors.dart';
import 'package:islami/core/theme/textstyle.dart';

class AzkarCardWidget extends StatelessWidget {
  const AzkarCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: askar.length,
      itemBuilder: (context, index) {
        final azkarData = askar[index];
        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(azkarData.imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              Text(
                azkarData.title,
                style: TextStylesHelper.mediumBodyTextStyle(textColor: AppColors.white),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
